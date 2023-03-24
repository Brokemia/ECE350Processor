nop
nop
nop
nop
nop
nop
addi $r1, $r1, 1
addi $r2, $r2, 3
addi $r3, $r3, 5
sw $r3, 0($r3)
sw $r2, 0($r2)
sw $r1, 0($r1)
lw $r4, 0($r2)
lw $r5, 0($r3)
sw $r3, 0($r1)
lw $r6, 0($r1)