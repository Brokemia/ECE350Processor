# $r6, $r7, $r8, $r9 are my parameter passers
# r5 is the return register
# r15-20 are scratch work


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


send_cmd:
    # r7 has first 
    # r6 is crc
    # r8 is args
    # first two addr 2050
    # second four addr 2051

    # get top 8 bits of args
    sra $r16, $r8, 24
    addi $r15, $r0, 255
    and $r16, $r16, $r15 #mask off top 24

    addi $r15, $r0, 1 # set bottom bit to one
    or $r6, $r6, $r15
    sll $r6, $r6, 8 # if upper eight of arg becomes important and them below this line
    or $r6, $r6, $r16 # combine command index with top 

    sw $r6, 2051($r0)
    
    # get bottom 24 bits of args
    sll $r16, $r8, 8
    addi $r15, $r0, 4294967040
    and $r16, $r16, $r15 # mask off bottom 8

    addi $r15, $r0, 2147483712 #set the top bit and the first two as well so it will send
    or $r7, $r7, $r15
    or $r7, $r7, $r16
    sw $r7, 2050($r0)
    
    jr $r31

# get_response:


## Start of SPI with SD Card

# set r6 and r7 to be cmd0
addi $r7, $r0, 148
addi $r6, $r0, 0
addi $r8, $r0, 0
jal send_cmd


addi $r6, $r0, 4096
jal wait

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
    addi $r8, $r0, 1073741824
    addi $r7, $r0, 0
    jal send_cmd

    bne $r4, $r0, init_loop

