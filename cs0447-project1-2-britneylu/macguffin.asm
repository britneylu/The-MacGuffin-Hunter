.include "constants.asm"
.include "macros.asm"

.globl display_macguffins
.globl check_and_collect_macguffin

.data

macguffin_positions:
    .word 45      # macGuffin 1 x
    .word 45      # macGuffin 1 y
    .word 25      # macGuffin 2 x
    .word 45      # macGuffin 2 y
    .word 20      # macGuffin 3 x
    .word 20      # macGuffin 3 y
    .word 35      # macGuffin 4 x
    .word 5       # macGuffin 4 y
    .word -1      # end marker x
    .word -1      # end marker y
    
macguffin_blit1:
    .byte -1, -1, 5, -1, -1
    .byte -1, 5, 13, 5, -1
    .byte 5, 13, 7, 13, 5
    .byte -1, 5, 13, 5, -1
    .byte -1, -1, 5, -1, -1

macguffin_blit2:
    .byte -1, -1, 13, -1, -1
    .byte -1, 13, 5, 13, -1
    .byte 13, 5, 7, 5, 13
    .byte -1, 13, 5, 13, -1
    .byte -1, -1, 13, -1, -1

macguffin_blit3:
    .byte -1, -1, 5, -1, -1
    .byte -1, 5, 7, 5, -1
    .byte 5, 7, 13, 7, 5
    .byte -1, 5, 7, 5, -1
    .byte -1, -1, 5, -1, -1

macguffin_blit4:
    .byte -1, -1, 13, -1, -1
    .byte -1, 13, 7, 13, -1
    .byte 13, 7, 5, 7, 13
    .byte -1, 13, 7, 13, -1
    .byte -1, -1, 13, -1, -1

frame_counter: .word 0          # frame counter to control blinking
blink_threshold: .word 10       # toggle visibility every 30 frames
animation_speed: .word 5       	# number of frames per blit (increased for slower animation)
macguffin_count: .word 4        # total number of MacGuffins initially in the arena

.text
    
display_macguffins:
    enter s0, s1, s2, s3, s4

    # increment frame counter
    la s0, frame_counter
    lw s1, (s0)
    addi s1, s1, 1              # increment the frame counter
    sw s1, (s0)

    # determine current blit (cycle through blit1, blit2, blit3, blit4)
    la s2, animation_speed
    lw s3, (s2)
    rem s1, s1, s3              # modulo operation for animation speed
    bnez s1, use_blit4      	# continue with the last blit if not time to switch

    # cycle through the blits
    la s0, frame_counter
    lw s1, (s0)
    divu s1, s1, s3             # divide frame_counter by animation_speed
    rem s1, s1, 4               # modulo 4 for 4 blits
    beqz s1, use_blit1          # frame % 4 == 0 -> blit 1
    beq s1, 1, use_blit2        # frame % 4 == 1 -> blit 2
    beq s1, 2, use_blit3        # frame % 4 == 2 -> blit 3
    j use_blit4                 # frame % 4 == 3 -> blit 4

		use_blit1:
    		la s1, macguffin_blit1      # pointer to blit 1
    		j render_macguffins

		use_blit2:
    		la s1, macguffin_blit2      # pointer to blit 2
    		j render_macguffins

		use_blit3:
    		la s1, macguffin_blit3      # pointer to blit 3
    		j render_macguffins

		use_blit4:
    		la s1, macguffin_blit4      # pointer to blit 4

	render_macguffins:
    	# initialize pointer to macguffin positions
    	la s0, macguffin_positions

		render_last_blit:
    		lw s2, 0(s0)                # load x-coordinate of the current macguffin
    		lw s3, 4(s0)                # load y-coordinate of the current macguffin
    		addi s0, s0, 8              # move to the next macguffin's coordinates

    		# check for end marker (-1, -1)
    		li t0, -1
    		beq s2, t0, display_macguffins_done # If x == -1 --> done
    		beq s3, t0, display_macguffins_done # If y == -1 --> done

    		# set up arguments for display_blit_5x5
    		move a0, s2                 # a0 = x-coordinate (top-left)
    		move a1, s3                 # a1 = y-coordinate (top-left)
    		move a2, s1                 # a2 = pointer to the current blit pattern

    		jal display_blit_5x5_trans  # call blit rendering

    		# repeat loop for the next macguffin
    		j render_last_blit

display_macguffins_done:
    leave s0, s1, s2, s3, s4

# check and collect macguffins (unchanged)
check_and_collect_macguffin:
    enter s0, s1
    
    # load player position
    lw s0, player_x
    lw s1, player_y
    
   # check macguffin 1 (45,45)
    la t0, macguffin_positions
    lw t1, 0(t0)    # x position
    lw t2, 4(t0)    # y position
    li t3, -1
    beq t1, t3, check_macguffin2    # skip if already collected
    bne s0, t1, check_macguffin2    # check x match
    bne s1, t2, check_macguffin2    # check y match
    li t3, -1
    sw t3, 0(t0)    # mark as collected
    sw t3, 4(t0)
    j collect_success
    
	check_macguffin2:
    	# check macguffin 2 (25,45)
    	lw t1, 8(t0)    # x position
    	lw t2, 12(t0)   # y position
    	li t3, -1
    	beq t1, t3, check_macguffin3    # skip if already collected
    	bne s0, t1, check_macguffin3    # check x match
    	bne s1, t2, check_macguffin3    # check y match
    	li t3, -1
    	sw t3, 8(t0)    # mark as collected
    	sw t3, 12(t0)
    	j collect_success
    
	check_macguffin3:
    	# check macguffin 3 (20,20)
    	lw t1, 16(t0)   # x position
    	lw t2, 20(t0)   # y position
    	li t3, -1
    	beq t1, t3, check_macguffin4    # skip if already collected
    	bne s0, t1, check_macguffin4    # check x match
    	bne s1, t2, check_macguffin4    # check y match
    	li t3, -1
    	sw t3, 16(t0)   # mark as collected
    	sw t3, 20(t0)
    	j collect_success
    
	check_macguffin4:
    	# check macguffin 4 (35,5)
    	lw t1, 24(t0)   # x position
    	lw t2, 28(t0)   # y position
    	li t3, -1
    	beq t1, t3, done_checking    # skip if already collected
    	bne s0, t1, done_checking    # check x match
    	bne s1, t2, done_checking    # check y match
    	li t3, -1
    	sw t3, 24(t0)   # mark as collected
    	sw t3, 28(t0)
    	j collect_success

	collect_success:
    	# update macguffin count
    	la t0, macguffin_count
    	lw t1, (t0)
    	subi t1, t1, 1
    	sw t1, (t0)
    
    	# update player score
    	la t0, player_score
    	lw t1, (t0)
    	addi t1, t1, 5
    	sw t1, (t0)
    
    	# check if all macguffins collected
    	la t0, macguffin_count
    	lw t1, (t0)
    	beqz t1, game_end

done_checking:
    leave s0, s1
