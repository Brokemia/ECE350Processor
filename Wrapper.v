`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (clk, rst, JA, JB, BTN, SD, LED, serialIn, serialOut, SW);
	input clk, rst, serialIn;
	output serialOut;
	input [4:0] BTN;
	output [7:0] JA, JB;
	inout [7:0] SD;
	output [15:0] LED;
	input [15:0] SW;

	wire rwe, mwe, reset, writeRAM;
	reg clock = 1'b0;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, romAddr, romData,
		rData, regA, regB,
		memAddr, memDataIn, memDataOut, RAMDataOut;

	assign reset = !rst; // The reset button on the FPGA is inverted for some reason

	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "program";
	localparam TAS_FILE_1 = "1A";
	localparam TAS_FILE_2 = "1B";
	localparam TAS_FILE_3 = "1C";
	localparam TAS_FILE_4 = "2A";
	localparam TAS_FILE_5 = "2C";
	localparam TAS_FILE_6 = "4A";
	localparam TAS_FILE_7 = "1A";
	localparam TAS_FILE_8 = "8C";
	
	wire [31:0] PC;
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),

		// TAS ROM
		.address_rom(romAddr), .q_rom(romData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut),
		
		.PC_dbg(PC)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));

	// TAS Memory (ROM)
	wire [31:0] roms[0:7];
	assign romData = roms[SW[2:0]];

	ROM #(.DATA_WIDTH(32), .MEMFILE({TAS_FILE_1, ".mem"}))
	TASMem1(.clk(clock), 
		.addr(romAddr[11:0]), 
		.dataOut(roms[0]));

	ROM #(.DATA_WIDTH(32), .MEMFILE({TAS_FILE_2, ".mem"}))
	TASMem2(.clk(clock), 
		.addr(romAddr[11:0]), 
		.dataOut(roms[1]));

	ROM #(.DATA_WIDTH(32), .MEMFILE({TAS_FILE_3, ".mem"}))
	TASMem3(.clk(clock), 
		.addr(romAddr[11:0]), 
		.dataOut(roms[2]));

	ROM #(.DATA_WIDTH(32), .MEMFILE({TAS_FILE_4, ".mem"}))
	TASMem4(.clk(clock), 
		.addr(romAddr[11:0]), 
		.dataOut(roms[3]));

	ROM #(.DATA_WIDTH(32), .MEMFILE({TAS_FILE_5, ".mem"}))
	TASMem5(.clk(clock), 
		.addr(romAddr[11:0]), 
		.dataOut(roms[4]));

	ROM #(.DATA_WIDTH(32), .MEMFILE({TAS_FILE_6, ".mem"}))
	TASMem6(.clk(clock), 
		.addr(romAddr[11:0]), 
		.dataOut(roms[5]));

	ROM #(.DATA_WIDTH(32), .MEMFILE({TAS_FILE_7, ".mem"}))
	TASMem7(.clk(clock), 
		.addr(romAddr[11:0]), 
		.dataOut(roms[6]));

	ROM #(.DATA_WIDTH(32), .MEMFILE({TAS_FILE_8, ".mem"}))
	TASMem8(.clk(clock), 
		.addr(romAddr[11:0]), 
		.dataOut(roms[7]));
	
	
	wire [31:0] data_r29;
	assign JB = { data_r29[0], data_r29[1], data_r29[2], data_r29[3], data_r29[4], data_r29[5], data_r29[6], data_r29[7] };
	assign JA = { data_r29[8], data_r29[9], data_r29[10], data_r29[11], data_r29[12], data_r29[13], data_r29[14], data_r29[15] };

	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
		.data_r29(data_r29));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(writeRAM), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(RAMDataOut),
		.wEn2(UART_writeEnable),
		.addr2(UART_writeAddr),
		.dataIn2(UART_writeData));

	reg SD_clk;
	// SD clock is 512 times slower than the main clock
	// Probably
	reg [7:0] SD_clkCnt;
	always @(posedge clk) begin
		SD_clkCnt <= SD_clkCnt + 1;
		if (SD_clkCnt == 0) begin
			SD_clk <= ~SD_clk;
		end
		if(SD_clkCnt[1] && SD_clkCnt[0]) begin
			clock <= ~clock;
		end
	end
	
	wire [47:0] SD_cmd;
	wire [7:0] SD_response;
	wire SD_start, SD_responseByte;
	SDController SDModule(SD, SD_clk, SD_cmd, SD_start, SD_responseByte, SD_response);

	wire [7:0] UART_lastByte;
	//UART SerialModule(clk, serialIn, serialOut, UART_setAddr, UART_startAddr, UART_err, UART_writeAddr, UART_writeData, UART_writeEnable);
	UART_simple SerialModule(clk, serialIn, serialOut, UART_err, UART_lastByte);

	MemoryMap MemMap(clock, memAddr[11:0], memDataIn, memDataOut, mwe,
		RAMDataOut, writeRAM, BTN, SD_responseByte, SD_response, SD_cmd, SD_start, UART_setAddr, UART_startAddr, UART_lastByte);

	// Better Debugger
	assign LED[15:0] = { JA[0], JA[1], JA[2], JA[3], JA[4], JA[5], JA[6], JA[7], JB[0], JB[1], JB[2], JB[3], JB[4], JB[5], JB[6], JB[7] };

	// Error LED
	//assign LED[0] = UART_err;

	// Debugger
	//ila_0 debugger(clk, SD, SD_clk, SD_cmd, SD_start, SD_responseByte, SD_response, memAddr[11:0], memDataIn, memDataOut, mwe, clock);
	ila_1 debugger(clk, clock, serialIn, serialOut, UART_writeAddr, PC, memAddr[11:0], memDataIn, memDataOut, mwe, UART_lastByte);
endmodule
