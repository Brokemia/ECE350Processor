main:
    # look for button presses to do different operations
    lw $r10, 2048(0)
    bne $r10, $r0, wait_for_release
    j main
wait_for_release:
    lw $r10, 2048(0)
    bne $r10, $r0, wait_for_release

tas:
    # r19 is current input block 
    # r18 is frames held per block
    addi $r19, $r0, 0
    addi $r18, $r0, 0
    addi $r29, $r0, 0
    addi $r1, $r0, 1

    # read in initial serial
    lw $r4, 2052($r0)

    # wait for first frame
    j wait_next_frame

    tas_loop:
        # Get inputs for next frame

        # reset serial toggle
        add $r4, $r5, $r0

        # wait if there are more frames to hold 
        bne $r18, $r0, hold_inputs

        # Load next input block
        lw_rom $r29, $r19, 0

        # Shift hold count into r18
        sra $r18, $r29, 16

        # Increment input block counter
        addi $r19, $r19, 1

        hold_inputs:
            addi $r18, $r18, -1

        wait_next_frame:
            lw $r10, 2048(0)
            bne $r10, $r1, blip
            j quick_restart

        blip:
            # Load current serial input
            lw $r5, 2052($r0)

            # If its different from previous, process next frame
            bne $r5, $r4, tas_loop
            
            j wait_next_frame

wait:  
    # r6 has number of cycles to wait,
    # will mutate r6, 
    # r6 must be at least one

    addi $r6, $r0, -1
    bne $r6, $r0, wait
    jr $r31

quick_restart:
    jal get_0_1_1_0
    addi $r29, $r10, 0
    addi $r6, $r0, 5000
    jal wait

    jal get_0_16_0_0
    addi $r29, $r10, 0
    addi $r6, $r0, 5000
    jal wait

    jal get_0_1_0_32
    addi $r29, $r10, 0
    addi $r6, $r0, 800
    jal wait
    
    jal get_0_16_0_0
    addi $r29, $r10, 0
    addi $r6, $r0, 5000
    jal wait

    jal get_0_1_0_32
    addi $r29, $r10, 0
    addi $r6, $r0, 800
    jal wait

    jal get_0_16_0_0
    addi $r29, $r10, 0
    addi $r6, $r0, 5000
    jal wait

    jal get_0_1_128_0
    addi $r29, $r10, 0
    addi $r6, $r0, 800
    jal wait

    jal get_0_16_0_0
    addi $r29, $r10, 0
    addi $r6, $r0, 5000
    jal wait

    jal get_0_1_128_0
    addi $r29, $r10, 0
    addi $r6, $r0, 800
    jal wait

    jal get_0_16_0_0
    addi $r29, $r10, 0
    addi $r6, $r0, 5000
    jal wait

    j main

get_0_1_1_0:
    # 0 1 1 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 1
    sra $r10, $r10, 8
    addi $r10, $r10, 1
    sra $r10, $r10, 8
    addi $r10, $r10, 0

    jr $r31

get_0_16_0_0:
    # 0 16 0 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 16
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 0

    jr $r31

get_0_1_0_32:
    # 0 1 0 32
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 1
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 32

    jr $r31

get_0_1_128_0:
    # 0 1 128 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 1
    sra $r10, $r10, 8
    addi $r10, $r10, 128
    sra $r10, $r10, 8
    addi $r10, $r10, 0

    jr $r31

tas_set_clock:
    # new input every 20833 cycles