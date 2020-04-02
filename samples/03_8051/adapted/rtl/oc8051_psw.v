//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 program status word                                    ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   program status word                                        ////
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
// Revision 1.11  2003/04/09 15:49:42  simont
// Register oc8051_sfr dato output, add signal wait_data.
//
// Revision 1.10  2003/04/07 14:58:02  simont
// change sfr's interface.
//
// Revision 1.9  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.8  2002/11/05 17:23:54  simont
// add module oc8051_sfr, 256 bytes internal ram
//
// Revision 1.7  2002/09/30 17:33:59  simont
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
module oc8051_psw (
input clk, 
input rst, 
input wr, 
input p, 
input cy_in, 
input ac_in, 
input ov_in, 
input wr_bit,
input [1:0] set,
input [7:0] wr_addr, input [7:0] data_in,
output [1:0] bank_sel,
output [7:0] data_out
);
//
// clk          (in)  clock
// rst          (in)  reset
// addr         (in)  write address [oc8051_ram_wr_sel.out]
// data_in      (in)  data input [oc8051_alu.des1]
// wr           (in)  write [oc8051_decoder.wr -r]
// wr_bit       (in)  write bit addresable [oc8051_decoder.bit_addr -r]
// p            (in)  parity [oc8051_acc.p]
// cy_in        (in)  input bit data [oc8051_alu.desCy]
// ac_in        (in)  auxiliary carry input [oc8051_alu.desAc]
// ov_in        (in)  overflov input [oc8051_alu.desOv]
// set          (in)  set psw (write to caryy, carry and overflov or carry, owerflov and ac) [oc8051_decoder.psw_set -r]
//
reg [7:1] data;
wire wr_psw;
assign wr_psw = (wr & (wr_addr==8'hd0) && !wr_bit);
assign bank_sel = wr_psw ? data_in[4:3]:data[4:3];
assign data_out = {data[7:1], p};
//
//case writing to psw
always @(posedge clk or posedge rst)
begin
  if (rst)
  begin
    data <= 8'h00;
//
// write to psw (byte addressable)
  end else begin
    if (wr & (wr_bit==1'b0) & (wr_addr==8'hd0)) begin
      data[7:1] <= data_in[7:1];
//
// write to psw (bit addressable)
    end else if (wr & wr_bit & (wr_addr[7:3]==5'b11010)) begin
      data[wr_addr[2:0]] <= cy_in;
    end else begin
      case (set) /* synopsys full_case parallel_case */
        2'b01: begin
//
//write carry
          data[7] <= cy_in;
        end
        2'b10: begin
//
//write carry and overflov
          data[7] <= cy_in;
          data[2] <= ov_in;
        end
        2'b11:begin
//
//write carry, overflov and ac
          data[7] <= cy_in;
          data[6] <= ac_in;
          data[2] <= ov_in;
        end
      endcase
    end
  end
end
endmodule
