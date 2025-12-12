nop

# Initializing playerL and playerR
addi $8, $0, 0

addi $3, $0, 2048 # dmem[2048] is playerL
sw   $8, 0($3)

addi $3, $0, 2049 # dmem[2049] is playerR
sw   $8, 0($3)

# Check if a player scored
nop               # Used for timing control
addi $2, $0, 2046 # dmem[2046] is event_addr
lw   $9, 0($2)
nop               # Used for hazard control

# Check if left player scored
addi $8, $0, 1
beq  $8, $9, 5   # If dmem[2046] == 1, jumps to add left branch
nop              # Used for hazard control

# Check if right player scored
addi $8, $0, 2
beq  $8, $9, 14  # If dmem[2046] == 2, jumps to add right branch
nop
j 6              # Loops back to the beginning of the check

# Add left
addi $3, $0, 2048
lw   $10, 0($3)
nop              # Used for hazard control
addi $10, $10, 1 # Increments current score by 1
sw   $10, 0($3)

addi $3, $0, 2047 # dmem[2047] is clear_addr (Clears the event_addr bit if written to)
lw   $11, 0($3)
nop
addi $11, $0, 1
sw   $11, 0($3)
nop              # Used for timing control
j 6

# Add right
addi $3, $0, 2049
lw   $10, 0($3)
nop              # Used for hazard control
addi $10, $10, 1 # Increments current score by 1
sw   $10, 0($3)

addi $3, $0, 2047 # dmem[2047] is clear_addr (Clears the event_addr bit if written to)
lw   $11, 0($3)
nop
addi $11, $0, 1
sw   $11, 0($3)
nop              # Used for timing control
j 6

