/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // TAS mem
    address_rom,                    // O: The address of the data to get from rom
    q_rom,                          // I: The data from rom

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

    // TAS mem
    output [31:0] address_rom;
    input [31:0] q_rom;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

    wire writeEnable, stallFD;

    /* Stall Logic */
    assign writeEnable = !isMultDiv || multDivReady;

	/* FETCH */
    wire [31:0] pc, pcPlusOne, jumpTarget, pcNext, executeSXImmediate, branchFromPC, bexJumpTarget;
    wire isJumpI, isJumpII, takeBranch, flushFD, takeBEX;
    register32 PC(!clock, writeEnable && !stallFD, reset, pcNext, pc);

    assign address_imem = isJumpII ? bypassedA : pc;

    cla PCPlusOne(takeBranch ? branchFromPC : address_imem, takeBranch ? executeSXImmediate : 32'b0, !isJumpII, pcPlusOne);

    // Do this super early to avoid having to flush instructions when we don't need to
    assign jumpTarget = {{5{q_imem[26]}}, q_imem[26:0]};
    assign isJumpI = q_imem[31:29] == 3'b000 && q_imem[27];

    assign pcNext = takeBEX ? bexJumpTarget : ((isJumpI && !takeBranch) ? jumpTarget : pcPlusOne);

    // Latch
    wire [31:0] latchFD_PC, latchFD_IR;
    register32 LatchFD_PC(!clock, writeEnable && !stallFD, reset, address_imem, latchFD_PC);
    register32 LatchFD_IR(!clock, writeEnable && !stallFD, reset, flushFD ? 31'b0 : q_imem, latchFD_IR);

    /* DECODE */
    wire decodeBranch;
    assign decodeBranch = latchFD_IR[31:30] == 2'b00 && latchFD_IR[28:27] == 2'b10;
    // jr loads from $rd into A
    assign ctrl_readRegA = latchFD_IR[31:27] == 5'b10110 ? 5'd30 : (latchFD_IR[31:27] == 5'b00100 ? latchFD_IR[26:22] : latchFD_IR[21:17]);
    // sw and branches load from $rd into B
    assign ctrl_readRegB = (latchFD_IR[31:27] == 5'b00111 || decodeBranch) ? latchFD_IR[26:22] : latchFD_IR[16:12];

    // Latch
    wire [31:0] latchDX_PC, latchDX_IR, latchDX_A, latchDX_B;
    wire [4:0] latchDX_AReg, latchDX_BReg;
    register32 LatchDX_PC(!clock, writeEnable, reset, latchFD_PC, latchDX_PC);
    register32 LatchDX_IR(!clock, writeEnable, reset, (flushFD || stallFD) ? 31'b0 : latchFD_IR, latchDX_IR);
    register32 LatchDX_A(!clock, writeEnable, reset, data_readRegA, latchDX_A);
    register32 LatchDX_B(!clock, writeEnable, reset, data_readRegB, latchDX_B);
    register5 LatchDX_AReg(!clock, writeEnable, reset, ctrl_readRegA, latchDX_AReg);
    register5 LatchDX_BReg(!clock, writeEnable, reset, ctrl_readRegB, latchDX_BReg);

    /* EXECUTE */
    wire [31:0] aluResult, actualA, actualB, multDivResult, bypassedA, bypassedB, nonExceptionResult, exceptionCode, exceptionCodeMux;
    wire [4:0] aluOp, aluShamt, memoryWhichWriteReg;
    wire aluNE, aluLT, aluOverflow, executeIType, isMultDiv, multDivException, multDivReady, multSignal, divSignal, multDivSignal1, multDivSignal2, executeJAL,
        executeBranch, bltVsBne, memoryShouldWriteReg, executeBEX, hadException, exceptionMux;
    
    // Stall if load before using reg
    assign stallFD = latchDX_IR[31:28] == 4'b0100 &&
        (ctrl_readRegA == latchDX_IR[26:22] ||
        (ctrl_readRegB == latchDX_IR[26:22] && latchFD_IR[31:27] != 5'b00111));
    
    assign executeIType = latchDX_IR[31:28] == 4'b0100 || (latchDX_IR[31:29] == 3'b001 && latchDX_IR[27]);
    assign executeJAL = latchDX_IR[31:27] == 5'b00011;
    assign bltVsBne = latchDX_IR[29];
    assign executeBranch = latchDX_IR[31:30] == 2'b00 && latchDX_IR[28:27] == 2'b10;
    assign executeBEX = latchDX_IR[31:27] == 5'b10110;

    assign executeSXImmediate = {{15{latchDX_IR[16]}}, latchDX_IR[16:0]};

    // Bypass to replace occurrences of latchDX_A and latchDX_B if needed
    // MX and WX
    assign bypassedA = (memoryShouldWriteReg && memoryWhichWriteReg != 5'b0 && memoryWhichWriteReg == latchDX_AReg) ? latchXM_O : 
        ((writebackShouldWriteReg && ctrl_writeReg != 5'b0 && ctrl_writeReg == latchDX_AReg) ? data_writeReg : latchDX_A);
    assign bypassedB = (memoryShouldWriteReg && memoryWhichWriteReg != 5'b0 && memoryWhichWriteReg == latchDX_BReg) ? latchXM_O : 
        ((writebackShouldWriteReg && ctrl_writeReg != 5'b0 && ctrl_writeReg == latchDX_BReg) ? data_writeReg : latchDX_B);

    assign actualA = executeJAL ? latchDX_PC : bypassedA;
    assign actualB = executeBEX ? 32'b0 : (executeJAL ? 32'b1 : (executeIType ? executeSXImmediate : bypassedB));
    
    assign aluOp = executeBranch ? 5'b1 : ((executeIType || executeJAL || executeBEX) ? 5'b0 : latchDX_IR[6:2]); // FIXME? Should BEX make this 1?
    assign aluShamt = (executeIType || executeJAL || executeBranch || executeBEX) ? 5'b0 : latchDX_IR[11:7];
    alu ALU(actualA, actualB, aluOp, aluShamt, aluResult, aluNE, aluLT, aluOverflow);

    assign isJumpII = latchDX_IR[31:27] == 5'b00100;

    assign takeBranch = executeBranch && aluNE && (!aluLT || !bltVsBne);
    assign branchFromPC = latchDX_PC;
    assign takeBEX = executeBEX && aluNE;
    assign bexJumpTarget = {{5{latchDX_IR[26]}}, latchDX_IR[26:0]};
    assign flushFD = takeBranch || isJumpII;

    assign isMultDiv = latchDX_IR[31:27] == 5'b00000 && aluOp[4:1] == 4'b0011;
    assign multSignal = (isMultDiv && !aluOp[0]) && (!multDivSignal1 || !multDivSignal2) && !multDivReady;
    assign divSignal = (isMultDiv && aluOp[0]) && (!multDivSignal1 || !multDivSignal2) && !multDivReady;
    multdiv MultDiv(actualA, actualB, multSignal, divSignal, !clock && isMultDiv, multDivResult, multDivException, multDivReady);
    dffe_ref MultDivSignal1(multDivSignal1, !writeEnable, !clock, 1'b1, reset);
    dffe_ref MultDivSignal2(multDivSignal2, multDivSignal1, !clock, 1'b1, reset);

    mux4 ExceptionCodeMux(exceptionCodeMux, aluOp[1:0], 32'd1, 32'd3, 32'd4, 32'd5);
    assign exceptionCode = latchDX_IR[31:27] == 5'b00101 ? 32'd2 : exceptionCodeMux;
    mux8_1b ExceptionMux(exceptionMux, aluOp[2:0], aluOverflow, aluOverflow, 1'b0, 1'b0, 1'b0, 1'b0, multDivException, multDivException);
    assign hadException = (exceptionMux && latchDX_IR[31:27] == 5'b00000) || (latchDX_IR[31:27] == 5'b00101 && aluOverflow);

    assign nonExceptionResult = latchDX_IR[31:27] == 5'b10101 ? bexJumpTarget : (isMultDiv ? multDivResult : aluResult);

    // Latch
    wire [31:0] latchXM_IR, latchXM_O, latchXM_B;
    wire [4:0] latchXM_BReg;
    wire latchXM_Exception;
    register32 LatchXM_IR(!clock, writeEnable, reset, latchDX_IR, latchXM_IR);
    register32 LatchXM_O(!clock, writeEnable, reset, hadException ? exceptionCode : nonExceptionResult, latchXM_O);
    register32 LatchXM_B(!clock, writeEnable, reset, latchDX_B, latchXM_B);
    register5 LatchXM_BReg(!clock, writeEnable, reset, latchDX_BReg, latchXM_BReg);
    dffe_ref LatchXM_Exception(latchXM_Exception, hadException, !clock, writeEnable, reset);

    /* MEMORY */
    wire [31:0] memoryOutput, bypassedMemData;
    assign address_dmem = latchXM_O;
    assign address_rom = latchXM_O;

    // Bypass to replace occurrences of latchXM_B if needed
    // WM
    assign bypassedMemData = (writebackShouldWriteReg && ctrl_writeReg != 5'b0 && ctrl_writeReg == latchXM_BReg) ? data_writeReg : latchXM_B;

    assign data = bypassedMemData;
    assign wren = latchXM_IR[31:27] == 5'b00111;

    assign memoryOutput = latchXM_IR[31:28] == 4'b0100 ? (latchXM_IR[27] ? q_rom : q_dmem) : latchXM_O;

    //`define shouldWriteReg(IR) IR[31:27] == 5'b00000 || IR[31:27] == 5'b00101 || IR[31:27] == 5'b01000 || IR[31:27] == 5'b00011;
    //`define whichWriteReg(IR) IR[31:27] == 5'b00011 ? 5'd31 : IR[26:22];

    assign memoryShouldWriteReg = latchXM_Exception || latchXM_IR[31:27] == 5'b10101 || latchXM_IR[31:27] == 5'b00000 || latchXM_IR[31:27] == 5'b00101 || latchXM_IR[31:28] == 4'b0100 || latchXM_IR[31:27] == 5'b00011;
    assign memoryWhichWriteReg = (latchXM_Exception || latchXM_IR[31:27] == 5'b10101) ? 5'd30 : (latchXM_IR[31:27] == 5'b00011 ? 5'd31 : latchXM_IR[26:22]);

    //Latch
    wire [31:0] latchMW_IR, latchMW_O;
    wire latchMW_Exception;
    register32 LatchMW_IR(!clock, writeEnable, reset, latchXM_IR, latchMW_IR);
    register32 LatchMW_O(!clock, writeEnable, reset, memoryOutput, latchMW_O);
    dffe_ref LatchMW_Exception(latchMW_Exception, latchXM_Exception, !clock, writeEnable, reset);

    /* WRITEBACK */
    wire writebackShouldWriteReg;
    assign writebackShouldWriteReg = latchMW_Exception || latchMW_IR[31:27] == 5'b10101 || latchMW_IR[31:27] == 5'b00000 || latchMW_IR[31:27] == 5'b00101 || latchMW_IR[31:28] == 4'b0100 || latchMW_IR[31:27] == 5'b00011;
    assign ctrl_writeEnable = writeEnable && writebackShouldWriteReg;
    // jal writes specifically to r31, and setx writes to r30
    assign ctrl_writeReg = (latchMW_Exception || latchMW_IR[31:27] == 5'b10101) ? 5'd30 : (latchMW_IR[31:27] == 5'b00011 ? 5'd31 : latchMW_IR[26:22]);
    assign data_writeReg = latchMW_O;

endmodule
