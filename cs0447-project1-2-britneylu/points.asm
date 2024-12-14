.include "constants.asm"
.include "macros.asm"

.globl heart
.globl display_lives
.globl display_points
.globl player_score
.globl player_lives
.globl check_collision

.data

heart:
    .byte -1, 1, -1, 1, -1
    .byte 1, 1, 1, 1, 1
    .byte 1, 1, 1, 1, 1
    .byte -1, 1, 1, 1, -1
    .byte -1, -1, 1, -1, -1
    
player_score: 
    .word 0                  # player's starting score
player_lives: 
    .word 3                  # player starts with 3 lives

.text

# display lives
display_lives:
    enter s0, s1, s2, s3

    lw s0, player_lives       		# load number of lives
    li s1, 40                 		# starting x-coordinate
    li s2, 58                 		# fixed y-coordinate
    la s3, heart              		# pointer to the heart sprite

	display_lives_loop:
    	blez s0, display_lives_done # if no lives left --> exit loop

    	# set up arguments for display_blit_5x5_trans
    	move a0, s1               	# x-coordinate
    	move a1, s2               	# y-coordinate
    	move a2, s3               	# heart pointer
    	jal display_blit_5x5_trans 	# Display the heart

    	# move to the next position for the next heart
    	addi s1, s1, 6            	# shift x-coordinate by 6
    	subi s0, s0, 1            	# decrement heart count
    	j display_lives_loop

display_lives_done:
    leave s0, s1, s2, s3

# display the player's score
display_points:
    enter
    la a0, player_score       # load address of player score
    lw a0, 0(a0)              # load score into a0
    leave

# check for collision between player and enemies
check_collision:
    enter s0, s1, s2, s3, s4

    # load player's position
    lw s0, player_x           # player's x-coordinate
    lw s1, player_y           # player's y-coordinate

    # pointer to enemy positions
    la s2, enemy_positions

	check_collision_loop:
    	lw s3, 0(s2)          # load enemy x-coordinate
    	lw s4, 4(s2)          # load enemy y-coordinate
    	addi s2, s2, 8        # move to the coodinates of the next enemy

    	# check for end marker (-1, -1)
    	li t0, -1
    	beq s3, t0, check_collision_done 	# if x == -1 -->done
    	beq s4, t0, check_collision_done 	# if y == -1 --> done

    	# check if player position matches enemy position
    	beq s0, s3, collision_detected  	# if x-coordinates match --> check y
    	j check_collision_loop          	# otherwise --> continue loop
	
		collision_detected:
    		beq s1, s4, handle_collision    # if y-coordinates match --> handle collision
    		j check_collision_loop

				handle_collision:
    				# decrease player's lives
    				lw t1, player_lives
    				subi t1, t1, 1
    				sw t1, player_lives

    				# update display of lives
    				jal display_lives

    				# check if lives are 0 (if 0 --> game over)
    				blez t1, call_game_end

				    j check_collision_done
    
					call_game_end:
    					j game_end

check_collision_done:
    leave s0, s1, s2, s3, s4
