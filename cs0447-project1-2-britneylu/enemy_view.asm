.include "constants.asm"
.include "macros.asm"


.globl display_enemy

.data
	
.text
display_enemy:
    enter s0, s1, s2, s3

    # initialize pointers to enemy data
    la s0, enemy_positions
    la s1, enemy_colors

		display_enemy_loop:
    		lw s2, 0(s0)                # load x-coordinate of the current enemy
    		lw s3, 4(s0)                # load y-coordinate of the current enemy
    		addi s0, s0, 8              # move to the next enemy's coordinates

    		# check for end marker (-1, -1)
    		li t0, -1
    		beq s2, t0, display_enemy_done # if x == -1 --> done
    		beq s3, t0, display_enemy_done # if y == -1 --> done

    		# set up the arguments for display_blits_5x5_trans
    		move a0, s2                 # a0 = top-left x-coordinate
    		move a1, s3                 # a1 = top-left y-coordinate
    		move a2, s1                 # a2 = pointer to the enemy pattern

    		jal display_blit_5x5_trans

    		# move to the next enemy pattern (25 bytes per enemy)
    		addi s1, s1, 25             # advance to the next pattern in enemy_colors

    		# repeat loop for the next enemy
    		j display_enemy_loop

display_enemy_done:
    leave s0, s1, s2, s3