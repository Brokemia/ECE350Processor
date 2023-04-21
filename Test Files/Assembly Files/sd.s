# $r6, $r7, $r8, $r9 are my parameter passers
# r3 r5 is the return register
# r1 is current value of toggle bit 
# r2 is next frame
# r15-20 are scratch work
j main

wait:  
    # r6 has number of cycles to wait,
    # will mutate r6, 
    # r6 must be at least one

    addi $r6, $r0, -1
    bne $r6, $r0, wait
    jr $r31

prime_cmd:
    addi $r6, $r0, 512
    sw $r0, 2051($r0)
    sw $r0, 2050($r0)
    jr $r31

set_toggle_bit:
    lw $r1, 2049($r0)
    sra $r1, $r1, 31
    jr $r31


send_cmd:
    # r6 is cmd
    # r8 is args
    # r7 is crc 
    # first two addr 2051
    # second four addr 2050

    #set what the current toggle bit is
    sw $r31, 100($r0)
    jal set_toggle_bit
    lw $r31, 100($r0)

    ## Setting the bottom four bytes of the SD command
    # get bottom 24 bits of args into the top 24 space
    sll $r16, $r8, 8

    # set bottom bit of crc to 1
    addi $r15, $r0, 1
    or $r7, $r7, $r15

    or $r7, $r7, $r16 #combine and save
    sw $r7, 2050($r0)

    ## Setting and Sending the Top two bytes of the SD COMMAND
    # get top 8 bits of args
    sra $r16, $r8, 24
    addi $r15, $r0, 255
    and $r16, $r16, $r15 #mask off top 24
    
    addi $r15, $r0, 64 # set transmission bit 6th bit is set to one
    or $r6, $r6, $r15
    sll $r6, $r6, 8 # shift trans bit and cmd index up eight
    or $r6, $r6, $r16 # combine command index with top 8 bits of args

    addi $r15, $r0, 1 #set the top bit
    sll $r15, $r15, 31
    or $r6, $r6, $r15    

    sw $r6, 2051($r0)
    
    jr $r31

get_next_byte:
    # if toggle bit is different, read in the new data
    lw $r6, 2049($r0)
    sra $r6, $r6, 31
    bne $r1, $r6, read_data
    j get_next_byte

    read_data:
        #read the byte into r5
        sll $r5, $r6, 1
        sra $r5, $r5, 1

        #set toggle to current
        add $r1, $r6, $r0
    
    # TEST
    addi $r17, $r0, 12
    addi $r18, $r0, 213
    addi $r29, $r0, 1023
    test:
    nop
    bne $r17, $r18, test

    jr $31

get_r7_r3_response:
    # the r1 response byte will be in $r3
    # the other four bytes will be in $r5
    sw $r31, 200($r0)
    
    jal get_next_byte
    add $r3, $r0, $r5

    jal get_next_byte
    add $r15, $r5, $r0
    sll $r15, $r15, 8

    jal get_next_byte
    add $r15, $r5, $r15
    sll $r15, $r15, 8

    jal get_next_byte
    add $r15, $r5, $r15
    sll $r15, $r15, 8

    jal get_next_byte
    add $r5, $r5, $r15

    lw $r31, 200($r0)
    jr $r31

main:
    ## Start of SPI with SD Card

    # set r6 and r7 to be cmd0
    addi $r7, $r0, 148
    addi $r6, $r0, 0
    addi $r8, $r0, 0
    jal send_cmd

    jal get_next_byte


    # send cmd8
    addi $r6, $r0, 8
    addi $r8, $r0, 426
    addi $r7, $r0, 134
    jal send_cmd

    addi $r6, $r0, 4096
    jal wait

    # send cmd58
    addi $r6, $r0, 58
    addi $r8, $r0, 0
    addi $r7, $r0, 0
    jal send_cmd

    addi $r6, $r0, 4096
    jal wait

    addi $r4, $r0, 100

    init_loop:
        addi $r4, $r4, -1

        # send cmd55
        addi $r6, $r0, 55
        addi $r8, $r0, 0
        addi $r7, $r0, 0
        jal send_cmd

        addi $r6, $r0, 4096
        jal wait

        # send cmd41
        addi $r6, $r0, 41
        addi $r8, $r0, 1
        sll $r8, $r8, 30
        addi $r7, $r0, 0
        jal send_cmd

        bne $r4, $r0, init_loop

    ## You can now read and write from the SD card!

    # Send cmd 17 to request read
    addi $r6, $r0, 17
    addi $r8, $r0, 0
    addi $r7, $r0, 0
    jal send_cmd

    # Get first/response byte
    jal get_next_byte

    # Loop to get the next 512
    addi $r17, $r0, 512
    read_loop:
        jal get_next_byte
        # store r5 
        addi $r17, $r17, -1
        bne $r17, $r0, read_loop

    # Get last two crc bytes
    #   or don't I'm not your dad


tas:
    #r19 is current offset 
    addi $r19, $r0, 0

    tas_loop:
        lw_rom $r29, 0($r19)
        addi $r19, $r19, 1

        debug_next:
            lw $r5, 2052($r0)
            bne $r5, $r0, tas_loop
            j debug_next


check_serial:
    addi $r6, $r0, 200
    sw $r6, 2052($r0)

    serial_success:
        lw $r5, 200($r0)
        bne $r5, $r0, we_did_it
        j serial_success

    we_did_it:
        addi $r29 $r0 1023

    the_loop:
        bne $r29, $r5, the_loop
