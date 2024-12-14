.include "constants.asm"
.include "macros.asm"

.globl move_enemy
.globl update_invincibility
.globl invincible
.globl invincibility_timer

.data

frame_rate: .word 60           # frames per second
invincible_time: .word 180     # total frames for 3 seconds (60 fps * 3 seconds)

arena_width:  .word 45  		# arena width (for boundary checking)
arena_height: .word 45  		# arena height (for boundary checking)

enemy_directions:
	.byte 1
	.byte -1
enemy_step_counter: .word 0
enemy_move_threshold: .word 20

invincible: .word 0             # player invincibility status (0 = not invincible)
invincibility_timer: .word 0    # timer for player's invincibility duration

.text

# enemy movement and collision detection
move_enemy:
    enter s0, s1, s2, s3, s4

    # check enemy step counter
    lw s0, enemy_step_counter   # load current step counter
    lw s1, enemy_move_threshold # load movement threshold
    addi s0, s0, 1              # increment the counter
    sw s0, enemy_step_counter   # store the updated counter

    blt s0, s1, move_enemy_done # if counter < threshold --> skip moving enemies

    # reset the counter after enemies move
    li s0, 0
    sw s0, enemy_step_counter

    # enemy movement logic
    la s0, enemy_positions      # pointer to enemy positions
    la s1, enemy_directions     # pointer to enemy directions

    lw s2, player_x             # load player's x-coordinate
    lw s3, player_y             # load player's y-coordinate

move_enemy_loop:
    lw s4, 0(s0)                # load x-coordinate of current enemy
    lw t0, 4(s0)                # load y-coordinate of current enemy
    addi s0, s0, 8              # move to next enemy's coordinates

    # check for end marker (-1, -1)
    li t1, -1
    beq s4, t1, move_enemy_done # if x = -1 --> done
    beq t0, t1, move_enemy_done # if y = -1 --> done

    # collision Detection
    beq s4, s2, check_y_collision
    j move_enemy_logic

check_y_collision:
    beq t0, s3, handle_collision # if y matches too --> handle collision
    j move_enemy_logic
    
handle_collision:
    # check if player is already invincible
    lw t2, invincible
    bne t2, zero, move_enemy_logic # skip if already invincible

    # set player to invincible and initialize timer
    li t2, 1
    sw t2, invincible            # set invincibility flag
    la t2, invincible_time
    lw t2, (t2)                  # load invincible time (e.g., 180 frames)
    sw t2, invincibility_timer   # set invincibility timer
    j move_enemy_logic


move_enemy_logic:
    # load direction for this enemy
    lb t2, 0(s1)
    addi s1, s1, 1              # move to next direction

    # initialize minimum distance and best direction
    li t3, 999999               # arbitrarily large value for minimum distance
    li t4, -1                   # best direction (-1 = no valid direction)

    # check possible directions
    # UP: (s4, t0 - 1)
    sub t5, t0, 1               # new y-coordinate for up
    move a0, s4                 # x-coordinate stays the same
    move a1, t5
    jal is_inside_wall          # check if position is a wall
    bne v0, zero, check_down    # skip if wall

    # calculate distance squared
    sub t6, s4, s2              # x difference
    mul t6, t6, t6              # x^2
    sub t7, t5, s3              # y difference
    mul t7, t7, t7              # y^2
    add t8, t6, t7              # distance squared
    blt t8, t3, update_up       # if less than min distance --> update
    j check_down

update_up:
    move t3, t8                 # update minimum distance
    li t4, 0                    # set direction to up
    j check_down

# DOWN: (s4, t0 + 1)
check_down:
    add t5, t0, 1               # new y-coordinate for down
    move a0, s4
    move a1, t5
    jal is_inside_wall
    bne v0, zero, check_left
    sub t6, s4, s2
    mul t6, t6, t6
    sub t7, t5, s3
    mul t7, t7, t7
    add t8, t6, t7
    blt t8, t3, update_down
    j check_left

update_down:
    move t3, t8
    li t4, 1
    j check_left

# LEFT : (s4 - 1, t0)
check_left:
    sub t5, s4, 1               # new x-coordinate for left
    move a0, t5
    move a1, t0                 # y-coordinate stays the same
    jal is_inside_wall
    bne v0, zero, check_right
    sub t6, t5, s2
    mul t6, t6, t6
    sub t7, t0, s3
    mul t7, t7, t7
    add t8, t6, t7
    blt t8, t3, update_left
    j check_right

update_left:
    move t3, t8
    li t4, 2
    j check_right

# RIGHT: (s4 + 1, t0)
check_right:
    add t5, s4, 1               # new x-coordinate for right
    move a0, t5
    move a1, t0
    jal is_inside_wall
    bne v0, zero, update_position
    sub t6, t5, s2
    mul t6, t6, t6
    sub t7, t0, s3
    mul t7, t7, t7
    add t8, t6, t7
    blt t8, t3, update_right
    j update_position

update_right:
    move t3, t8
    li t4, 3

# update enemy position based on chosen direction
update_position:
    beq t4, 0, move_up
    beq t4, 1, move_down
    beq t4, 2, move_left
    beq t4, 3, move_right
    j next_enemy

move_up:
    sub t0, t0, 1               # move up
    j next_enemy

move_down:
    add t0, t0, 1               # move down
    j next_enemy

move_left:
    sub s4, s4, 1               # move left
    j next_enemy

move_right:
    add s4, s4, 1               # move right

next_enemy:
    # store updated coordinates back to memory
    sw s4, -8(s0)
    sw t0, -4(s0)
    j move_enemy_loop

move_enemy_done:
    leave s0, s1, s2, s3, s4

update_invincibility:
    lw t0, invincibility_timer
    beqz t0, invincibility_done   # if timer is 0 --> skip decrementing

    # decrement the timer
    subi t0, t0, 1
    sw t0, invincibility_timer

    # if timer reaches 0 --> reset invincibility
    bnez t0, invincibility_done
    li t1, 0
    sw t1, invincible

invincibility_done:
    jr ra
