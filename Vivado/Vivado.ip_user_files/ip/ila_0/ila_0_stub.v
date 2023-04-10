// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Mon Apr 10 16:02:18 2023
// Host        : DESKTOP-VN8895K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/rrwth/OneDrive/Documents/College/ECE350/Checkpoints/processor/Vivado/Vivado.srcs/sources_1/ip/ila_0/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2020.1" *)
module ila_0(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7, probe8, probe9)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[7:0],probe1[0:0],probe2[47:0],probe3[0:0],probe4[0:0],probe5[7:0],probe6[11:0],probe7[31:0],probe8[31:0],probe9[0:0]" */;
  input clk;
  input [7:0]probe0;
  input [0:0]probe1;
  input [47:0]probe2;
  input [0:0]probe3;
  input [0:0]probe4;
  input [7:0]probe5;
  input [11:0]probe6;
  input [31:0]probe7;
  input [31:0]probe8;
  input [0:0]probe9;
endmodule
