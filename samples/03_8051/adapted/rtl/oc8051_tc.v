//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores timer/counter control                            ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   timers and counters handling for 8051 core                 ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
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
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.8  2003/04/10 12:43:19  simont
// defines for pherypherals added
//
// Revision 1.7  2003/04/07 14:58:02  simont
// change sfr's interface.
//
// Revision 1.6  2003/04/04 10:34:13  simont
// change timers to meet timing specifications (add divider with 12)
//
// Revision 1.5  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.4  2002/09/30 17:33:59  simont
// prepared header
//
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores Definitions              		          ////
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
//synopsys translate_off
`timescale 1ns/10ps
//synopsys translate_on
module oc8051_tc (clk, rst, 
            data_in,
            wr_addr,
	    wr, wr_bit,
	    ie0, ie1,
	    tr0, tr1,
	    t0, t1,
            tf0, tf1,
	    pres_ow,
//registers
	    tmod, tl0, th0, tl1, th1);
input [7:0]  wr_addr,
             data_in;
input        clk,
             rst,
	     wr,
	     wr_bit,
	     ie0,
	     ie1,
	     tr0,
	     tr1,
	     t0,
	     t1,
	     pres_ow;
output [7:0] tmod,
             tl0,
	     th0,
	     tl1,
	     th1;
output       tf0,
             tf1;
reg [7:0] tmod, tl0, th0, tl1, th1;
reg tf0, tf1_0, tf1_1, t0_buff, t1_buff;
wire tc0_add, tc1_add;
assign tc0_add = (tr0 & (!tmod[3] | !ie0) & ((!tmod[2] & pres_ow) | (tmod[2] & !t0 & t0_buff)));
assign tc1_add = (tr1 & (!tmod[7] | !ie1) & ((!tmod[6] & pres_ow) | (tmod[6] & !t1 & t1_buff)));
assign tf1= tf1_0 | tf1_1;
//
// read or write from one of the addresses in tmod
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   tmod <=#1 8'b0000_0000;
 end else if ((wr) & !(wr_bit) & (wr_addr==8'h89))
    tmod <= #1 data_in;
end
//
// TIMER COUNTER 0
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   tl0 <=#1 8'b0000_0000;
   th0 <=#1 8'b0000_0000;
   tf0 <= #1 1'b0;
   tf1_0 <= #1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==8'h8a)) begin
   tl0 <= #1 data_in;
   tf0 <= #1 1'b0;
   tf1_0 <= #1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==8'h8c)) begin
   th0 <= #1 data_in;
   tf0 <= #1 1'b0;
   tf1_0 <= #1 1'b0;
 end else begin
     case (tmod[1:0]) /* synopsys full_case parallel_case */
      2'b00: begin                       // mode 0
        tf1_0 <= #1 1'b0;
        if (tc0_add)
          {tf0, th0,tl0[4:0]} <= #1 {1'b0, th0, tl0[4:0]}+ 1'b1;
      end
      2'b01: begin                       // mode 1
        tf1_0 <= #1 1'b0;
        if (tc0_add)
          {tf0, th0,tl0} <= #1 {1'b0, th0, tl0}+ 1'b1;
      end
      2'b10: begin                       // mode 2
        tf1_0 <= #1 1'b0;
        if (tc0_add) begin
	  if (tl0 == 8'b1111_1111) begin
            tf0 <=#1 1'b1;
            tl0 <=#1 th0;
           end
          else begin
            tl0 <=#1 tl0 + 8'h1;
            tf0 <= #1 1'b0;
          end
	end
      end
      2'b11: begin                       // mode 3
	 if (tc0_add)
	   {tf0, tl0} <= #1 {1'b0, tl0} +1'b1;
         if (tr1 & pres_ow)
	   {tf1_0, th0} <= #1 {1'b0, th0} +1'b1;
      end
/*      default:begin
        tf0 <= #1 1'b0;
        tf1_0 <= #1 1'b0;
      end*/
    endcase
 end
end
//
// TIMER COUNTER 1
//
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   tl1 <=#1 8'b0000_0000;
   th1 <=#1 8'b0000_0000;
   tf1_1 <= #1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==8'h8b)) begin
   tl1 <= #1 data_in;
   tf1_1 <= #1 1'b0;
 end else if ((wr) & !(wr_bit) & (wr_addr==8'h8d)) begin
   th1 <= #1 data_in;
   tf1_1 <= #1 1'b0;
 end else begin
     case (tmod[5:4]) /* synopsys full_case parallel_case */
      2'b00: begin                       // mode 0
        if (tc1_add)
          {tf1_1, th1,tl1[4:0]} <= #1 {1'b0, th1, tl1[4:0]}+ 1'b1;
      end
      2'b01: begin                       // mode 1
        if (tc1_add)
          {tf1_1, th1,tl1} <= #1 {1'b0, th1, tl1}+ 1'b1;
      end
      2'b10: begin                       // mode 2
        if (tc1_add) begin
	  if (tl1 == 8'b1111_1111) begin
            tf1_1 <=#1 1'b1;
            tl1 <=#1 th1;
           end
          else begin
            tl1 <=#1 tl1 + 8'h1;
            tf1_1 <= #1 1'b0;
          end
	end
      end
/*      default:begin
        tf1_1 <= #1 1'b0;
      end*/
    endcase
 end
end
always @(posedge clk or posedge rst)
  if (rst) begin
    t0_buff <= #1 1'b0;
    t1_buff <= #1 1'b0;
  end else begin
    t0_buff <= #1 t0;
    t1_buff <= #1 t1;
  end
endmodule
