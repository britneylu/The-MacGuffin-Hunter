.include "constants.asm"
.include "macros.asm"

.globl display_player
    
.text

display_player:
    enter s0, s1, s2  # save registers

    # load invincible flag and invincibility timer
    lw s0, invincible
    lw s1, invincibility_timer

    # check if invincible
    bne s0, zero, handle_blink

    # regular display if not invincible
    lw a0, player_x               # load player x position
    lw a1, player_y               # load player y position
    la a2, player                 # load player sprite
    jal display_blit_5x5_trans    # display player
    j leave_display_player

handle_blink:
    andi s2, s1, 1                # check if invincibility_timer is even
    bnez s2, leave_display_player # skip display if odd (blink effect)
    
    # display player when even
    lw a0, player_x
    lw a1, player_y
    la a2, player
    jal display_blit_5x5_trans

leave_display_player:
    leave s0, s1, s2
