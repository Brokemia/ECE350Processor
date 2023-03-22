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

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

    wire writeEnable;

    /* Stall Logic */
    assign writeEnable = !isMultDiv || multDivReady;

	/* FETCH */
    wire [31:0] pc, pcPlusOne, jumpTarget, pcNext;
    wire isJumpI;
    register32 PC(!clock, writeEnable, reset, pcNext, pc);

    assign address_imem = isJumpII ? data_readRegA : pc;

    cla PCPlusOne(address_imem, takeBranch ? executeSXImmediate : 32'b0, 1'b1, pcPlusOne);

    // Do this super early to avoid having to flush instructions when we don't need to
    assign jumpTarget = {{5{q_imem[26]}}, q_imem[26:0]};
    assign isJumpI = q_imem[31:29] == 3'b000 && q_imem[27];

    assign pcNext = isJumpI ? jumpTarget : pcPlusOne;

    // Latch
    wire [31:0] latchFD_PC, latchFD_IR;
    wire isJumpII;
    register32 LatchFD_PC(!clock, writeEnable, reset, address_imem, latchFD_PC);
    register32 LatchFD_IR(!clock, writeEnable, reset, q_imem, latchFD_IR);

    /* DECODE */
    wire decodeBranch;
    assign decodeBranch = latchFD_IR[31:30] == 2'b00 && latchFD_IR[28:27] == 2'b10;
    // jr loads from $rd into A
    assign ctrl_readRegA = latchFD_IR[31:27] == 5'b00100 ? latchFD_IR[26:22] : latchFD_IR[21:17];
    // sw and branches load from $rd into B
    assign ctrl_readRegB = (latchFD_IR[31:27] == 5'b00111 || decodeBranch) ? latchFD_IR[26:22] : latchFD_IR[16:12];

    assign isJumpII = latchFD_IR[31:27] == 5'b00100;

    // Latch
    wire [31:0] latchDX_PC, latchDX_IR, latchDX_A, latchDX_B;
    register32 LatchDX_PC(!clock, writeEnable, reset, latchFD_PC, latchDX_PC);
    register32 LatchDX_IR(!clock, writeEnable, reset, latchFD_IR, latchDX_IR);
    register32 LatchDX_A(!clock, writeEnable, reset, data_readRegA, latchDX_A);
    register32 LatchDX_B(!clock, writeEnable, reset, data_readRegB, latchDX_B);

    /* EXECUTE */
    wire [31:0] aluResult, actualA, actualB, multDivResult, executeSXImmediate;
    wire [4:0] aluOp, aluShamt;
    wire aluNE, aluLT, aluOverflow, executeIType, isALUOp, isMultDiv, multDivException, multDivReady, multSignal, divSignal, multDivStalling, executeJAL,
        executeBranch, bltVsBne;
    assign isALUOp = latchDX_IR[31:27] == 5'b00000 || latchDX_IR[31:27] == 5'b00101;
    assign executeIType = latchDX_IR[31:27] == 5'b01000 || (latchDX_IR[31:29] == 3'b001 && latchDX_IR[27]);
    assign executeJAL = latchDX_IR[31:27] == 5'b00011;
    assign bltVsBne = latchDX_IR[29];
    assign executeBranch = latchDX_IR[31:30] == 2'b00 && latchDX_IR[28:27] == 2'b10;

    assign executeSXImmediate = {{15{latchDX_IR[16]}}, latchDX_IR[16:0]};

    assign actualA = executeJAL ? latchDX_PC : latchDX_A;
    assign actualB = executeJAL ? 32'b1 : (executeIType ? executeSXImmediate : latchDX_B);
    
    assign aluOp = executeBranch ? 5'b1 : ((executeIType || executeJAL) ? 5'b0 : latchDX_IR[6:2]);
    assign aluShamt = (executeIType || executeJAL || executeBranch) ? 5'b0 : latchDX_IR[11:7];
    alu ALU(actualA, actualB, aluOp, aluShamt, aluResult, aluNE, aluLT, aluOverflow);

    assign takeBranch = (bltVsBne && !aluLT) || (!bltVsBne && aluNE);

    assign isMultDiv = isALUOp && aluOp[4:1] == 4'b0011;
    assign multSignal = (isMultDiv && !aluOp[0]) && !multDivStalling && !multDivReady;
    assign divSignal = (isMultDiv && aluOp[0]) && !multDivStalling && !multDivReady;
    multdiv MultDiv(latchDX_A, actualB, multSignal, divSignal, !clock && isMultDiv, multDivResult, multDivException, multDivReady);
    dffe_ref MultDivStalling(multDivStalling, !writeEnable, !clock, 1'b1, reset);

    // Latch
    wire [31:0] latchXM_IR, latchXM_O, latchXM_B;
    register32 LatchXM_IR(!clock, writeEnable, reset, latchDX_IR, latchXM_IR);
    register32 LatchXM_O(!clock, writeEnable, reset, isMultDiv ? multDivResult : aluResult, latchXM_O);
    register32 LatchXM_B(!clock, writeEnable, reset, latchDX_B, latchXM_B);

    /* MEMORY */
    wire [31:0] memoryOutput;
    assign address_dmem = latchXM_O;
    assign data = latchXM_B;
    assign wren = latchXM_IR[31:27] == 5'b00111;

    assign memoryOutput = latchXM_IR[31:27] == 5'b01000 ? q_dmem : latchXM_O;

    //Latch
    wire [31:0] latchMW_IR, latchMW_O;
    register32 LatchMW_IR(!clock, writeEnable, reset, latchXM_IR, latchMW_IR);
    register32 LatchMW_O(!clock, writeEnable, reset, memoryOutput, latchMW_O);

    /* WRITEBACK */
    wire writeToReg, writebackJAL;
    assign writebackJAL = latchMW_IR[31:27] == 5'b00011;
    assign writeToReg = latchMW_IR[31:27] == 5'b00000 || latchMW_IR[31:27] == 5'b00101 || latchMW_IR[31:27] == 5'b01000 || writebackJAL;
    assign ctrl_writeEnable = writeEnable && writeToReg;
    // jal writes specifically to r31
    assign ctrl_writeReg = writebackJAL ? 5'd31 : latchMW_IR[26:22];
    assign data_writeReg = latchMW_O;

endmodule
