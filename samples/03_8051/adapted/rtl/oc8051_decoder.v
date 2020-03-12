//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 core decoder                                           ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Main 8051 core module. decodes instruction and creates     ////
////   control sigals.                                            ////
////                                                              ////
////  To Do:                                                      ////
////   optimize state machine, especially IDS ASS and AS3         ////
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
// Revision 1.21  2003/06/03 17:09:57  simont
// pipelined acces to axternal instruction interface added.
//
// Revision 1.20  2003/05/06 11:10:38  simont
// optimize state machine.
//
// Revision 1.19  2003/05/06 09:41:35  simont
// remove define OC8051_AS2_PCL, chane signal src_sel2 to 2 bit wide.
//
// Revision 1.18  2003/05/05 15:46:36  simont
// add aditional alu destination to solve critical path.
//
// Revision 1.17  2003/04/25 17:15:51  simont
// change branch instruction execution (reduse needed clock periods).
//
// Revision 1.16  2003/04/09 16:24:03  simont
// change wr_sft to 2 bit wire.
//
// Revision 1.15  2003/04/09 15:49:42  simont
// Register oc8051_sfr dato output, add signal wait_data.
//
// Revision 1.14  2003/01/13 14:14:40  simont
// replace some modules
//
// Revision 1.13  2002/10/23 16:53:39  simont
// fix bugs in instruction interface
//
// Revision 1.12  2002/10/17 18:50:00  simont
// cahnge interface to instruction rom
//
// Revision 1.11  2002/09/30 17:33:59  simont
// prepared header
//
//

// synopsys translate_off


