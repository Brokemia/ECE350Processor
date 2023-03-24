nop
nop
nop
nop
nop
nop
addi $r1, $r1, 1
addi $r2, $r2, 2
bne $r0, $r0, bad
blt $r0, $r0, bad
j jump1
addi $r2, $r0, 999

jump1:
    nop
    nop
    nop
    nop
    blt $r2, $r1, bad
    addi $r3, $r3, 3
    addi $r4, $r4, 4
    addi $r5, $r5, 5
    addi $r6, $r6, 6
    blt $r1, $r2, branch1
    j bad
    addi $r2, $r0, 999
branch1:
    addi $r7, $r7, 7
    addi $r8, $r8, 8
    addi $r9, $r9, 9
    addi $r10, $r10, 10
    bne $r2, $r3, branch2
    j bad
    j bad
    addi $r3, $r0, 999
branch2:
    addi $r11, $r11, 11
    addi $r12, $r12, 12
    bne $r0, $r1, branch3
bad:
    addi $r1, $r0, 999
branch3:
    addi $r13, $r13, 13