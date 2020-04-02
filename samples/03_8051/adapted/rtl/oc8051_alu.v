//////////////////////////////////////////////////////////////////////
////                                                                   ////
//// alu for 8051 Core                                                   ////
////                                                                   ////
//// This file is part of the 8051 cores project                   ////
//// http://www.opencores.org/cores/8051/                           ////
////                                                                   ////
//// Description                                                   ////
//// Implementation of aritmetic unit  according to                   ////
//// 8051 IP core specification document. Uses divide.v and           ////
//// multiply.v                                                          ////
////                                                                   ////
//// To Do:                                                           ////
////  pc signed add                                               ////
////                                                                   ////
//// Author(s):                                                   ////
//// - Simon Teran, simont@opencores.org                           ////
////                                                                   ////
//////////////////////////////////////////////////////////////////////
////                                                                   ////
//// Copyright (C) 2001 Authors and OPENCORES.ORG                   ////
////                                                                   ////
//// This source file may be used and distributed without           ////
//// restriction provided that this copyright statement is not           ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                                   ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                                   ////
////                                                                   ////
//// This source is distributed in the hope that it will be           ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                           ////
////                                                                   ////
//// You should have received a copy of the GNU Lesser General           ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                           ////
////                                                                   ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.18  2003/07/01 18:51:11  simont
// x replaced with 0.
//
// Revision 1.17  2003/06/09 16:51:16  simont
// fix bug in DA operation.
//
// Revision 1.16  2003/06/03 17:15:06  simont
// sub_result output added.
//
// Revision 1.15  2003/05/07 12:31:53  simont
// add wire sub_result, conect it to des_acc and des1.
//
// Revision 1.14  2003/05/05 15:46:36  simont
// add aditional alu destination to solve critical path.
//
// Revision 1.13  2003/04/29 08:35:12  simont
// fix bug in substraction.
//
// Revision 1.12  2003/04/25 17:15:51  simont
// change branch instruction execution (reduse needed clock periods).
//
// Revision 1.11  2003/04/14 14:29:42  simont
// fiz bug iv pcs operation.
//
// Revision 1.10  2003/01/13 14:14:40  simont
// replace some modules
//
// Revision 1.9  2002/09/30 17:33:59  simont
// prepared header
//
//
// synopsys translate_off
// synopsys translate_on
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores Definitions                                        ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////  8051 definitions.                                           ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////      - Jaka Simsic, jakas@opencores.org                      ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// ver: 1
//
//
// oc8051 pherypherals
//
//
// oc8051 ITERNAL ROM
//
//`define OC8051_ROM
//
// oc8051 memory
//
//`define OC8051_CACHE
//`define OC8051_WB
//`define OC8051_RAM_XILINX
//`define OC8051_RAM_VIRTUALSILICON
//
// oc8051 simulation defines
//
//`define OC8051_SIMULATION
//`define OC8051_SERIAL
//
// oc8051 bist
//
//`define OC8051_BIST
//
// operation codes for alu
//
//
// sfr addresses
//
//
// sfr bit addresses
//
//
//carry input in alu
//
//
// instruction set
//
//op_code [4:0]
//op_code [7:3]
//op_code [7:1]
//op_code [7:0]
//
// default values (used after reset)
//
//
// alu source 1 select
//
//
// alu source 2 select
//
//
// alu source 3 select
//
//`define OC8051_AS3_PCU  3'b101 // program clunter not registered
//
//write sfr
//
//
// ram read select
//
//
// ram write select
//
//
// pc in select
//
//
// compare source select
//
//
// pc Write
//
//
//psw set
//
//
// rom address select
//
////
//// write accumulator
////
//`define OC8051_WA_N 1'b0 // not
//`define OC8051_WA_Y 1'b1 // yes
//
//memory action select
//
////////////////////////////////////////////////////
//
// Timer/Counter modes
//
//
// Interrupt numbers (vectors)
//
//
// interrupt levels
//
//
// interrupt sources
//
//
// miscellaneus
//
//
// read modify write instruction
//
module oc8051_alu (
input        clk, input rst, input srcCy, input srcAc, input bit_in,
input  [3:0] op_code,
input [7:0] src1, input [7:0] src2, input [7:0] src3,
output reg       desCy, output reg desAc, output reg desOv,
output reg [7:0] des1, output reg [7:0] des2, output reg [7:0] des_acc,
output wire [7:0] sub_result);
//
// op_code      (in)  operation code [oc8051_decoder.alu_op -r]
// src1         (in)  first operand [oc8051_alu_src1_sel.des]
// src2         (in)  second operand [oc8051_alu_src2_sel.des]
// src3         (in)  third operand [oc8051_alu_src3_sel.des]
// srcCy        (in)  carry input [oc8051_cy_select.data_out]
// srcAc        (in)  auxiliary carry input [oc8051_psw.data_out[6] ]
// bit_in       (in)  bit input, used for logic operatins on bits [oc8051_ram_sel.bit_out]
// des1         (out)
// des2         (out)
// desCy        (out) carry output [oc8051_ram_top.bit_data_in, oc8051_acc.bit_in, oc8051_b_register.bit_in, oc8051_psw.cy_in, oc8051_ports.bit_in]
// desAc        (out) auxiliary carry output [oc8051_psw.ac_in]
// desOv        (out) Overflow output [oc8051_psw.ov_in]
//
//
//add
//
wire [4:0] add1, add2, add3, add4;
wire [3:0] add5, add6, add7, add8;
wire [1:0] add9, adda, addb, addc;
//
//sub
//
wire [4:0] sub1, sub2, sub3, sub4;
wire [3:0] sub5, sub6, sub7, sub8;
wire [1:0] sub9, suba, subb, subc;
wire [7:0] sub_result;
//
//mul
//
  wire [7:0] mulsrc1, mulsrc2;
  wire mulOv;
  reg enable_mul;
