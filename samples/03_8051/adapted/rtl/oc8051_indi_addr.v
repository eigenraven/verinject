//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 indirect address                                       ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Contains ragister 0 and register 1. used for indirrect     ////
////   addressing.                                                ////
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
// Revision 1.6  2003/05/05 15:46:37  simont
// add aditional alu destination to solve critical path.
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
module oc8051_indi_addr (
input        clk,        // clock
input          rst,        // reset
input   wr,        // write
input       sel,        // select register
input  wr_bit,        // write bit addressable
input  [1:0] bank,        // select register bank
input  [7:0] data_in,        // data input
input  [7:0] wr_addr,        // write address
output reg [7:0] ri_out);
//

//reg [7:0] buff [31:0];
reg wr_bit_r;
reg [7:0] buff [0:7];
//
//write to buffer
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    buff[3'b000] <= 8'h00;
    buff[3'b001] <= 8'h00;
    buff[3'b010] <= 8'h00;
    buff[3'b011] <= 8'h00;
    buff[3'b100] <= 8'h00;
    buff[3'b101] <= 8'h00;
    buff[3'b110] <= 8'h00;
    buff[3'b111] <= 8'h00;
  end else begin
    if ((wr) & !(wr_bit_r)) begin
      case (wr_addr) /* synopsys full_case parallel_case */
        8'h00: begin buff[3'b000] <= data_in; end
        8'h01: begin buff[3'b001] <= data_in; end
        8'h08: begin buff[3'b010] <= data_in; end
        8'h09: begin buff[3'b011] <= data_in; end
        8'h10: begin buff[3'b100] <= data_in; end
        8'h11: begin buff[3'b101] <= data_in; end
        8'h18: begin buff[3'b110] <= data_in; end
        8'h19: begin buff[3'b111] <= data_in; end
      endcase
    end
  end
end
//
//read from buffer
always @*
begin
  ri_out = (({3'b000, bank, 2'b00, sel}==wr_addr) & (wr) & !wr_bit_r) ?
                 data_in : buff[{bank, sel}];
end

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    wr_bit_r <= 1'b0;
  end else begin
    wr_bit_r <= wr_bit;
  end
end

endmodule
