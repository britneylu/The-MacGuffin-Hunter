.include "constants.asm"
.include "macros.asm"

.globl display_arena
.globl arena_matrix
.globl get_matrix_element_addr
.globl get_matrix_wall_addr
.globl update_arena_matrix

.data
# tile block definitions for walls and roads (5x5 pixel blocks)
wall_block:
    .byte 8, 15, 8, 0, 15
    .byte 15, 8, 15, 8, 0
    .byte 8, 0, 8, 15, 8
    .byte 0, 8, 15, 8, 15
    .byte 15, 8, 0, 15, 8
    
road_block:
    .byte 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0

# arena layout: 1 = wall, 0 = road
arena_matrix:    
    .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
    .byte 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1
    .byte 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1
    .byte 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1
    .byte 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1
    .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1
    .byte 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1
    .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
    .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

.text
    
display_arena:
	
	enter s0, s1, s2, s3, s4, s5
	
	li s1, 0	# the index (i) row
	li s2, 0	# the index (j) column
	li s3, 12	# the number of elements in each row
	li s4, 0	# x coordinate of blit
	li s5, 0	# y coordinate of blit
	
	_maze_print_start:
	bge s2, 12, _move_i		# if j reaches end of row --> move to next row
	move a1, s1				# temp variable to store i
	move a2, s2				# temp variable to store j
	
	jal get_matrix_element_addr
	
	move s2, a2					# store updated column index
	
	lb t0, (v0)					# load byte from matrix element
	beq t0, 1, _print_wall		# if matrix_element_address returns 1 --> print wall
	beq t0, 0, _print_road		# if matrix_element_address returns 2 --> print road
	
	_maze_print_continue:
	add s2, s2, 1				# increment column index
	
	j _maze_print_start
	
	_move_i:
		bge s1, 10, _maze_print_end		# finish printing if i reaches 11
		li s2, 0						# sets j to zero
		add s1, s1, 1					# increments i by 1
		j _maze_print_start
		
	_print_wall:
	bge s4, 59, _wrap_wall				# if x-coor reaches 60 --> wrap to new line
	
		_print_wall_blit:
		move a0, s4						# set x-coord
		move a1, s5						# set y-coord
		la a2, wall_block				# load wall block patter
		jal display_blit_5x5_trans
		add s4, s4, 5					# increments by 5 (5x5 pixels)
		
		j _maze_print_continue
		
		_wrap_wall:
		bge s5, 59, _maze_print_end		# if y-coor reaches 60 --> end printing
		add s5, s5, 5					# move y-coord for next row
		li s4, 0						# reset x-coord --> is now 0
		
		j _print_wall_blit
		
	_print_road:
	bge s4, 59, _wrap_road				# if x-coor reaches 60 --> wrap to new line
	
		_print_road_blit:
		move a0, s4						# set x-coord
		move a1, s5						# set y-coord
		la a2, road_block				# load road block pattern
		jal display_blit_5x5_trans
		add s4, s4, 5					# increment by 5 (5x5 pixel)
		
		j _maze_print_continue
		
		_wrap_road:
		bge s5, 59, _maze_print_end		# if y-coor reaches 60 --> end printing
		add s5, s5, 5					# move y-coord for next row
		li s4, 0						# reset x-coord --> is now 0
		j _print_road_blit
		
	_maze_print_end:
	leave s1, s2, s3, s4, s5			# restore saved registers
	
# FUNCTION: find the bit in the matrix
get_matrix_element_addr:
	enter s0, s1, s2
	
	la s0, arena_matrix		# load base address of arena matrix
	move s1, a1				# row index
	move s2, a2				# column index
	
	mul s1, s1, 12			# offset for row (12 elements per row)
	mul s2, s2, 1			
	add s2, s2, s1			# calculate byte offset in matrix
	add v0, s2, s0			# add base address to offset
	
	leave s0, s1, s2
	
# FUNCTION: to find if there is a wall at the address
get_matrix_wall_addr:
	enter s0, s1, s2
	
	la s0, arena_matrix		# load base address of arena matrix
	move s1, a1				# row index
	move s2, a2				# column index
	
	div s1, s1, 5			# scale row to 5x5 block
	div s2, s2, 5			# scale column to 5x5 block
	
	mul s2, s2, 12			# offset for row
	mul s1, s1, 1
	add s2, s2, s1			# calculate byte offset
	add v0, s2, s0			# add base address to offset
	
	leave s0, s1, s2
	
update_arena_matrix:
	enter s0, s1, s2, s3
	
	la s0, arena_matrix		# load base address of arena matrix
	move s1, a1				# row index
	move s2, a2				# column index
	move s3, a3				# new value for the matrix element
	
	div s1, s1, 5			# scale row to 5x5 block
	div s2, s2, 5			# scale column to 5x5 block
	
	mul s2, s2, 12			# offset for row
	mul s1, s1, 1
	add s2, s2, s1			# calculate byte offset
	add v0, s2, s0			# add base address to offset
	
	sb s3, (v0)				# store new value at calculated address
	
	leave s0, s1, s2, s3