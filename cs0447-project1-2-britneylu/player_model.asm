.include "constants.asm"
.include "macros.asm"

.globl player
.globl player_x
.globl player_y
.globl is_inside_wall

.data

player:
	.byte -1, 7, 7, 7, -1       # head (white with glowing eyes)
	.byte 7, 13, -1, 13, 7      # eyes (dark Blue)
	.byte -1, 7, 7, 7, -1       # chestplate (white)
	.byte 5, 5, 7, 5, 5         # arms and core
	.byte -1, 5, -1, 5, -1      # feet

player_x: .word 5              # initial x-position
player_y: .word 5              # initial y-position

.text

# check if a given position is inside a wall
# arguments: a0 = x, a1 = y
is_inside_wall:
    enter s0, s1

    # store coordinates in s0 (x) and s1 (y)
    move s0, a0                     # save x-coordinate in s0
    move s1, a1                     # save y-coordinate in s1

    # pass s0 (x) and s1 (y) to get_matrix_wall_addr
    move a2, s0                     # x-coordinate
    move a1, s1                     # y-coordinate
    jal get_matrix_wall_addr        # get address of the matrix element

    # load the value at the calculated address
    lb v0, (v0)                     # load byte from the calculated address

    # check if the value indicates a wall
    li a3, 1                        # wall identifier
    beq v0, a3, inside_wall         # if value = 1 --> it is a wall
    li v0, 0                        # otherwise --> return 0 (not inside wall)
    j finish                        # skip the wall case

inside_wall:
    li v0, 1                        # set return value to 1 (inside wall)

finish:
    leave s0, s1