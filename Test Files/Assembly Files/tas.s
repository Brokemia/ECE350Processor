main:
    jal quick_restart_setup
    
    # look for button presses to do different operations
    lw $r10, 2048(0)
    bne $r10, $r0, tas
    j main

tas:
    # r19 is current input block 
    # r18 is frames held per block
    addi $r19, $r0, 0
    addi $r18, $r0, 0
    addi $r29, $r0, 0

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
            bne $r10, $r0, quick_restart

            # Load current serial input
            lw $r5, 2052($r0)

            # If its different from previous, process next frame
            bne $r5, $r4, tas_loop
            
            j wait_next_frame

quick_restart_setup:
    # address for reset tas
    # word addr
    addi $r11, $r0, 100

    # 0 1 1 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 1
    sra $r10, $r10, 8
    addi $r10, $r10, 1
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    
    sw $r10, 0($r11)

    # 0 16 0 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 16
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    
    sw $r10, 1($r11)

    # 0 1 0 32
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 1
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 32
    
    sw $r10, 2($r11)

    # 0 16 0 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 16
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    
    sw $r10, 3($r11)

    # 0 1 0 32
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 1
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 32
    
    sw $r10, 4($r11)

    # 0 16 0 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 16
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    
    sw $r10, 5($r11)

    # 0 1 128 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 1
    sra $r10, $r10, 8
    addi $r10, $r10, 128
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    
    sw $r10, 6($r11)

    # 0 16 0 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 16
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    
    sw $r10, 7($r11)

    # 0 1 128 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 1
    sra $r10, $r10, 8
    addi $r10, $r10, 128
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    
    sw $r10, 8($r11)

    # 0 16 0 0
    addi $r10, $r0, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 16
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    sra $r10, $r10, 8
    addi $r10, $r10, 0
    
    sw $r10, 9($r11)

    j $r31

quick_restart:
    # r19 is current input block 
    # r18 is frames held per block
    addi $r19, $r0, 0
    addi $r18, $r0, 0
    addi $r20, $r0, 10
    addi $r29, $r0, 0

    # read in initial serial
    lw $r4, 2052($r0)

    # wait for first frame
    j wait_next_frame

    reset_loop:
        # Get inputs for next frame

        # reset serial toggle
        add $r4, $r5, $r0

        # wait if there are more frames to hold 
        bne $r18, $r0, hold_inputs_reset

        # Load next input block
        lw $r29, 100($r19)

        # Shift hold count into r18
        sra $r18, $r29, 16

        # Increment input block counter
        addi $r19, $r19, 1
        addi $r20, $r20, -1

        hold_inputs_reset:
            addi $r18, $r18, -1

        bne $r20, $r0, wait_next_frame_reset

        j main

        wait_next_frame_reset:
            # Load current serial input
            lw $r5, 2052($r0)

            # If its different from previous, process next frame
            bne $r5, $r4, reset_loop
            
            j wait_next_frame_reset

tas_set_clock:
    # new input every 20833 cycles