module not32(out, in);
    input [31:0] in;
    output [31:0] out;
    generate
        for(genvar i = 0; i < 32; i = i + 1) begin
            not Not(out[i], in[i]);
        end
    endgenerate
endmodule