
main:
    # look for button presses to do different operations
    lw $r10, 2048(0)
    bne $r10, $r0, tas
    j main



tas:
    #r19 is current offset 
    addi $r19, $r0, 0
    lw $r4, 2052($r0)
    j wait_for_serial

    tas_loop:
        add $r4, $r5, $r0
        lw_rom $r29, $r19, 0
        addi $r19, $r19, 1

        wait_for_serial:
            lw $r5, 2052($r0)
            bne $r5, $r4, tas_loop
            j wait_for_serial