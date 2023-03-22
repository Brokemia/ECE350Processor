nop
nop
nop
nop
nop
nop 
addi $r0, $r0, 0
addi $r1, $r1, 1
addi $r2, $r2, 2
addi $r3, $r3, 3
addi $r4, $r4, 4
j j1
addi $r2, $r0, 999
addi $r2, $r0, 999
j5:
    addi $r13, $r13, 13
    addi $r14, $r14, 14
    addi $r15, $r15, 15
    j j6
j1:
    addi $r5, $r5, 5
    addi $r6, $r6, 6
    j j2
j3:
    addi $r7, $r7, 7
    addi $r8, $r8, 8
    jal j4
    addi $r9, $r9, 9
    j j5
j2:
    j j3
j4:
    addi $r10, $r10, 10
    addi $r11, $r11, 11
    addi $r12, $r12, 12
    nop
    nop
    nop
    nop
    jr $r31
j6:
    nop
    nop