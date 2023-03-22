nop # Test of all basic ALU operations (no mult or div) with no Hazards
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
add $r6, $r1, $r2
add $r7, $r3, $r4
sub $r8, $r4, $r2
and $r9, $r1, $r3
and $r10, $r1, $r2
or $r11, $r1, $r3
or $r12, $r1, $r2
sll $r13, $r1, 2
sra $r14, $r2, 1
sra $r15, $r5, 1
