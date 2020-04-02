//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 data ram                                               ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   data ram                                                   ////
////                                                              ////
////  To Do:                                                      ////
////   nothing                                                    ////
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
// Revision 1.10  2003/06/20 13:36:37  simont
// ram modules added.
//
// Revision 1.9  2003/06/17 14:17:22  simont
// BIST signals added.
//
// Revision 1.8  2003/04/02 16:12:04  simont
// generic_dpram used
//
// Revision 1.7  2003/04/02 11:26:21  simont
// updating...
//
// Revision 1.6  2003/01/26 14:19:22  rherveille
// Replaced oc8051_ram by generic_dpram.
//
// Revision 1.5  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.4  2002/09/30 17:33:59  simont
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
module oc8051_ram_top (
  input clk, input wr, input bit_addr, input bit_data_in, input rst,
  input [7:0] wr_data,
  input [7:0] rd_addr, input [7:0] wr_addr,
  output bit_data_out,
  output [7:0] rd_data
);
// on-chip ram-size (2**ram_aw bytes)
localparam ram_aw = 8; // default 256 bytes
//
// clk          (in)  clock
// rd_addr      (in)  read addres [oc8051_ram_rd_sel.out]
// rd_data      (out) read data [oc8051_ram_sel.in_ram]
// wr_addr      (in)  write addres [oc8051_ram_wr_sel.out]
// bit_addr     (in)  bit addresable instruction [oc8051_decoder.bit_addr -r]
// wr_data      (in)  write data [oc8051_alu.des1]
// wr           (in)  write [oc8051_decoder.wr -r]
// bit_data_in  (in)  bit data input [oc8051_alu.desCy]
// bit_data_out (out)  bit data output [oc8051_ram_sel.bit_in]
//

// rd_addr_m    read address modified
// wr_addr_m    write address modified
// wr_data_m    write data modified
reg [7:0] wr_data_m;
reg [7:0] rd_addr_m, wr_addr_m;
wire       rd_en;
reg        bit_addr_r;
reg        rd_en_r;
reg  [7:0] wr_data_r;
wire [7:0] rd_data_m;
reg  [2:0] bit_select;
assign bit_data_out = rd_data[bit_select];
assign rd_data = rd_en_r ? wr_data_r: rd_data_m;
assign rd_en   = (rd_addr_m == wr_addr_m) & wr;
oc8051_ram_256x8_two_bist oc8051_idata(
                           .clk     ( clk        ),
                           .rst     ( rst        ),
                           .rd_addr ( rd_addr_m  ),
                           .rd_data ( rd_data_m  ),
                           .rd_en   ( !rd_en     ),
                           .wr_addr ( wr_addr_m  ),
                           .wr_data ( wr_data_m  ),
                           .wr_en   ( 1'b1       ),
                           .wr      ( wr         )
                           );
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    bit_addr_r <= 1'b0;
    bit_select <= 3'b0;
  end else begin
    bit_addr_r <= bit_addr;
    bit_select <= rd_addr[2:0];
  end
end
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    rd_en_r    <= 1'b0;
    wr_data_r  <= 8'h0;
  end else begin
    rd_en_r    <= rd_en;
    wr_data_r  <= wr_data_m;
  end
end
always @*
begin
  casex ( {bit_addr, rd_addr[7]} ) // synopsys full_case parallel_case
      2'b0?: begin rd_addr_m = rd_addr; end
      2'b10: begin rd_addr_m = {4'b0010, rd_addr[6:3]}; end
      2'b11: begin rd_addr_m = {1'b1, rd_addr[6:3], 3'b000}; end
  endcase
end
always @*
begin
  casex ( {bit_addr_r, wr_addr[7]} ) // synopsys full_case parallel_case
      2'b0?: begin wr_addr_m = wr_addr; end
      2'b10: begin wr_addr_m = {8'h00, 4'b0010, wr_addr[6:3]}; end
      2'b11: begin wr_addr_m = {8'h00, 1'b1, wr_addr[6:3], 3'b000}; end
  endcase
end
always @*
begin
  casex ( {bit_addr_r, bit_select} ) // synopsys full_case parallel_case
      4'b0_???: begin wr_data_m = wr_data; end
      4'b1_000: begin wr_data_m = {rd_data[7:1], bit_data_in}; end
      4'b1_001: begin wr_data_m = {rd_data[7:2], bit_data_in, rd_data[0]}; end
      4'b1_010: begin wr_data_m = {rd_data[7:3], bit_data_in, rd_data[1:0]}; end
      4'b1_011: begin wr_data_m = {rd_data[7:4], bit_data_in, rd_data[2:0]}; end
      4'b1_100: begin wr_data_m = {rd_data[7:5], bit_data_in, rd_data[3:0]}; end
      4'b1_101: begin wr_data_m = {rd_data[7:6], bit_data_in, rd_data[4:0]}; end
      4'b1_110: begin wr_data_m = {rd_data[7], bit_data_in, rd_data[5:0]}; end
      4'b1_111: begin wr_data_m = {bit_data_in, rd_data[6:0]}; end
  endcase
end
endmodule
