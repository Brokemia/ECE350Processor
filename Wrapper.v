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

module Wrapper (clk, rst, JA, BTN, SD, LED);
	input clk, rst;
	input [4:0] BTN;
	output [7:0] JA;
	inout [7:0] SD;
	output [15:0] LED;

	wire rwe, mwe, reset, writeRAM;
	reg clock = 1'b0;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut, RAMDataOut;

	assign reset = !rst; // The reset button on the FPGA is inverted for some reason

	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "program";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	wire [31:0] data_r29;
	assign JA = data_r29[7:0];

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
		.dataOut(RAMDataOut));

	reg SD_clk;
	// SD clock is 512 times slower than the main clock
	// Probably
	reg [/*7*/4:0] SD_clkCnt;
	always @(posedge BTN[2]) begin
		SD_clkCnt <= SD_clkCnt + 1;
		if (SD_clkCnt == 0) begin
			SD_clk <= ~SD_clk;
		end
		//if(SD_clkCnt[2]) begin
			clock <= ~clock;
		//end
	end
	
	wire [47:0] SD_cmd;
	wire [7:0] SD_response;
	wire SD_start, SD_responseByte;
	SDController SDModule(SD, SD_clk, SD_cmd, SD_start, SD_responseByte, SD_response);

	MemoryMap MemMap(memAddr[11:0], memDataIn, memDataOut, mwe,
		RAMDataOut, writeRAM, BTN, SD_responseByte, SD_response, SD_cmd, SD_start);

	// Better Debugger
	assign LED = { SD, SD_cmd[47:40] };

	// Debugger
	ila_0 debugger(clk, SD, SD_clk, SD_cmd, SD_start, SD_responseByte, SD_response, memAddr[11:0], memDataIn, memDataOut, mwe);
endmodule