`timescale 1ns/10ps
// synopsys translate_on

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






module oc8051_decoder (clk, rst, op_in, op1_c,
  ram_rd_sel_o, ram_wr_sel_o,
  bit_addr, wr_o, wr_sfr_o,
  src_sel1, src_sel2, src_sel3,
  alu_op_o, psw_set, eq, cy_sel, comp_sel,
  pc_wr, pc_sel, rd, rmw, istb, mem_act, mem_wait,
  wait_data);

//
// clk          (in)  clock
// rst          (in)  reset
// op_in        (in)  operation code [oc8051_op_select.op1]
// eq           (in)  compare result [oc8051_comp.eq]
// ram_rd_sel   (out) select, whitch address will be send to ram for read [oc8051_ram_rd_sel.sel, oc8051_sp.ram_rd_sel]
// ram_wr_sel   (out) select, whitch address will be send to ram for write [oc8051_ram_wr_sel.sel -r, oc8051_sp.ram_wr_sel -r]
// wr           (out) write - if 1 then we will write to ram [oc8051_ram_top.wr -r, oc8051_acc.wr -r, oc8051_b_register.wr -r, oc8051_sp.wr-r, oc8051_dptr.wr -r, oc8051_psw.wr -r, oc8051_indi_addr.wr -r, oc8051_ports.wr -r]
// src_sel1     (out) select alu source 1 [oc8051_alu_src1_sel.sel -r]
// src_sel2     (out) select alu source 2 [oc8051_alu_src2_sel.sel -r]
// src_sel3     (out) select alu source 3 [oc8051_alu_src3_sel.sel -r]
// alu_op       (out) alu operation [oc8051_alu.op_code -r]
// psw_set      (out) will we remember cy, ac, ov from alu [oc8051_psw.set -r]
// cy_sel       (out) carry in alu select [oc8051_cy_select.cy_sel -r]
// comp_sel     (out) compare source select [oc8051_comp.sel]
// bit_addr     (out) if instruction is bit addresable [oc8051_ram_top.bit_addr -r, oc8051_acc.wr_bit -r, oc8051_b_register.wr_bit-r, oc8051_sp.wr_bit -r, oc8051_dptr.wr_bit -r, oc8051_psw.wr_bit -r, oc8051_indi_addr.wr_bit -r, oc8051_ports.wr_bit -r]
// pc_wr        (out) pc write [oc8051_pc.wr]
// pc_sel       (out) pc select [oc8051_pc.pc_wr_sel]
// rd           (out) read from rom [oc8051_pc.rd, oc8051_op_select.rd]
// reti         (out) return from interrupt [pin]
// rmw          (out) read modify write feature [oc8051_ports.rmw]
// pc_wait      (out)
//

input clk, rst, eq, mem_wait, wait_data;
input [7:0] op_in;

output wr_o, bit_addr, pc_wr, rmw, istb, src_sel3;
output [1:0] psw_set, cy_sel, wr_sfr_o, src_sel2, comp_sel;
output [2:0] mem_act, src_sel1, ram_rd_sel_o, ram_wr_sel_o, pc_sel, op1_c;
output [3:0] alu_op_o;
output rd;

reg rmw;
reg src_sel3, wr,  bit_addr, pc_wr;
reg [3:0] alu_op;
reg [1:0] src_sel2, comp_sel, psw_set, cy_sel, wr_sfr;
reg [2:0] mem_act, src_sel1, ram_wr_sel, ram_rd_sel, pc_sel;

//
// state        if 2'b00 then normal execution, sle instructin that need more than one clock
// op           instruction buffer
reg  [1:0] state;
wire [1:0] state_dec;
reg  [7:0] op;
wire [7:0] op_cur;
reg  [2:0] ram_rd_sel_r;

reg stb_i;

assign rd = !state[0] && !state[1] && !wait_data;// && !stb_o;

assign istb = (!state[1]) && stb_i;

assign state_dec = wait_data ? 2'b00 : state;

assign op_cur = mem_wait ? 8'h00
                : (state[0] || state[1] || mem_wait || wait_data) ? op : op_in;
//assign op_cur = (state[0] || state[1] || mem_wait || wait_data) ? op : op_in;

assign op1_c = op_cur[2:0];

assign alu_op_o     = wait_data ? 4'b0000 : alu_op;
assign wr_sfr_o     = wait_data ? 2'b00   : wr_sfr;
assign ram_rd_sel_o = wait_data ? ram_rd_sel_r    : ram_rd_sel;
assign ram_wr_sel_o = wait_data ? 3'b000  : ram_wr_sel;
assign wr_o         = wait_data ? 1'b0            : wr;

//
// main block
// unregisterd outputs
always @(op_cur or eq or state_dec or mem_wait)
begin
    case (state_dec) /* synopsys full_case parallel_case */
      2'b01: begin
        casex (op_cur) /* synopsys parallel_case */
          8'b1000_0100 : begin
              ram_rd_sel = 3'b100;
            end
          8'b1010_0100 : begin
              ram_rd_sel = 3'b100;
            end
          default begin
              ram_rd_sel = 3'b000;
          end
        endcase
        stb_i = 1'b1;
        bit_addr = 1'b0;
        pc_wr = 1'b0;
        pc_sel = 3'b000;
        comp_sel =  2'b01;
        rmw = 1'b0;
      end
      2'b10: begin
        casex (op_cur) /* synopsys parallel_case */
          8'b1000_0000 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b1;
              pc_sel = 3'b010;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b0100_0000 : begin
              ram_rd_sel = 3'b110;
              pc_wr = eq;
              pc_sel = 3'b010;
              comp_sel =  2'b10;
              bit_addr = 1'b0;
            end
          8'b0101_0000 : begin
              ram_rd_sel = 3'b110;
              pc_wr = !eq;
              pc_sel = 3'b010;
              comp_sel =  2'b10;
              bit_addr = 1'b0;
            end
          8'b0111_0000 : begin
              ram_rd_sel = 3'b111;
              pc_wr = !eq;
              pc_sel = 3'b010;
              comp_sel =  2'b00;
              bit_addr = 1'b0;
            end
          8'b0110_0000 : begin
              ram_rd_sel = 3'b111;
              pc_wr = eq;
              pc_sel = 3'b010;
              comp_sel =  2'b00;
              bit_addr = 1'b0;
            end

          8'b0010_0010 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b1;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b0011_0010 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b1;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b1011_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = !eq;
              pc_sel = 3'b011;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b1011_011x : begin
              ram_rd_sel = 3'b000;
              pc_wr = !eq;
              pc_sel = 3'b011;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b1011_0101 : begin
              ram_rd_sel = 3'b000;
              pc_wr = !eq;
              pc_sel = 3'b011;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b1011_0100 : begin
              ram_rd_sel = 3'b000;
              pc_wr = !eq;
              pc_sel = 3'b011;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b1101_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = !eq;
              pc_sel = 3'b010;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b1101_0101 : begin
              ram_rd_sel = 3'b000;
              pc_wr = !eq;
              pc_sel = 3'b011;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b0010_0000 : begin
              ram_rd_sel = 3'b000;
              pc_wr = eq;
              pc_sel = 3'b011;
              comp_sel =  2'b11;
              bit_addr = 1'b0;
            end
          8'b0001_0000 : begin
              ram_rd_sel = 3'b000;
              pc_wr = eq;
              pc_sel = 3'b011;
              comp_sel =  2'b11;
              bit_addr = 1'b1;
            end
          8'b0111_0011 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b1;
              pc_sel = 3'b110;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b0011_0000 : begin
              ram_rd_sel = 3'b000;
              pc_wr = !eq;
              pc_sel = 3'b011;
              comp_sel =  2'b11;
              bit_addr = 1'b1;
            end
          8'b1000_0100 : begin
              ram_rd_sel = 3'b100;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          8'b1010_0100 : begin
              ram_rd_sel = 3'b100;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
            end
          default begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              bit_addr = 1'b0;
          end
        endcase
        rmw = 1'b0;
        stb_i = 1'b1;
      end
      2'b11: begin
        casex (op_cur) /* synopsys parallel_case */
          8'b1011_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
            end
          8'b1011_011x : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
            end
          8'b1011_0101 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
            end
          8'b1011_0100 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
            end
          8'b1101_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
            end
          8'b1101_0101 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
            end
          8'b0010_0010 : begin
              ram_rd_sel = 3'b011;
              pc_wr = 1'b1;
              pc_sel = 3'b001;
            end
          8'b0011_0010 : begin
              ram_rd_sel = 3'b011;
              pc_wr = 1'b1;
              pc_sel = 3'b001;
            end
          8'b1000_0100 : begin
              ram_rd_sel = 3'b100;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
            end
          8'b1010_0100 : begin
              ram_rd_sel = 3'b100;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
            end
         default begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
          end
        endcase
        comp_sel =  2'b01;
        rmw = 1'b0;
        stb_i = 1'b1;
        bit_addr = 1'b0;
      end
      2'b00: begin
        casex (op_cur) /* synopsys parallel_case */
          8'bxxx1_0001 :begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b1;
              pc_sel = 3'b100;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'bxxx0_0001 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b1;
              pc_sel = 3'b100;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b0010_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0011_1xxx : begin
             ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0101_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1011_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b0001_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1101_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b0000_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1110_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1010_1xxx : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1000_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0100_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1001_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1100_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0110_1xxx : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
    
    //op_code [7:1]
          8'b0010_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0011_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0101_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1011_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b0001_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0000_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1110_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1000_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1010_011x : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1110_001x : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b1111_001x :begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b0100_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1001_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1100_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1101_011x :begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0110_011x : begin
              ram_rd_sel = 3'b001;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
    
    //op_code [7:0]
          8'b0010_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0011_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0101_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0101_0100 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0101_0010 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0101_0011 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1000_0010 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b1;
            end
          8'b1011_0000 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b1;
            end
          8'b1011_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b1011_0100 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b1100_0010 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b1;
            end
          8'b1011_0010 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b1;
            end
          8'b0001_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1000_0100 : begin
              ram_rd_sel = 3'b100;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b1101_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b0000_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1010_0011 : begin
              ram_rd_sel = 3'b101;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0010_0000 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b011;
              comp_sel =  2'b11;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b1;
            end
          8'b0001_0000 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b11;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b1;
            end
/*          `OC8051_JC : begin
              ram_rd_sel = `OC8051_RRS_PSW;
              pc_wr = eq;
              pc_sel = `OC8051_PIS_SO1;
              comp_sel =  `OC8051_CSS_CY;
              rmw = `OC8051_RMW_N;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end*/
          8'b0111_0011 : begin
              ram_rd_sel = 3'b101;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
    
          8'b0011_0000 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b011;
              comp_sel =  2'b11;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b1;
            end
