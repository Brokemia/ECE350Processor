module cla(A, B, Cin, S);
    input [31:0] A, B;
    input Cin;
    output [31:0] S;

    wire [3:0] P, G;
    wire C8_0, C16_0, C16_1, C24_0, C24_1, C24_2, Cout_0, Cout_1, Cout_2, Cout_3;
    wire C8, C16, C24;
    
    cla_block block1(A[7:0], B[7:0], Cin, S[7:0], P[0], G[0]);
    
    and C8_0Calc(C8_0, P[0], Cin);
    or C8Calc(C8, G[0], C8_0);
    cla_block block2(A[15:8], B[15:8], C8, S[15:8], P[1], G[1]);

    and C16_0Calc(C16_0, P[1], P[0], Cin);
    and C16_1Calc(C16_1, P[1], G[0]);
    or C16Calc(C16, G[1], C16_0, C16_1);
    cla_block block3(A[23:16], B[23:16], C16, S[23:16], P[2], G[2]);

    and C24_0Calc(C24_0, P[2], P[1], P[0], Cin);
    and C24_1Calc(C24_1, P[2], P[1], G[0]);
    and C24_2Calc(C24_2, P[2], G[1]);
    or C24Calc(C24, G[2], C24_0, C24_1, C24_2);
    cla_block block4(A[31:24], B[31:24], C24, S[31:24], P[3], G[3]);

    // and Cout_0Calc(Cout_0, P[3], P[2], P[1], P[0], Cin);
    // and Cout_1Calc(Cout_1, P[3], P[2], P[1], G[0]);
    // and Cout_2Calc(Cout_2, P[3], P[2], G[1]);
    // and Cout_3Calc(Cout_3, P[3], G[2]);
    // or CoutCalc(Cout, G[3], Cout_0, Cout_1, Cout_2, Cout_3);
endmodule

module cla_block(A, B, Cin, S, Pout, Gout);
    input [7:0] A, B;
    input Cin;
    output [7:0] S;
    output Pout, Gout;

    wire [7:0] P, G;
    wire C1_0, C2_0, C2_1, C3_0, C3_1, C3_2, C4_0, C4_1, C4_2, C4_3, C5_0, C5_1, C5_2, C5_3, C5_4, C6_0, C6_1, C6_2, C6_3, C6_4, C6_5, C7_0, C7_1, C7_2, C7_3, C7_4, C7_5, C7_6;
    wire Gout_1, Gout_2, Gout_3, Gout_4, Gout_5, Gout_6, Gout_7;
    wire [7:1] C;

    or P0(P[0], A[0], B[0]);
    or P1(P[1], A[1], B[1]);
    or P2(P[2], A[2], B[2]);
    or P3(P[3], A[3], B[3]);
    or P4(P[4], A[4], B[4]);
    or P5(P[5], A[5], B[5]);
    or P6(P[6], A[6], B[6]);
    or P7(P[7], A[7], B[7]);

    and G0(G[0], A[0], B[0]);
    and G1(G[1], A[1], B[1]);
    and G2(G[2], A[2], B[2]);
    and G3(G[3], A[3], B[3]);
    and G4(G[4], A[4], B[4]);
    and G5(G[5], A[5], B[5]);
    and G6(G[6], A[6], B[6]);
    and G7(G[7], A[7], B[7]);

    xor Sum0(S[0], A[0], B[0], Cin);
    
    and C1_0Calc(C1_0, P[0], Cin);
    or C1(C[1], G[0], C1_0);
    xor Sum1(S[1], A[1], B[1], C[1]);

    and C2_0Calc(C2_0, P[1], P[0], Cin);
    and C2_1Calc(C2_1, P[1], G[0]);
    or C2(C[2], G[1], C2_0, C2_1);
    xor Sum2(S[2], A[2], B[2], C[2]);

    and C3_0Calc(C3_0, P[2], P[1], P[0], Cin);
    and C3_1Calc(C3_1, P[2], P[1], G[0]);
    and C3_2Calc(C3_2, P[2], G[1]);
    or C3(C[3], G[2], C3_0, C3_1, C3_2);
    xor(S[3], A[3], B[3], C[3]);

    and C4_0Calc(C4_0, P[3], P[2], P[1], P[0], Cin);
    and C4_1Calc(C4_1, P[3], P[2], P[1], G[0]);
    and C4_2Calc(C4_2, P[3], P[2], G[1]);
    and C4_3Calc(C4_3, P[3], G[2]);
    or C4(C[4], G[3], C4_0, C4_1, C4_2, C4_3);
    xor(S[4], A[4], B[4], C[4]);

    and C5_0Calc(C5_0, P[4], P[3], P[2], P[1], P[0], Cin);
    and C5_1Calc(C5_1, P[4], P[3], P[2], P[1], G[0]);
    and C5_2Calc(C5_2, P[4], P[3], P[2], G[1]);
    and C5_3Calc(C5_3, P[4], P[3], G[2]);
    and C5_4Calc(C5_4, P[4], G[3]);
    or C5(C[5], G[4], C5_0, C5_1, C5_2, C5_3, C5_4);
    xor(S[5], A[5], B[5], C[5]);

    and C6_0Calc(C6_0, P[5], P[4], P[3], P[2], P[1], P[0], Cin);
    and C6_1Calc(C6_1, P[5], P[4], P[3], P[2], P[1], G[0]);
    and C6_2Calc(C6_2, P[5], P[4], P[3], P[2], G[1]);
    and C6_3Calc(C6_3, P[5], P[4], P[3], G[2]);
    and C6_4Calc(C6_4, P[5], P[4], G[3]);
    and C6_5Calc(C6_5, P[5], G[4]);
    or C6(C[6], G[5], C6_0, C6_1, C6_2, C6_3, C6_4, C6_5);
    xor(S[6], A[6], B[6], C[6]);

    and C7_0Calc(C7_0, P[6], P[5], P[4], P[3], P[2], P[1], P[0], Cin);
    and C7_1Calc(C7_1, P[6], P[5], P[4], P[3], P[2], P[1], G[0]);
    and C7_2Calc(C7_2, P[6], P[5], P[4], P[3], P[2], G[1]);
    and C7_3Calc(C7_3, P[6], P[5], P[4], P[3], G[2]);
    and C7_4Calc(C7_4, P[6], P[5], P[4], G[3]);
    and C7_5Calc(C7_5, P[6], P[5], G[4]);
    and C7_6Calc(C7_6, P[6], G[5]);
    or C7(C[7], G[6], C7_0, C7_1, C7_2, C7_3, C7_4, C7_5, C7_6);
    xor(S[7], A[7], B[7], C[7]);

    // Calculate Pout and Gout
    and PoutCalc(Pout, P[7], P[6], P[5], P[4], P[3], P[2], P[1], P[0]);
    and Gout_1Calc(Gout_1, P[7], P[6], P[5], P[4], P[3], P[2], P[1], G[0]);
    and Gout_2Calc(Gout_2, P[7], P[6], P[5], P[4], P[3], P[2], G[1]);
    and Gout_3Calc(Gout_3, P[7], P[6], P[5], P[4], P[3], G[2]);
    and Gout_4Calc(Gout_4, P[7], P[6], P[5], P[4], G[3]);
    and Gout_5Calc(Gout_5, P[7], P[6], P[5], G[4]);
    and Gout_6Calc(Gout_6, P[7], P[6], G[5]);
    and Gout_7Calc(Gout_7, P[7], G[6]);
    or GoutCalc(Gout, G[7], Gout_1, Gout_2, Gout_3, Gout_4, Gout_5, Gout_6, Gout_7);
endmodule