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
addi $r5, $r5, -2
nop
nop
nop
nop
nop
nop
nop
mul $r6, $r0, $r4 # = 0
mul $r7, $r5, $r0 # = 0
mul $r8, $r1, $r2 # = 2
mul $r9, $r3, $r4 # = 12
mul $r10, $r5, r4 # = -8
div $r11, $r0, $r1 # = 0
div $r12, $r2, $r3 # = 0
div $r13, $r2, $r1 # = 2
nop
div $r14, $r4, $r2 # = 2
div $r15, $r4, $r1 # = 4
div $r16, $r4, $r5 # = -2