/*          `OC8051_JNC : begin
              ram_rd_sel = `OC8051_RRS_PSW;
              pc_wr = !eq;
              pc_sel = `OC8051_PIS_SO1;
              comp_sel =  `OC8051_CSS_CY;
              rmw = `OC8051_RMW_N;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          `OC8051_JNZ : begin
              ram_rd_sel = `OC8051_RRS_ACC;
              pc_wr = !eq;
              pc_sel = `OC8051_PIS_SO1;
              comp_sel =  `OC8051_CSS_AZ;
              rmw = `OC8051_RMW_N;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          `OC8051_JZ : begin
              ram_rd_sel = `OC8051_RRS_ACC;
              pc_wr = eq;
              pc_sel = `OC8051_PIS_SO1;
              comp_sel =  `OC8051_CSS_AZ;
              rmw = `OC8051_RMW_N;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end*/
          8'b0001_0010 :begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b1;
              pc_sel = 3'b101;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b0000_0010 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b1;
              pc_sel = 3'b101;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b1110_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1000_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1010_0010 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b1;
            end
          8'b1001_0010 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b1;
            end
          8'b1001_0011 :begin
              ram_rd_sel = 3'b101;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b1000_0011 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b1110_0000 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b1111_0000 : begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b1010_0100 : begin
              ram_rd_sel = 3'b100;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b0100_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0100_0010 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0100_0011 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0111_0010 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b1;
            end
          8'b1010_0000 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b1;
            end
          8'b1101_0000 : begin
              ram_rd_sel = 3'b011;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1100_0000 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0010_0010 : begin
              ram_rd_sel = 3'b011;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b0011_0010 : begin
              ram_rd_sel = 3'b011;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end
          8'b1101_0010 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b1;
            end
