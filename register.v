module register5(clock, writeEnable, reset, data, out);
	input clock, writeEnable, reset;
	input [4:0] data;

	output [4:0] out;

	genvar i;
	generate
		for(i = 0; i < 5; i = i + 1) begin
			dffe_ref RegBit(
				.q(out[i]),
				.d(data[i]),
				.clk(clock),
				.en(writeEnable),
				.clr(reset)
			);
		end
	endgenerate
endmodule

module register32(clock, writeEnable, reset, data, out);
	input clock, writeEnable, reset;
	input [31:0] data;

	output [31:0] out;

	genvar i;
	generate
		for(i = 0; i < 32; i = i + 1) begin
			dffe_ref RegBit(
				.q(out[i]),
				.d(data[i]),
				.clk(clock),
				.en(writeEnable),
				.clr(reset)
			);
		end
	endgenerate
endmodule

module register64(clock, writeEnable, reset, data, out);
	input clock, writeEnable, reset;
	input [63:0] data;

	output [63:0] out;

	genvar i;
	generate
		for(i = 0; i < 64; i = i + 1) begin
			dffe_ref RegBit(
				.q(out[i]),
				.d(data[i]),
				.clk(clock),
				.en(writeEnable),
				.clr(reset)
			);
		end
	endgenerate
endmodule