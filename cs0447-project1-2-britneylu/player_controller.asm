.include "constants.asm"
.include "macros.asm"

.globl move_player

.text

move_player:
    enter s0, s1
    
    lw s0, player_x                   # load current player x position
    lw s1, player_y                   # load current player y position

    # get keyboard input for direction
    lw a0, DISPLAY_KEYS

    # determine direction and compute new potential position
    move t0, s0                       # start with current x (temp x)
    move t1, s1                       # start with current y (temp y)
    beq a0, KEY_UP, try_up
    beq a0, KEY_DOWN, try_down
    beq a0, KEY_LEFT, try_left
    beq a0, KEY_RIGHT, try_right
    j movement_done                   # skip movement if no directional key is pressed

	try_up:
    	sub t1, t1, 1                     # move up by 1 pixel
    	j check_bounds
	try_down:
    	add t1, t1, 1                     # move down by 1 pixel
    	j check_bounds
	try_left:
    	sub t0, t0, 1                     # move left by 1 pixel
    	j check_bounds
	try_right:
    	add t0, t0, 1                     # move right by 1 pixel

		check_bounds:
    		# ensure new position stays within display bounds
    		blt t0, 5, movement_done          # if out of bounds on the left --> cancel movement
    		bgt t0, 50, movement_done         # if out of bounds on the right --> cancel movement
    		blt t1, 5, movement_done          # if out of bounds at the top --> cancel movement
    		bgt t1, 45, movement_done         # if out of bounds at the bottom --> cancel movement
    		
    		# Check all four corners of the player 
    		move a0, t0                       # top-left corner x
    		move a1, t1                       # top-left corner y
    		jal is_inside_wall
    		beq v0, 1, movement_done          # cancel if any corner is in a wall

    		add a0, t0, 4                     # top-right corner x
    		move a1, t1                       # top-right corner y
    		jal is_inside_wall
    		beq v0, 1, movement_done

    		move a0, t0                       # bottom-left corner x
    		add a1, t1, 4                     # bottom-left corner y
    		jal is_inside_wall
    		beq v0, 1, movement_done

    		add a0, t0, 4                     # bottom-right corner x
    		add a1, t1, 4                     # bottom-right corner y
    		jal is_inside_wall
    		beq v0, 1, movement_done


    		# update player position if within bounds and not inside a wall
    		move s0, t0
    		move s1, t1

				movement_done:
    			# store updated position back to player_x and player_y
    			sw s0, player_x
    			sw s1, player_y
    	
    leave s0, s1