/*          `OC8051_SJMP : begin
              ram_rd_sel = `OC8051_RRS_DC;
              pc_wr = `OC8051_PCW_Y;
              pc_sel = `OC8051_PIS_SO1;
              comp_sel =  `OC8051_CSS_DC;
              rmw = `OC8051_RMW_N;
              stb_i = 1'b0;
              bit_addr = 1'b0;
            end*/
          8'b1001_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b1100_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0110_0101 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0110_0010 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          8'b0110_0011 : begin
              ram_rd_sel = 3'b010;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b1;
              stb_i = 1'b1;
              bit_addr = 1'b0;
            end
          default: begin
              ram_rd_sel = 3'b000;
              pc_wr = 1'b0;
              pc_sel = 3'b000;
              comp_sel =  2'b01;
              rmw = 1'b0;
              stb_i = 1'b1;
              bit_addr = 1'b0;
           end
        endcase
      end
    endcase
end










//
//
// registerd outputs

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    ram_wr_sel <= #1 3'b000;
    src_sel1 <= #1 3'b000;
    src_sel2 <= #1 3'b00;
    alu_op <= #1 4'b0000;
    wr <= #1 1'b0;
    psw_set <= #1 2'b00;
    cy_sel <= #1 2'b00;
    src_sel3 <= #1 1'b0;
    wr_sfr <= #1 2'b00;
  end else if (!wait_data) begin
    case (state_dec) /* synopsys parallel_case */
      2'b01: begin
        casex (op_cur) /* synopsys parallel_case */
          8'b1001_0011 :begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b111;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              wr_sfr <= #1 2'b01;
            end
          8'b1000_0011 :begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b111;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              wr_sfr <= #1 2'b01;
            end
          8'b1110_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b111;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              wr_sfr <= #1 2'b01;
            end
          8'b1110_001x : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b111;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              wr_sfr <= #1 2'b01;
            end
