//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cache ram                                              ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   64x32 dual port ram for instruction cache                  ////
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
// Revision 1.2  2002/10/24 13:37:43  simont
// add localparams
//
// Revision 1.1  2002/10/23 16:58:21  simont
// initial import
//
//
// synopsys translate_off
// synopsys translate_on
module oc8051_cache_ram (
input clk, input wr1, input rst,
input [ADR_WIDTH-1:0] addr0, input [ADR_WIDTH-1:0] addr1,
input [31:0] data1_i,
output reg [31:0] data0, output reg [31:0] data1_o
);
//
// this module is part of oc8051_icache
// it's tehnology dependent
//
// clk          (in)  clock
// addr0        (in)  addres port 0
// data0        (out) data output port 0
// addr1        (in)  address port 1
// data1_i      (in)  data input port 1
// data1_o      (out) data output port 1
// wr1          (in)  write port 1
//
localparam ADR_WIDTH = 7; // cache address wihth
localparam CACHE_RAM = 128; // cache ram x 32 (2^ADR_WIDTH)

//
// buffer
reg [31:0] buff [0:CACHE_RAM];
//
// port 1
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    data1_o <= 32'h0;
  end else if (wr1) begin
    buff[addr1] <= data1_i;
    data1_o <= data1_i;
  end else begin
    data1_o <= buff[addr1];
  end
end
//
// port 0
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    data0 <= 32'h0;
  end else if ((addr0==addr1) & wr1) begin
    data0 <= data1_i;
  end else begin
    data0 <= buff[addr0];
  end
end
endmodule
