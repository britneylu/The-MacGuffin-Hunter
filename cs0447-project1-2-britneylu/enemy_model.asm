.include "constants.asm"
.include "macros.asm"

.globl enemy_positions
.globl enemy_colors

.data

enemy_positions:
    .word 5			# enemy 1 x
    .word 40      	# enemy 1 y
    .word 45      	# enemy 2 x
    .word 15      	# enemy 2 y
    .word 20      	# enemy 3 x
    .word 30      	# enemy 3 y
    .word -1      	# end marker x
    .word -1      	# end marker y

enemy_colors:
    .byte -1, 3, 3, 3, -1
    .byte 3, 1, -1, 1, 3
    .byte -1, 3, 3, 3, -1
    .byte 2, 2, 3, 2, 2
    .byte -1, 2, -1, 2, -1
    
    .byte -1, 3, 3, 3, -1
    .byte 3, 1, -1, 1, 3
    .byte -1, 3, 3, 3, -1
    .byte 2, 2, 3, 2, 2
    .byte -1, 2, -1, 2, -1
    
    .byte -1, 3, 3, 3, -1
    .byte 3, 1, -1, 1, 3
    .byte -1, 3, 3, 3, -1
    .byte 2, 2, 3, 2, 2
    .byte -1, 2, -1, 2, -1

.text