/*          `OC8051_ACALL :begin
              ram_wr_sel <= #1 `OC8051_RWS_SP;
              src_sel1 <= #1 `OC8051_AS1_PCH;
              src_sel2 <= #1 `OC8051_AS2_DC;
              alu_op <= #1 `OC8051_ALU_NOP;
              wr <= #1 1'b1;
              psw_set <= #1 `OC8051_PS_NOT;
              wr_sfr <= #1 `OC8051_WRS_N;
            end
          `OC8051_AJMP : begin
              ram_wr_sel <= #1 `OC8051_RWS_DC;
              src_sel1 <= #1 `OC8051_AS1_DC;
              src_sel2 <= #1 `OC8051_AS2_DC;
              alu_op <= #1 `OC8051_ALU_NOP;
              wr <= #1 1'b0;
              psw_set <= #1 `OC8051_PS_NOT;
              wr_sfr <= #1 `OC8051_WRS_N;
            end
          `OC8051_LCALL :begin
              ram_wr_sel <= #1 `OC8051_RWS_SP;
              src_sel1 <= #1 `OC8051_AS1_PCH;
              src_sel2 <= #1 `OC8051_AS2_DC;
              alu_op <= #1 `OC8051_ALU_NOP;
              wr <= #1 1'b1;
              psw_set <= #1 `OC8051_PS_NOT;
              wr_sfr <= #1 `OC8051_WRS_N;
            end*/
          8'b1000_0100 : begin
              ram_wr_sel <= #1 3'b111;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0100;
              wr <= #1 1'b1;
              psw_set <= #1 2'b10;
              wr_sfr <= #1 2'b10;
            end
          8'b1010_0100 : begin
              ram_wr_sel <= #1 3'b111;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0011;
              wr <= #1 1'b1;
              psw_set <= #1 2'b10;
              wr_sfr <= #1 2'b10;
            end
          default begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              wr_sfr <= #1 2'b00;
          end
        endcase
        cy_sel <= #1 2'b00;
        src_sel3 <= #1 1'b0;
      end
      2'b10: begin
        casex (op_cur) /* synopsys parallel_case */
          8'bxxx1_0001 :begin
              ram_wr_sel <= #1 3'b011;
              src_sel1 <= #1 3'b100;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
            end
          8'b0001_0010 :begin
              ram_wr_sel <= #1 3'b011;
              src_sel1 <= #1 3'b100;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
            end
          8'b0001_0000 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
            end
          8'b1000_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0100;
              wr <= #1 1'b0;
              psw_set <= #1 2'b10;
            end
          8'b1010_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0011;
              wr <= #1 1'b0;
              psw_set <= #1 2'b10;
            end
          default begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
          end
        endcase
        cy_sel <= #1 2'b00;
        src_sel3 <= #1 1'b0;
        wr_sfr <= #1 2'b00;
      end

      2'b11: begin
        casex (op_cur) /* synopsys parallel_case */
          8'b0010_0010 : begin
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              psw_set <= #1 2'b00;
            end
          8'b0011_0010 : begin
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              psw_set <= #1 2'b00;
            end
          8'b1000_0100 : begin
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0100;
              psw_set <= #1 2'b10;
            end
          8'b1010_0100 : begin
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0011;
              psw_set <= #1 2'b10;
            end
         default begin
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              psw_set <= #1 2'b00;
          end
        endcase
        ram_wr_sel <= #1 3'b000;
        wr <= #1 1'b0;
        cy_sel <= #1 2'b00;
        src_sel3 <= #1 1'b0;
        wr_sfr <= #1 2'b00;
      end
      default: begin
        casex (op_cur) /* synopsys parallel_case */
          8'bxxx1_0001 :begin
              ram_wr_sel <= #1 3'b011;
              src_sel1 <= #1 3'b101;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'bxxx0_0001 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0010_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0011_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0101_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0111;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1011_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b11;
              alu_op <= #1 4'b0010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0001_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b1110;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1101_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b1110;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0000_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b1110;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1110_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1111_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1010_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0111_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b001;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1000_1xxx : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0100_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1001_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1100_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1111;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b10;
            end
          8'b0110_1xxx : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
    
    //op_code [7:1]
          8'b0010_011x : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0011_011x : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0101_011x : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0111;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1011_011x : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b11;
              alu_op <= #1 4'b0010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0001_011x : begin
              ram_wr_sel <= #1 3'b010;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b1110;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0000_011x : begin
              ram_wr_sel <= #1 3'b010;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b1110;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1110_011x : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1000_011x : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1111_011x : begin
              ram_wr_sel <= #1 3'b010;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1010_011x : begin
              ram_wr_sel <= #1 3'b010;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0111_011x : begin
              ram_wr_sel <= #1 3'b010;
              src_sel1 <= #1 3'b001;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1110_001x : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1111_001x :begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0100_011x : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1001_011x : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1100_011x : begin
              ram_wr_sel <= #1 3'b010;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1111;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b10;
            end
          8'b1101_011x :begin
              ram_wr_sel <= #1 3'b010;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1111;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b10;
            end
          8'b0110_011x : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
    
    //op_code [7:0]
          8'b0010_0101 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0010_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b001;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0011_0101 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0011_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b001;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0101_0101 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0111;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0101_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b001;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b0111;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0101_0010 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0111;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0101_0011 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b010;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0111;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1000_0010 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0111;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1011_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b1100;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1011_0101 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1011_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b11;
              alu_op <= #1 4'b0010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1110_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b0010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b01;
            end
          8'b1100_0011 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b1100_0010 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b1111_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0110;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1011_0011 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0110;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1011_0010 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0110;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b10;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1101_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0101;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0001_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b1110;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0001_0101 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b1110;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1000_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0100;
              wr <= #1 1'b0;
              psw_set <= #1 2'b10;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1101_0101 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b1110;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0000_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b1110;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0000_0101 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b1110;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1010_0011 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b10;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b11;
            end
          8'b0010_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b0001_0000 :begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b0100_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b0111_0011 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0011_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b0101_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b0111_0000 :begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b0110_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b0001_0010 :begin
              ram_wr_sel <= #1 3'b011;
              src_sel1 <= #1 3'b101;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0000_0010 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1110_0101 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0111_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b001;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1111_0101 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1000_0101 : begin
              ram_wr_sel <= #1 3'b101;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0111_0101 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b010;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1010_0010 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b10;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1001_0010 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1001_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b010;
              src_sel2 <= #1 3'b11;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b11;
            end
          8'b1001_0011 :begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1000_0011 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b101;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b0001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b1110_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1111_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1010_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0011;
              wr <= #1 1'b0;
              psw_set <= #1 2'b10;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0100_0101 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0100_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b001;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0100_0010 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1001;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0100_0011 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b010;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b1001;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0111_0010 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b1001;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1010_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b1010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1101_0000 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b1100_0000 : begin
              ram_wr_sel <= #1 3'b011;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0010_0010 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0011_0010 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0010_0011 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b1010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0011_0011 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b1011;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0000_0011 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b1100;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0001_0011 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b1101;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1101_0011 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b01;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b1101_0010 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b1000_0000 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b1;
              wr_sfr <= #1 2'b00;
            end
          8'b1001_0101 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1001_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b11;
              alu_op <= #1 4'b0010;
              wr <= #1 1'b0;
              psw_set <= #1 2'b11;
              cy_sel <= #1 2'b01;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b1100_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b011;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b1011;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b10;
            end
          8'b1100_0101 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1111;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b11;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b10;
            end
          8'b0110_0101 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0110_0100 : begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b001;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b01;
            end
          8'b0110_0010 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b01;
              alu_op <= #1 4'b1000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          8'b0110_0011 : begin
              ram_wr_sel <= #1 3'b001;
              src_sel1 <= #1 3'b010;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b1000;
              wr <= #1 1'b1;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
            end
          default: begin
              ram_wr_sel <= #1 3'b000;
              src_sel1 <= #1 3'b000;
              src_sel2 <= #1 3'b00;
              alu_op <= #1 4'b0000;
              wr <= #1 1'b0;
              psw_set <= #1 2'b00;
              cy_sel <= #1 2'b00;
              src_sel3 <= #1 1'b0;
              wr_sfr <= #1 2'b00;
           end
        endcase
      end
      endcase
  end
