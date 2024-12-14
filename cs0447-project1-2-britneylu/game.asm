.include "constants.asm"
.include "macros.asm"

.globl game
.globl game_end

.text

game:
	enter
	
	jal start_screen

game_while:
	# draw horizontal divider for info area
    li a0, 0
    li a1, 55
    li a2, DISPLAY_W
    li a3, COLOR_WHITE
    jal display_draw_hline
    li a0, 0
    li a1, 56
    li a2, DISPLAY_W
    li a3, COLOR_WHITE
    jal display_draw_hline
    
    # set up the call to display_draw_colored_text
	li a0, 3                   # x position for text
	li a1, 58                  # y position for text
	lstr a2, "Pts:"            # load address of "pts" string
	jal display_draw_text
	
	# draw game info
    li a0, 25
    li a1, 58
    la a2, player_score
    lw a2, (a2)           # load the actual score value (not address!)
    jal display_draw_int

	jal display_arena
	
	jal display_lives
	
	jal handle_input
	jal move_player
    jal display_player
    
   	jal display_macguffins
   	jal check_and_collect_macguffin
    
	jal display_enemy
	jal move_enemy
	jal check_collision
	jal update_invincibility
	jal display_player

	# update the frame and wait for next frame
	jal display_update_and_clear
	jal wait_for_next_frame

	# check if 'x' was pressed to exit the game
	lw t0, x_pressed
	bnez t0, game_end       	# if 'x' pressed --> jump to game end
	j game_while             	# loop back to start of game while-loop

game_end:
	# clear the screen before exiting
	jal end_screen
	jal display_update_and_clear
	jal wait_for_next_frame

	leave                      # exit the game

# FUNCTION: start screen
start_screen:
    # display "The Macguffin Hunter"
    li a0, 23
    li a1, 5
    lstr a2, "The"
    jal display_draw_text
    
    li a0, 5
    li a1, 11
    lstr a2, "Macguffin"
    jal display_draw_text
    
    li a0, 13
    li a1, 17
    lstr a2, "Hunter"
    jal display_draw_text
    
    # display "Press b to start"
    li a0, 5
    li a1, 36
    lstr a2, "Press b"
    li a3, 4
    jal display_draw_colored_text

    li a0, 11
    li a1, 42
    lstr a2, "to begin"
    li a3, 4
    jal display_draw_colored_text
    
    # display "Press x to exit"
    li a0, 5
    li a1, 48
    lstr a2, "Press x"
    li a3, 1
    jal display_draw_colored_text

    li a0, 11
    li a1, 54
    lstr a2, "to exit"
    li a3, 1
    jal display_draw_colored_text
    
    jal handle_input
    lw t0, b_pressed
    bnez t0, game_while   # start game loop if 'x' is pressed

    jal display_update_and_clear
    jal wait_for_next_frame
    j start_screen
    
# FUNCTION: end screen
end_screen:
	# display "Game Over"
	li a0, 5
    li a1, 5
    lstr a2, "Game Over"
    li a3, 4
    jal display_draw_colored_text

	# display "You Scored"
    li a0, 23
    li a1, 15
    lstr a2, "You"
    jal display_draw_text
    
    li a0, 14
    li a1, 21
    lstr a2, "Scored:"
    jal display_draw_text
    
   	# display integer score
   	li a0, 29
    li a1, 27
    la a2, player_score
    lw a2, (a2)           # load the actual score value (not address!)
    li a3, 1
    jal display_draw_colored_int
    
    jal display_update_and_clear
    jal wait_for_next_frame
    j end_screen