//
//div
//
wire [7:0] divsrc1,divsrc2;
wire divOv;
reg enable_div;
//
//da
//
reg da_tmp, da_tmp1;
//reg [8:0] da1;
//
// inc
//
wire [15:0] inc, dec;
oc8051_multiply oc8051_mul1(.clk(clk), .rst(rst), .enable(enable_mul), .src1(src1), .src2(src2), .des1(mulsrc1), .des2(mulsrc2), .desOv(mulOv));
oc8051_divide oc8051_div1(.clk(clk), .rst(rst), .enable(enable_div), .src1(src1), .src2(src2), .des1(divsrc1), .des2(divsrc2), .desOv(divOv));
/* Add */
assign add1 = {1'b0,src1[3:0]};
assign add2 = {1'b0,src2[3:0]};
assign add3 = {3'b000,srcCy};
assign add4 = add1+add2+add3;
assign add5 = {1'b0,src1[6:4]};
assign add6 = {1'b0,src2[6:4]};
assign add7 = {1'b0,1'b0,1'b0,add4[4]};
assign add8 = add5+add6+add7;
assign add9 = {1'b0,src1[7]};
assign adda = {1'b0,src2[7]};
assign addb = {1'b0,add8[3]};
assign addc = add9+adda+addb;
/* Sub */
assign sub1 = {1'b1,src1[3:0]};
assign sub2 = {1'b0,src2[3:0]};
assign sub3 = {1'b0,1'b0,1'b0,srcCy};
assign sub4 = sub1-sub2-sub3;
assign sub5 = {1'b1,src1[6:4]};
assign sub6 = {1'b0,src2[6:4]};
assign sub7 = {1'b0,1'b0,1'b0, !sub4[4]};
assign sub8 = sub5-sub6-sub7;
assign sub9 = {1'b1,src1[7]};
assign suba = {1'b0,src2[7]};
assign subb = {1'b0,!sub8[3]};
assign subc = sub9-suba-subb;
assign sub_result = {subc[0],sub8[2:0],sub4[3:0]};
/* inc */
assign inc = {src2, src1} + {15'h0, 1'b1};
assign dec = {src2, src1} - {15'h0, 1'b1};
always @*
begin
  case (op_code) /* synopsys full_case parallel_case */
//operation add
    4'b0001: begin
      des_acc = {addc[0],add8[2:0],add4[3:0]};
      des1 = src1;
      des2 = src3+ {7'b0, addc[1]};
      desCy = addc[1];
      desAc = add4[4];
      desOv = addc[1] ^ add8[3];
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation subtract
    4'b0010: begin
      des_acc = sub_result;
//      des1 = sub_result;
      des1 = 8'h00;
      des2 = 8'h00;
      desCy = !subc[1];
      desAc = !sub4[4];
      desOv = !subc[1] ^ !sub8[3];
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation multiply
    4'b0011: begin
      des_acc = mulsrc1;
      des1 = src1;
      des2 = mulsrc2;
      desOv = mulOv;
      desCy = 1'b0;
      desAc = 1'b0;
      enable_mul = 1'b1;
      enable_div = 1'b0;
    end
//operation divide
    4'b0100: begin
      des_acc = divsrc1;
      des1 = src1;
      des2 = divsrc2;
      desOv = divOv;
      desAc = 1'b0;
      desCy = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b1;
    end
//operation decimal adjustment
    4'b0101: begin
      if (srcAc==1'b1 | src1[3:0]>4'b1001) begin {da_tmp, des_acc[3:0]} = {1'b0, src1[3:0]}+ 5'b00110; end
      else begin {da_tmp, des_acc[3:0]} = {1'b0, src1[3:0]}; end
      if (srcCy | da_tmp | src1[7:4]>4'b1001) begin
        {da_tmp1, des_acc[7:4]} = {srcCy, src1[7:4]}+ 5'b00110 + {4'b0, da_tmp}; end
      else begin {da_tmp1, des_acc[7:4]} = {srcCy, src1[7:4]} + {4'b0, da_tmp}; end
      desCy = da_tmp | da_tmp1;
      des1 = src1;
      des2 = 8'h00;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation not
// bit operation not
    4'b0110: begin
      des_acc = ~src1;
      des1 = ~src1;
      des2 = 8'h00;
      desCy = !srcCy;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation and
//bit operation and
    4'b0111: begin
      des_acc = src1 & src2;
      des1 = src1 & src2;
      des2 = 8'h00;
      desCy = srcCy & bit_in;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation xor
// bit operation xor
    4'b1000: begin
      des_acc = src1 ^ src2;
      des1 = src1 ^ src2;
      des2 = 8'h00;
      desCy = srcCy ^ bit_in;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation or
// bit operation or
    4'b1001: begin
      des_acc = src1 | src2;
      des1 = src1 | src2;
      des2 = 8'h00;
      desCy = srcCy | bit_in;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation rotate left
// bit operation cy= cy or (not ram)
    4'b1010: begin
      des_acc = {src1[6:0], src1[7]};
      des1 = src1 ;
      des2 = 8'h00;
      desCy = srcCy | !bit_in;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation rotate left with carry and swap nibbles
    4'b1011: begin
      des_acc = {src1[6:0], srcCy};
      des1 = src1 ;
      des2 = {src1[3:0], src1[7:4]};
      desCy = src1[7];
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation rotate right
    4'b1100: begin
      des_acc = {src1[0], src1[7:1]};
      des1 = src1 ;
      des2 = 8'h00;
      desCy = srcCy & !bit_in;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation rotate right with carry
    4'b1101: begin
      des_acc = {srcCy, src1[7:1]};
      des1 = src1 ;
      des2 = 8'h00;
      desCy = src1[0];
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation pcs Add
    4'b1110: begin
      if (srcCy) begin
        des_acc = dec[7:0];
        des1 = dec[7:0];
        des2 = dec[15:8];
      end else begin
        des_acc = inc[7:0];
        des1 = inc[7:0];
        des2 = inc[15:8];
      end
      desCy = 1'b0;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation exchange
//if carry = 0 exchange low order digit
    4'b1111: begin
      if (srcCy)
      begin
        des_acc = src2;
        des1 = src2;
        des2 = src1;
      end else begin
        des_acc = {src1[7:4],src2[3:0]};
        des1 = {src1[7:4],src2[3:0]};
        des2 = {src2[7:4],src1[3:0]};
      end
      desCy = 1'b0;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
    4'b0000: begin
      des_acc = src1;
      des1 = src1;
      des2 = src2;
      desCy = srcCy;
      desAc = srcAc;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
  endcase
end
endmodule