end


//
// remember current instruction
always @(posedge clk or posedge rst)
  if (rst) op <= #1 2'b00;
  else if (state==2'b00) op <= #1 op_in;

//
// in case of instructions that needs more than one clock set state
always @(posedge clk or posedge rst)
begin
  if (rst)
    state <= #1 2'b11;
  else if  (!mem_wait & !wait_data) begin
    case (state) /* synopsys parallel_case */
      2'b10: state <= #1 2'b01;
      2'b11: state <= #1 2'b10;
      2'b00:
          casex (op_in) /* synopsys full_case parallel_case */
            8'bxxx1_0001   : state <= #1 2'b10;
            8'bxxx0_0001    : state <= #1 2'b10;
            8'b1011_1xxx  : state <= #1 2'b10;
            8'b1011_011x  : state <= #1 2'b10;
            8'b1011_0101  : state <= #1 2'b10;
            8'b1011_0100  : state <= #1 2'b10;
            8'b0000_0010    : state <= #1 2'b10;
            8'b1101_1xxx  : state <= #1 2'b10;
            8'b1101_0101  : state <= #1 2'b10;
            8'b0001_0010   : state <= #1 2'b10;
            8'b1001_0011 : state <= #1 2'b11;
            8'b1000_0011 : state <= #1 2'b11;
            8'b1110_001x : state <= #1 2'b10;
            8'b1111_001x : state <= #1 2'b10;
            8'b1110_0000 : state <= #1 2'b10;
            8'b1111_0000 : state <= #1 2'b10;
            8'b0010_0010     : state <= #1 2'b11;
            8'b0011_0010    : state <= #1 2'b11;
            8'b1000_0000    : state <= #1 2'b10;
            8'b0010_0000      : state <= #1 2'b10;
            8'b0001_0000     : state <= #1 2'b10;
            8'b0100_0000      : state <= #1 2'b10;
            8'b0111_0011   : state <= #1 2'b10;
            8'b0101_0000     : state <= #1 2'b10;
            8'b0011_0000     : state <= #1 2'b10;
            8'b0111_0000     : state <= #1 2'b10;
            8'b0110_0000      : state <= #1 2'b10;
            8'b1000_0100     : state <= #1 2'b11;
            8'b1010_0100     : state <= #1 2'b11;
//            default         : state <= #1 2'b00;
          endcase
      default: state <= #1 2'b00;
    endcase
  end
end


//
//in case of writing to external ram
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    mem_act <= #1 3'b111;
  end else if (!rd) begin
    mem_act <= #1 3'b111;
  end else
    casex (op_cur) /* synopsys parallel_case */
      8'b1111_001x : mem_act <= #1 3'b011;
      8'b1111_0000 : mem_act <= #1 3'b001;
      8'b1110_001x : mem_act <= #1 3'b010;
      8'b1110_0000 : mem_act <= #1 3'b000;
      8'b1001_0011 : mem_act <= #1 3'b100;
      8'b1000_0011 : mem_act <= #1 3'b100;
      default : mem_act <= #1 3'b111;
    endcase
end

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    ram_rd_sel_r <= #1 3'h0;
  end else begin
    ram_rd_sel_r <= #1 ram_rd_sel;
  end
end



















endmodule


