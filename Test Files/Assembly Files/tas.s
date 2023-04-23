main:
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
            # Load current serial input
            lw $r5, 2052($r0)

            # If its different from previous, process next frame
            bne $r5, $r4, tas_loop
            
            j wait_next_frame