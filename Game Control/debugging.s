nop
addi $8, $0, 0
addi $3, $0, 2048 
sw   $8, 0($3)
addi $3, $0, 2049 
sw   $8, 0($3)
nop               
addi $2, $0, 2046 
lw   $9, 0($2)
nop              
addi $8, $0, 1
beq  $8, $9, 5  
nop           
addi $8, $0, 2
beq  $8, $9, 14  
nop
j 6             
addi $3, $0, 2048
lw   $10, 0($3)
nop              
addi $10, $10, 1 
sw   $10, 0($3)
addi $3, $0, 2047 
lw   $11, 0($3)
nop
addi $11, $0, 1
sw   $11, 0($3)
nop            
j 6
addi $3, $0, 2049
lw   $10, 0($3)
nop            
addi $10, $10, 1
sw   $10, 0($3)
addi $3, $0, 2047 
lw   $11, 0($3)
nop
addi $11, $0, 1
sw   $11, 0($3)
nop 
j 6