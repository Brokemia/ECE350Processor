module ShiftLeftLogical(Out, In, Shift);
    input [31:0] In;
    input [4:0] Shift;

    output [31:0] Out;

    wire [31:0] Shifted1, Shifted2, Shifted4, Shifted8;

    assign Shifted1 = Shift[0] ? {In[30:0], 1'b0} : In;
    assign Shifted2 = Shift[1] ? {Shifted1[29:0], 2'b00} : Shifted1;
    assign Shifted4 = Shift[2] ? {Shifted2[27:0], 4'b0000} : Shifted2;
    assign Shifted8 = Shift[3] ? {Shifted4[23:0], 8'b00000000} : Shifted4;
    assign Out = Shift[4] ? {Shifted8[15:0], 16'b0000000000000000} : Shifted8;
endmodule

module ShiftRightArithmetic(Out, In, Shift);
    input [31:0] In;
    input [4:0] Shift;

    output [31:0] Out;

    wire [31:0] Shifted1, Shifted2, Shifted4, Shifted8;

    assign Shifted1 = Shift[0] ? {In[31], In[31:1]} : In;
    assign Shifted2 = Shift[1] ? {{2{Shifted1[31]}}, Shifted1[31:2]} : Shifted1;
    assign Shifted4 = Shift[2] ? {{4{Shifted2[31]}}, Shifted2[31:4]} : Shifted2;
    assign Shifted8 = Shift[3] ? {{8{Shifted4[31]}}, Shifted4[31:8]} : Shifted4;
    assign Out = Shift[4] ? {{16{Shifted8[31]}}, Shifted8[31:16]} : Shifted8;
endmodule