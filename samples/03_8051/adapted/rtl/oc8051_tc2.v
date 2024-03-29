//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores timer/counter2 control                           ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   timers and counters 2 8051 core                            ////
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
// Revision 1.2  2003/04/04 10:34:13  simont
// change timers to meet timing specifications (add divider with 12)
//
// Revision 1.1  2003/01/13 14:13:12  simont
// initial import
//
//
//
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
//synopsys translate_off
//synopsys translate_on
module oc8051_tc2 (
input clk,
input rst,
input [7:0] wr_addr,
input [7:0] data_in,
input wr,
input wr_bit,
input t2,
input t2ex,
input bit_in,
input pres_ow,        //prescalre owerflov
output reg [7:0] t2con,
output reg [7:0] tl2,
output reg [7:0] th2,
output reg [7:0] rcap2l,
output reg [7:0] rcap2h,
output tc2_int,
output rclk,
output tclk,
output reg brate2
);

reg neg_trans, t2ex_r, t2_r, tc2_event, tf2_set;
wire run;
//
// t2con
wire tf2, exf2, exen2, tr2, ct2, cprl2;
assign tc2_int = tf2 | exf2;
assign tf2   = t2con[7];
assign exf2  = t2con[6];
assign rclk  = t2con[5];
assign tclk  = t2con[4];
assign exen2 = t2con[3];
assign tr2   = t2con[2];
assign ct2   = t2con[1];
assign cprl2 = t2con[0];
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    t2con <= 8'h00;
  end else if ((wr) & !(wr_bit) & (wr_addr==8'hc8)) begin
    t2con <= data_in;
  end else if ((wr) & (wr_bit) & (wr_addr[7:3]==5'b11001)) begin
    t2con[wr_addr[2:0]] <= bit_in;
  end else if (tf2_set) begin
    t2con[7] <= 1'b1;
  end else if (exen2 & neg_trans) begin
    t2con[6] <= 1'b1;
  end
end
//
//th2, tl2
assign run = tr2 & ((!ct2 & pres_ow) | (ct2 & tc2_event));
always @(posedge clk or posedge rst)
begin
  if (rst) begin
//
// reset
//
    tl2 <= 8'h00;
    th2 <= 8'h00;
    brate2 <= 1'b0;
    tf2_set <= 1'b0;
  end else if ((wr) & !(wr_bit) & (wr_addr==8'hcd)) begin
//
// write to timer 2 high
//
    th2 <= data_in;
  end else if ((wr) & !(wr_bit) & (wr_addr==8'hcc)) begin
//
// write to timer 2 low
//
    tl2 <= data_in;
  end else if (!(rclk | tclk) & !cprl2 & exen2 & neg_trans) begin
//
// avto reload mode, exen2=1, 0-1 transition on t2ex pin
//
    th2 <= rcap2h;
    tl2 <= rcap2l;
    tf2_set <= 1'b0;
  end else if (run) begin
    if (rclk | tclk) begin
//
// boud rate generator mode
//
      if (&{th2, tl2}) begin
        th2 <= rcap2h;
        tl2 <= rcap2l;
        brate2 <= 1'b1;
      end else begin
        {brate2, th2, tl2}  <= {1'b0, th2, tl2} + 17'h1;
      end
      tf2_set <= 1'b0;
    end else if (cprl2) begin
//
// capture mode
//
      {tf2_set, th2, tl2}  <= {1'b0, th2, tl2} + 17'h1;
    end else begin
//
// auto reload mode
//
      if (&{th2, tl2}) begin
        th2 <= rcap2h;
        tl2 <= rcap2l;
        tf2_set <= 1'b1;
      end else begin
        {tf2_set, th2, tl2} <= {1'b0, th2, tl2} + 17'h1;
      end
    end
  end else begin tf2_set <= 1'b0; end
end
//
// rcap2l, rcap2h
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    rcap2l <= 8'h00;
    rcap2h <= 8'h00;
  end else if ((wr) & !(wr_bit) & (wr_addr==8'hcb)) begin
    rcap2h <= data_in;
  end else if ((wr) & !(wr_bit) & (wr_addr==8'hca)) begin
    rcap2l <= data_in;
  end else if (!(rclk | tclk) & exen2 & cprl2 & neg_trans) begin
    rcap2l <= tl2;
    rcap2h <= th2;
  end
end
//
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    neg_trans <= 1'b0;
    t2ex_r <= 1'b0;
  end else if (t2ex) begin
    neg_trans <= 1'b0;
    t2ex_r <= 1'b1;
  end else if (t2ex_r) begin
    neg_trans <= 1'b1;
    t2ex_r <= 1'b0;
  end else begin
    neg_trans <= 1'b0;
    t2ex_r <= t2ex_r;
  end
end
//
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    tc2_event <= 1'b0;
    t2_r <= 1'b0;
  end else if (t2) begin
    tc2_event <= 1'b0;
    t2_r <= 1'b1;
  end else if (!t2 & t2_r) begin
    tc2_event <= 1'b1;
    t2_r <= 1'b0;
  end else begin
    tc2_event <= 1'b0;
  end
end
endmodule
