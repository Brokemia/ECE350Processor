module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB, data_r29
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB, data_r29;

	wire [31:0] writeSelect, readSelectA, readSelectB;
	wire [31:0] regOut[0:31];

	decoder32 WriteSelect(writeSelect, ctrl_writeReg, ctrl_writeEnable);
	decoder32 ReadSelectA(readSelectA, ctrl_readRegA, 1'b1);
	decoder32 ReadSelectB(readSelectB, ctrl_readRegB, 1'b1);

	assign regOut[0] = 32'b0;
	genvar i;
	generate
		for(i = 1; i < 32; i = i + 1) begin
			register32 Reg(
				.clock(clock),
				.writeEnable(writeSelect[i]),
				.reset(ctrl_reset),
				.data(data_writeReg),
				.out(regOut[i])
			);
		end
		for(i = 0; i < 32; i = i + 1) begin
			tristate32 ReadA(
				.out(data_readRegA),
				.enable(readSelectA[i]),
				.in(regOut[i])
			);
			tristate32 ReadB(
				.out(data_readRegB),
				.enable(readSelectB[i]),
				.in(regOut[i])
			);
		end
	endgenerate

	assign data_r29 = regOut[29];
endmodule
