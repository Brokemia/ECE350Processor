module mux2(out, select, in0, in1);
    input select;
    input [31:0] in0, in1;
    output [31:0] out;
    assign out = select ? in1 : in0;
endmodule

module mux2_1b(out, select, in0, in1);
    input select;
    input in0, in1;
    output out;
    assign out = select ? in1 : in0;
endmodule

module mux4(out, select, in0, in1, in2, in3);
    input [1:0] select;
    input [31:0] in0, in1, in2, in3;
    output [31:0] out;
    wire [31:0] w1, w2;

    mux2 mux_01(w1, select[0], in0, in1);
    mux2 mux_23(w2, select[0], in2, in3);
    mux2 mux_final(out, select[1], w1, w2);
endmodule

module mux4_1b(out, select, in0, in1, in2, in3);
    input [1:0] select;
    input in0, in1, in2, in3;
    output out;
    wire w1, w2;

    mux2_1b mux_01(w1, select[0], in0, in1);
    mux2_1b mux_23(w2, select[0], in2, in3);
    mux2_1b mux_final(out, select[1], w1, w2);
endmodule

module mux8(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
    input [2:0] select;
    input [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
    output [31:0] out;
    wire [31:0] w1, w2;

    mux4 mux_0123(w1, select[1:0], in0, in1, in2, in3);
    mux4 mux_4567(w2, select[1:0], in4, in5, in6, in7);
    mux2 mux_final(out, select[2], w1, w2);
endmodule

module mux8_1b(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
    input [2:0] select;
    input in0, in1, in2, in3, in4, in5, in6, in7;
    output out;
    wire w1, w2;

    mux4_1b mux_0123(w1, select[1:0], in0, in1, in2, in3);
    mux4_1b mux_4567(w2, select[1:0], in4, in5, in6, in7);
    mux2_1b mux_final(out, select[2], w1, w2);
endmodule