//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 memory interface                                       ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   comunication betwen cpu and memory                         ////
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
// Revision 1.12  2003/07/01 20:47:39  simont
// add /* synopsys xx_case */ to case statments.
//
// Revision 1.11  2003/06/20 13:35:10  simont
// simualtion `ifdef added
//
// Revision 1.10  2003/06/05 11:15:02  simont
// fix bug.
//
// Revision 1.9  2003/06/03 17:09:57  simont
// pipelined acces to axternal instruction interface added.
//
// Revision 1.8  2003/05/12 16:27:40  simont
// fix bug in movc intruction.
//
// Revision 1.7  2003/05/06 09:39:34  simont
// cahnge assigment to pc_wait (remove istb_o)
//
// Revision 1.6  2003/05/05 15:46:37  simont
// add aditional alu destination to solve critical path.
//
// Revision 1.5  2003/04/25 17:15:51  simont
// change branch instruction execution (reduse needed clock periods).
//
// Revision 1.4  2003/04/16 10:04:09  simont
// chance idat_ir to 24 bit wide
//
// Revision 1.3  2003/04/11 10:05:08  simont
// Change pc add value from 23'h to 16'h
//
// Revision 1.2  2003/04/09 16:24:03  simont
// change wr_sft to 2 bit wire.
//
// Revision 1.1  2003/01/13 14:13:12  simont
// initial import
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
module oc8051_memory_interface (
input         clk,
input         rst,
input         wr_i,
input         wr_bit_i,
input         bit_in,
input         sfr_bit,
input         dack_i,
input [2:0]   mem_act,
input [7:0]   in_ram,
input [7:0]   sfr,
input [7:0]   acc,
input [7:0]   sp_w,
input [31:0]  idat_i,
output reg    bit_out,
output        mem_wait,
output reg    reti,
output reg [7:0]  iram_out,
output [7:0]  wr_dat,
output        wr_o,
output        wr_bit_o,
/////////////////////////////
//
//  rom_addr_sel
//
/////////////////////////////
input         iack_i,
input [7:0]   des_acc,
input [7:0]   des1,
input [7:0]   des2,
output [15:0] iadr_o,
/////////////////////////////
//
// ext_addr_sel
//
/////////////////////////////
input [7:0]   ri,
input [7:0]   ddat_i,
input [15:0]  dptr,
output reg    dstb_o,
output reg    dwe_o,
output reg [7:0]  ddat_o,
output [15:0] dadr_o,
/////////////////////////////
//
// ram_adr_sel
//
/////////////////////////////
input [2:0]   rd_sel,
input [2:0]   wr_sel,
input [4:0]   rn,
input [7:0]   sp,
output reg    rd_ind,
output reg    wr_ind,
output reg [7:0]  wr_addr,
output reg [7:0]  rd_addr,
/////////////////////////////
//
// op_select
//
/////////////////////////////
input         intr,
input         rd,
input         ea, 
input         ea_int, 
input         istb,
input  [7:0]  int_v,
input  [31:0] idat_onchip,
output reg    int_ack,
output        istb_o,
output reg [7:0] op1_out,
output [7:0] op3_out,
output [7:0] op2_out,

input [2:0]   pc_wr_sel,
input         pc_wr,
output reg [15:0] pc
);

reg [7:0]        sp_r;
reg           rd_addr_r;
//????
reg           dack_ir;
reg [7:0]     ddat_ir;
reg [23:0]    idat_ir;
wire          ea_rom_sel;
reg [4:0]     rn_r;
reg [7:0]     ri_r;
reg [7:0]     imm_r;
reg [7:0]     imm2_r;
reg [7:0]     op1_r;
wire [7:0]    imm;
wire [7:0]    imm2;
reg           int_ack_t;
reg           int_ack_buff;
reg [7:0]     int_vec_buff;
reg [7:0]     op2_buff;
reg [7:0]     op3_buff;
reg [7:0]     op1_o;
reg [7:0]     op2_o;
reg [7:0]     op3_o;
reg [7:0]     op1_xt;
reg [7:0]     op2_xt;
reg [7:0]     op3_xt;
reg [7:0]     op1;
reg [7:0]     op2;
reg [7:0]     op3;
wire [7:0]    op2_direct;
//
//pc            program counter register, save current value
reg [15:0]    pc_buf;
wire [15:0]   alu;
reg           int_buff,
              int_buff1; // interrupt buffer: used to prevent interrupting in the middle of executin instructions
//
//
////////////////////////////
reg           istb_t;
reg           imem_wait;
reg [15:0]    iadr_t;
reg [15:0]    dadr_ot;
reg           dmem_wait;
wire          pc_wait;
wire [1:0]    bank;
wire [7:0]    isr_call;
reg [1:0]     op_length;
reg [2:0]     op_pos;
wire          inc_pc;
reg           pc_wr_r;
wire [15:0]   pc_out;
reg [31:0]    idat_cur;
reg [31:0]    idat_old;
reg           inc_pc_r;
reg           pc_wr_r2;
reg [7:0]     cdata;
reg           cdone;
assign bank       = rn[4:3];
assign imm        = op2_out;
assign imm2       = op3_out;
assign alu        = {des2, des_acc};
assign ea_rom_sel = ea && ea_int;
assign wr_o       = wr_i;
assign wr_bit_o   = wr_bit_i;
//assign mem_wait   = dmem_wait || imem_wait || pc_wr_r;
assign mem_wait   = dmem_wait || imem_wait || pc_wr_r2;
//assign mem_wait   = dmem_wait || imem_wait;
assign istb_o     = (istb || (istb_t & !iack_i)) && !dstb_o && !ea_rom_sel;
assign pc_wait    = rd && (ea_rom_sel || (!istb_t && iack_i));
assign wr_dat     = des1;
/////////////////////////////
//
//  ram_select
//
/////////////////////////////
always @*
begin
  if (rd_addr_r && !rd_ind) begin
    iram_out = sfr;
    bit_out = sfr_bit;
  end else begin
    iram_out = in_ram;
    bit_out = bit_in;
  end
end
/////////////////////////////
//
// ram_adr_sel
//
/////////////////////////////
always @*
begin
  case (rd_sel) /* synopsys full_case parallel_case */
    3'b000   : begin rd_addr = {3'h0, rn}; end
    3'b001    : begin rd_addr = ri; end
    3'b010    : begin rd_addr = imm; end
    3'b011   : begin rd_addr = sp; end
    3'b100    : begin rd_addr = 8'hf0; end
    3'b101 : begin rd_addr = 8'h82; end
    3'b110  : begin rd_addr = 8'hd0; end
    3'b111  : begin rd_addr = 8'he0; end
//    default          : rd_addr = 2'bxx;
  endcase
end
//
//
always @*
begin
  case (wr_sel) /* synopsys full_case parallel_case */
    3'b000 : begin wr_addr = {3'h0, rn_r}; end
    3'b010  : begin wr_addr = ri_r; end
    3'b001  : begin wr_addr = imm_r; end
    3'b011 : begin wr_addr = sp_w; end
    3'b101 : begin wr_addr = imm2_r; end
    3'b111  : begin wr_addr = 8'hf0; end
//    default        : wr_addr = 2'bxx;
  endcase
end
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    rd_ind <= 1'b0; end
  else if ((rd_sel==3'b001) || (rd_sel==3'b011)) begin
    rd_ind <= 1'b1;
  end else begin
    rd_ind <= 1'b0;
  end
end
always @*
begin
  if ((wr_sel==3'b010) || (wr_sel==3'b011)) begin
    wr_ind = 1'b1;
  end else begin
    wr_ind = 1'b0;
  end
end
/////////////////////////////
//
//  rom_addr_sel
//
/////////////////////////////
//
// output address is alu destination
// (instructions MOVC)
//assign iadr_o = (istb_t & !iack_i) ? iadr_t : pc_out;
assign iadr_o = (istb_t) ? iadr_t : pc_out;
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    iadr_t <= 23'h0;
    istb_t <= 1'b0;
    imem_wait <= 1'b0;
    idat_ir <= 24'h0;
  end else if (mem_act==3'b100) begin
    iadr_t <= alu;
    istb_t <= 1'b1;
    imem_wait <= 1'b1;
  end else if (ea_rom_sel && imem_wait) begin
    imem_wait <= 1'b0;
  end else if (!imem_wait && istb_t) begin
    istb_t <= 1'b0;
  end else if (iack_i) begin
    imem_wait <= 1'b0;
    idat_ir <= idat_i [23:0];
  end
end
/////////////////////////////
//
// ext_addr_sel
//
/////////////////////////////
assign dadr_o = dadr_ot;
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    dwe_o <= 1'b0;
    dmem_wait <= 1'b0;
    dstb_o <= 1'b0;
    ddat_o <= 8'h00;
    dadr_ot <= 23'h0;
  end else if (dack_i) begin
    dwe_o <= 1'b0;
    dstb_o <= 1'b0;
    dmem_wait <= 1'b0;
  end else begin
    case (mem_act) /* synopsys full_case parallel_case */
      3'b000: begin  // read from external rom: acc=(dptr)
        dwe_o <= 1'b0;
        dstb_o <= 1'b1;
        ddat_o <= 8'h00;
        dadr_ot <= {7'h0, dptr};
        dmem_wait <= 1'b1;
      end
      3'b001: begin  // write to external rom: (dptr)=acc
        dwe_o <= 1'b1;
        dstb_o <= 1'b1;
        ddat_o <= acc;
        dadr_ot <= {7'h0, dptr};
        dmem_wait <= 1'b1;
      end
      3'b010:   begin  // read from external rom: acc=(Ri)
        dwe_o <= 1'b0;
        dstb_o <= 1'b1;
        ddat_o <= 8'h00;
        dadr_ot <= {15'h0, ri};
        dmem_wait <= 1'b1;
      end
      3'b011: begin    // write to external rom: (Ri)=acc
        dwe_o <= 1'b1;
        dstb_o <= 1'b1;
        ddat_o <= acc;
        dadr_ot <= {15'h0, ri};
        dmem_wait <= 1'b1;
      end
    endcase
  end
end
/////////////////////////////
//
// op_select
//
/////////////////////////////
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    idat_cur <= 32'h0;
    idat_old <= 32'h0;
  end else if ((iack_i | ea_rom_sel) & (inc_pc | pc_wr_r2)) begin
    idat_cur <= ea_rom_sel ? idat_onchip : idat_i;
    idat_old <= idat_cur;
  end
end
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    cdata <= 8'h00;
    cdone <= 1'b0;
  end else if (istb_t) begin
    cdata <= ea_rom_sel ? idat_onchip[7:0] : idat_i[7:0];
    cdone <= 1'b1;
  end else begin
    cdone <= 1'b0;
  end
end
always @*
begin
  case (op_pos)  /* synopsys parallel_case */
    3'b000: begin
       op1 = idat_old[7:0]  ;
       op2 = idat_old[15:8] ;
       op3 = idat_old[23:16];
      end
    3'b001: begin
       op1 = idat_old[15:8] ;
       op2 = idat_old[23:16];
       op3 = idat_old[31:24];
      end
    3'b010: begin
       op1 = idat_old[23:16];
       op2 = idat_old[31:24];
       op3 = idat_cur[7:0]  ;
      end
    3'b011: begin
       op1 = idat_old[31:24];
       op2 = idat_cur[7:0]  ;
       op3 = idat_cur[15:8] ;
      end
    3'b100: begin
       op1 = idat_cur[7:0]  ;
       op2 = idat_cur[15:8] ;
       op3 = idat_cur[23:16];
      end
    default: begin
       op1 = idat_cur[15:8] ;
       op2 = idat_cur[23:16];
       op3 = idat_cur[31:24];
      end
  endcase
end
/*assign op1 = ea_rom_sel ? idat_onchip[7:0]   : op1_xt;
assign op2 = ea_rom_sel ? idat_onchip[15:8]  : op2_xt;
assign op3 = ea_rom_sel ? idat_onchip[23:16] : op3_xt;*/
always @*
begin
  if (dack_ir) begin
    op1_out = ddat_ir;
  end else if (cdone) begin
    op1_out = cdata;
  end else begin
    op1_out = op1_o;
  end
end
assign op3_out = (rd) ? op3_o : op3_buff;
assign op2_out = (rd) ? op2_o : op2_buff;
always @*
begin
  if (iack_i) begin
    op1_xt = idat_i[7:0];
    op2_xt = idat_i[15:8];
    op3_xt = idat_i[23:16];
  end else if (!rd) begin
    op1_xt = idat_ir[7:0];
    op2_xt = idat_ir[15:8];
    op3_xt = idat_ir[23:16];
  end else begin
    op1_xt = 8'h00;
    op2_xt = 8'h00;
    op3_xt = 8'h00;
  end
end
//
// in case of interrupts
always @*
begin
  if (int_ack_t && (iack_i || ea_rom_sel)) begin
    op1_o = 8'b0001_0010;
    op2_o = 8'h00;
    op3_o = int_vec_buff;
  end else begin
    op1_o = op1;
    op2_o = op2;
    op3_o = op3;
  end
end
//
//in case of reti
always @(posedge clk or posedge rst)
begin
  if (rst) begin reti <= 1'b0; end
  else if ((op1_o==8'b0011_0010) & rd & !mem_wait) begin reti <= 1'b1; end
  else begin reti <= 1'b0; end
end
//
// remember inputs
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    op2_buff <= 8'h0;
    op3_buff <= 8'h0;
  end else if (rd) begin
    op2_buff <= op2_o;
    op3_buff <= op3_o;
  end
end
/////////////////////////////
//
//  pc
//
/////////////////////////////
always @*
begin
  casex (op1_out) /* synopsys parallel_case */
    8'bxxx1_0001 : begin  op_length = 2'h2; end
    8'bxxx0_0001 : begin   op_length = 2'h2; end
  //op_code [7:3]
    8'b1011_1xxx : begin op_length = 2'h3; end
    8'b1101_1xxx : begin op_length = 2'h2; end
    8'b1010_1xxx : begin op_length = 2'h2; end
    8'b0111_1xxx : begin op_length = 2'h2; end
    8'b1000_1xxx : begin op_length = 2'h2; end
  //op_code [7:1]
    8'b1011_011x : begin op_length = 2'h3; end
    8'b1000_011x : begin op_length = 2'h2; end
    8'b1010_011x : begin op_length = 2'h2; end
    8'b0111_011x : begin op_length = 2'h2; end
  //op_code [7:0]
    8'b0010_0101 : begin  op_length = 2'h2; end
    8'b0010_0100 : begin  op_length = 2'h2; end
    8'b0011_0101 : begin op_length = 2'h2; end
    8'b0011_0100 : begin op_length = 2'h2; end
    8'b0101_0101 : begin  op_length = 2'h2; end
    8'b0101_0100 : begin  op_length = 2'h2; end
    8'b0101_0010 : begin op_length = 2'h2; end
    8'b0101_0011 : begin op_length = 2'h3; end
    8'b1000_0010 : begin  op_length = 2'h2; end
    8'b1011_0000 : begin op_length = 2'h2; end
    8'b1011_0101 : begin op_length = 2'h3; end
    8'b1011_0100 : begin op_length = 2'h3; end
    8'b1100_0010 : begin  op_length = 2'h2; end
    8'b1011_0010 : begin  op_length = 2'h2; end
    8'b0001_0101 : begin  op_length = 2'h2; end
    8'b1101_0101 : begin op_length = 2'h3; end
    8'b0000_0101 : begin  op_length = 2'h2; end
    8'b0010_0000 : begin     op_length = 2'h3; end
    8'b0001_0000 : begin    op_length = 2'h3; end
    8'b0100_0000 : begin     op_length = 2'h2; end
    8'b0011_0000 : begin    op_length = 2'h3; end
    8'b0101_0000 : begin    op_length = 2'h2; end
    8'b0111_0000 : begin    op_length = 2'h2; end
    8'b0110_0000 : begin     op_length = 2'h2; end
    8'b0001_0010 : begin  op_length = 2'h3; end
    8'b0000_0010 : begin   op_length = 2'h3; end
    8'b1110_0101 : begin  op_length = 2'h2; end
    8'b0111_0100 : begin  op_length = 2'h2; end
    8'b1111_0101 : begin op_length = 2'h2; end
    8'b1000_0101 : begin op_length = 2'h3; end
    8'b0111_0101 : begin op_length = 2'h3; end
    8'b1010_0010 : begin op_length = 2'h2; end
    8'b1001_0010 : begin op_length = 2'h2; end
    8'b1001_0000 : begin op_length = 2'h3; end
    8'b0100_0101 : begin  op_length = 2'h2; end
    8'b0100_0100 : begin  op_length = 2'h2; end
    8'b0100_0010 : begin op_length = 2'h2; end
    8'b0100_0011 : begin op_length = 2'h3; end
    8'b0111_0010 : begin  op_length = 2'h2; end
    8'b1010_0000 : begin op_length = 2'h2; end
    8'b1101_0000 : begin    op_length = 2'h2; end
    8'b1100_0000 : begin   op_length = 2'h2; end
    8'b1101_0010 : begin op_length = 2'h2; end
    8'b1000_0000 : begin   op_length = 2'h2; end
    8'b1001_0101 : begin op_length = 2'h2; end
    8'b1001_0100 : begin op_length = 2'h2; end
    8'b1100_0101 : begin  op_length = 2'h2; end
    8'b0110_0101 : begin  op_length = 2'h2; end
    8'b0110_0100 : begin  op_length = 2'h2; end
    8'b0110_0010 : begin op_length = 2'h2; end
    8'b0110_0011 : begin op_length = 2'h3; end
    default:       begin  op_length = 2'h1; end
  endcase
end
/*
always @(posedge clk or posedge rst)
begin
    if (rst) begin
      op_length = 2'h2;
//    end else if (pc_wait) begin
    end else begin
        casex (op1_out)
          `OC8051_ACALL :  op_length <= 2'h2;
          `OC8051_AJMP :   op_length <= 2'h2;
        //op_code [7:3]
          `OC8051_CJNE_R : op_length <= 2'h3;
          `OC8051_DJNZ_R : op_length <= 2'h2;
          `OC8051_MOV_DR : op_length <= 2'h2;
          `OC8051_MOV_CR : op_length <= 2'h2;
          `OC8051_MOV_RD : op_length <= 2'h2;
        //op_code [7:1]
          `OC8051_CJNE_I : op_length <= 2'h3;
          `OC8051_MOV_ID : op_length <= 2'h2;
          `OC8051_MOV_DI : op_length <= 2'h2;
          `OC8051_MOV_CI : op_length <= 2'h2;
        //op_code [7:0]
          `OC8051_ADD_D :  op_length <= 2'h2;
          `OC8051_ADD_C :  op_length <= 2'h2;
          `OC8051_ADDC_D : op_length <= 2'h2;
          `OC8051_ADDC_C : op_length <= 2'h2;
          `OC8051_ANL_D :  op_length <= 2'h2;
          `OC8051_ANL_C :  op_length <= 2'h2;
          `OC8051_ANL_DD : op_length <= 2'h2;
          `OC8051_ANL_DC : op_length <= 2'h3;
          `OC8051_ANL_B :  op_length <= 2'h2;
          `OC8051_ANL_NB : op_length <= 2'h2;
          `OC8051_CJNE_D : op_length <= 2'h3;
          `OC8051_CJNE_C : op_length <= 2'h3;
          `OC8051_CLR_B :  op_length <= 2'h2;
          `OC8051_CPL_B :  op_length <= 2'h2;
          `OC8051_DEC_D :  op_length <= 2'h2;
          `OC8051_DJNZ_D : op_length <= 2'h3;
          `OC8051_INC_D :  op_length <= 2'h2;
          `OC8051_JB :     op_length <= 2'h3;
          `OC8051_JBC :    op_length <= 2'h3;
          `OC8051_JC :     op_length <= 2'h2;
          `OC8051_JNB :    op_length <= 2'h3;
          `OC8051_JNC :    op_length <= 2'h2;
          `OC8051_JNZ :    op_length <= 2'h2;
          `OC8051_JZ :     op_length <= 2'h2;
          `OC8051_LCALL :  op_length <= 2'h3;
          `OC8051_LJMP :   op_length <= 2'h3;
          `OC8051_MOV_D :  op_length <= 2'h2;
          `OC8051_MOV_C :  op_length <= 2'h2;
          `OC8051_MOV_DA : op_length <= 2'h2;
          `OC8051_MOV_DD : op_length <= 2'h3;
          `OC8051_MOV_CD : op_length <= 2'h3;
          `OC8051_MOV_BC : op_length <= 2'h2;
          `OC8051_MOV_CB : op_length <= 2'h2;
          `OC8051_MOV_DP : op_length <= 2'h3;
          `OC8051_ORL_D :  op_length <= 2'h2;
          `OC8051_ORL_C :  op_length <= 2'h2;
          `OC8051_ORL_AD : op_length <= 2'h2;
          `OC8051_ORL_CD : op_length <= 2'h3;
          `OC8051_ORL_B :  op_length <= 2'h2;
          `OC8051_ORL_NB : op_length <= 2'h2;
          `OC8051_POP :    op_length <= 2'h2;
          `OC8051_PUSH :   op_length <= 2'h2;
          `OC8051_SETB_B : op_length <= 2'h2;
          `OC8051_SJMP :   op_length <= 2'h2;
          `OC8051_SUBB_D : op_length <= 2'h2;
          `OC8051_SUBB_C : op_length <= 2'h2;
          `OC8051_XCH_D :  op_length <= 2'h2;
          `OC8051_XRL_D :  op_length <= 2'h2;
          `OC8051_XRL_C :  op_length <= 2'h2;
          `OC8051_XRL_AD : op_length <= 2'h2;
          `OC8051_XRL_CD : op_length <= 2'h3;
          default:         op_length <= 2'h1;
        endcase
//
//in case of instructions that use more than one clock hold current pc
//    end else begin
//      pc= pc_buf;
   end
end
*/
assign inc_pc = ((op_pos[2] | (&op_pos[1:0])) & rd) | pc_wr_r2;

always @(posedge rst or posedge clk)
begin
  if (rst) begin
    op_pos <= 3'h0;
  end else if (pc_wr_r2) begin
    op_pos <= 3'h4;// - op_length;////****??????????
/*  end else if (inc_pc & rd) begin
    op_pos[2]   <= op_pos[2] & !op_pos[1] & op_pos[0] & (&op_length);
    op_pos[1:0] <= op_pos[1:0] + op_length;
//    op_pos   <= {1'b0, op_pos[1:0]} + {1'b0, op_length};
  end else if (rd) begin
    op_pos <= op_pos + {1'b0, op_length};
  end*/
  end else if (inc_pc & rd) begin
    op_pos[2]   <= op_pos[2] & !op_pos[1] & op_pos[0] & (&op_length);
    op_pos[1:0] <= op_pos[1:0] + op_length;
//    op_pos   <= {1'b0, op_pos[1:0]} + {1'b0, op_length};
//  end else if (istb & rd) begin
  end else if (rd) begin
    op_pos <= op_pos + {1'b0, op_length};
  end
end
//
// remember interrupt
// we don't want to interrupt instruction in the middle of execution
always @(posedge clk or posedge rst)
begin
 if (rst) begin
   int_ack_t <= 1'b0;
   int_vec_buff <= 8'h00;
 end else if (intr) begin
   int_ack_t <= 1'b1;
   int_vec_buff <= int_v;
 end else if (rd && (ea_rom_sel || iack_i) && !pc_wr_r2) begin int_ack_t <= 1'b0; end
end
always @(posedge clk or posedge rst)
begin
  if (rst) int_ack_buff <= 1'b0;
  else int_ack_buff <= int_ack_t;
end
always @(posedge clk or posedge rst)
begin
  if (rst) int_ack <= 1'b0;
  else begin
    if ((int_ack_buff) & !(int_ack_t))
      int_ack <= 1'b1;
    else int_ack <= 1'b0;
  end
end
//
//interrupt buffer
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    int_buff1 <= 1'b0;
  end else begin
    int_buff1 <= int_buff;
  end
end
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    int_buff <= 1'b0;
  end else if (intr) begin
    int_buff <= 1'b1;
  end else if (pc_wait) begin
    int_buff <= 1'b0;
  end
end

wire [7:0]  pcs_source;
reg  [15:0] pcs_result;
reg         pcs_cy;
assign pcs_source = pc_wr_sel[0] ? op3_out : op2_out;
always @*
begin
  if (pcs_source[7]) begin
    {pcs_cy, pcs_result[7:0]} = {1'b0, pc[7:0]} + {1'b0, pcs_source};
    pcs_result[15:8] = pc[15:8] - {7'h0, !pcs_cy};
  end else begin
    pcs_result = pc + {8'h00, pcs_source};
  end
end
//assign pc = pc_buf - {13'h0, op_pos[2] | inc_pc_r, op_pos[1:0]}; ////******???
//assign pc = pc_buf - 16'h8 + {13'h0, op_pos}; ////******???
//assign pc = pc_buf - 16'h8 + {13'h0, op_pos} + {14'h0, op_length};
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    pc <= 16'h0;
  end else if (pc_wr_r2) begin
    pc <= pc_buf;
  end else if (rd & !int_ack_t) begin
    pc <= pc_buf - 16'h8 + {13'h0, op_pos} + {14'h0, op_length};
  end
end
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    pc_buf <= 23'h0;
  end else if (pc_wr) begin
//
//case of writing new value to pc (jupms)
      case (pc_wr_sel) /* synopsys full_case parallel_case */
        3'b110: begin pc_buf        <= alu; end
        3'b000: begin  pc_buf[7:0]   <= alu[7:0]; end
        3'b001: begin  pc_buf[15:8]  <= alu[7:0]; end
        3'b100: begin pc_buf[10:0]  <= {op1_out[7:5], op2_out}; end
        3'b101: begin pc_buf        <= {op2_out, op3_out}; end
        3'b010: begin pc_buf        <= pcs_result; end
        3'b011: begin pc_buf        <= pcs_result; end
      endcase
//  end else if (inc_pc) begin
  end else begin
//
//or just remember current
      pc_buf <= pc_out;
  end
end
assign pc_out = inc_pc ? pc_buf + 16'h4
                       : pc_buf ;
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    ddat_ir <= 8'h00;
  end else if (dack_i) begin
    ddat_ir <= ddat_i;
  end
end
/*
always @(pc_buf or op1_out or pc_wait or int_buff or int_buff1 or ea_rom_sel or iack_i)
begin
    if (int_buff || int_buff1) begin
//
//in case of interrupt hold valut, to be written to stack
      pc= pc_buf;
//    end else if (pis_l) begin
//      pc = {pc_buf[22:8], alu[7:0]};
    end else if (pc_wait) begin
        casex (op1_out)
          `OC8051_ACALL :  pc= pc_buf + 16'h2;
          `OC8051_AJMP :   pc= pc_buf + 16'h2;
        //op_code [7:3]
          `OC8051_CJNE_R : pc= pc_buf + 16'h3;
          `OC8051_DJNZ_R : pc= pc_buf + 16'h2;
          `OC8051_MOV_DR : pc= pc_buf + 16'h2;
          `OC8051_MOV_CR : pc= pc_buf + 16'h2;
          `OC8051_MOV_RD : pc= pc_buf + 16'h2;
        //op_code [7:1]
          `OC8051_CJNE_I : pc= pc_buf + 16'h3;
          `OC8051_MOV_ID : pc= pc_buf + 16'h2;
          `OC8051_MOV_DI : pc= pc_buf + 16'h2;
          `OC8051_MOV_CI : pc= pc_buf + 16'h2;
        //op_code [7:0]
          `OC8051_ADD_D :  pc= pc_buf + 16'h2;
          `OC8051_ADD_C :  pc= pc_buf + 16'h2;
          `OC8051_ADDC_D : pc= pc_buf + 16'h2;
          `OC8051_ADDC_C : pc= pc_buf + 16'h2;
          `OC8051_ANL_D :  pc= pc_buf + 16'h2;
          `OC8051_ANL_C :  pc= pc_buf + 16'h2;
          `OC8051_ANL_DD : pc= pc_buf + 16'h2;
          `OC8051_ANL_DC : pc= pc_buf + 16'h3;
          `OC8051_ANL_B :  pc= pc_buf + 16'h2;
          `OC8051_ANL_NB : pc= pc_buf + 16'h2;
          `OC8051_CJNE_D : pc= pc_buf + 16'h3;
          `OC8051_CJNE_C : pc= pc_buf + 16'h3;
          `OC8051_CLR_B :  pc= pc_buf + 16'h2;
          `OC8051_CPL_B :  pc= pc_buf + 16'h2;
          `OC8051_DEC_D :  pc= pc_buf + 16'h2;
          `OC8051_DJNZ_D : pc= pc_buf + 16'h3;
          `OC8051_INC_D :  pc= pc_buf + 16'h2;
          `OC8051_JB :     pc= pc_buf + 16'h3;
          `OC8051_JBC :    pc= pc_buf + 16'h3;
          `OC8051_JC :     pc= pc_buf + 16'h2;
          `OC8051_JNB :    pc= pc_buf + 16'h3;
          `OC8051_JNC :    pc= pc_buf + 16'h2;
          `OC8051_JNZ :    pc= pc_buf + 16'h2;
          `OC8051_JZ :     pc= pc_buf + 16'h2;
          `OC8051_LCALL :  pc= pc_buf + 16'h3;
          `OC8051_LJMP :   pc= pc_buf + 16'h3;
          `OC8051_MOV_D :  pc= pc_buf + 16'h2;
          `OC8051_MOV_C :  pc= pc_buf + 16'h2;
          `OC8051_MOV_DA : pc= pc_buf + 16'h2;
          `OC8051_MOV_DD : pc= pc_buf + 16'h3;
          `OC8051_MOV_CD : pc= pc_buf + 16'h3;
          `OC8051_MOV_BC : pc= pc_buf + 16'h2;
          `OC8051_MOV_CB : pc= pc_buf + 16'h2;
          `OC8051_MOV_DP : pc= pc_buf + 16'h3;
          `OC8051_ORL_D :  pc= pc_buf + 16'h2;
          `OC8051_ORL_C :  pc= pc_buf + 16'h2;
          `OC8051_ORL_AD : pc= pc_buf + 16'h2;
          `OC8051_ORL_CD : pc= pc_buf + 16'h3;
          `OC8051_ORL_B :  pc= pc_buf + 16'h2;
          `OC8051_ORL_NB : pc= pc_buf + 16'h2;
          `OC8051_POP :    pc= pc_buf + 16'h2;
          `OC8051_PUSH :   pc= pc_buf + 16'h2;
          `OC8051_SETB_B : pc= pc_buf + 16'h2;
          `OC8051_SJMP :   pc= pc_buf + 16'h2;
          `OC8051_SUBB_D : pc= pc_buf + 16'h2;
          `OC8051_SUBB_C : pc= pc_buf + 16'h2;
          `OC8051_XCH_D :  pc= pc_buf + 16'h2;
          `OC8051_XRL_D :  pc= pc_buf + 16'h2;
          `OC8051_XRL_C :  pc= pc_buf + 16'h2;
          `OC8051_XRL_AD : pc= pc_buf + 16'h2;
          `OC8051_XRL_CD : pc= pc_buf + 16'h3;
          default:         pc= pc_buf + 16'h1;
        endcase
//
//in case of instructions that use more than one clock hold current pc
    end else begin
      pc= pc_buf;
   end
end
//
//interrupt buffer
always @(posedge clk or posedge rst)
  if (rst) begin
    int_buff1 <= 1'b0;
  end else begin
    int_buff1 <= int_buff;
  end
always @(posedge clk or posedge rst)
  if (rst) begin
    int_buff <= 1'b0;
  end else if (intr) begin
    int_buff <= 1'b1;
  end else if (pc_wait)
    int_buff <= 1'b0;
wire [7:0]  pcs_source;
reg  [15:0] pcs_result;
reg         pcs_cy;
assign pcs_source = pc_wr_sel[0] ? op3_out : op2_out;
always @(pcs_source or pc or pcs_cy)
begin
  if (pcs_source[7]) begin
    {pcs_cy, pcs_result[7:0]} = {1'b0, pc[7:0]} + {1'b0, pcs_source};
    pcs_result[15:8] = pc[15:8] - {7'h0, !pcs_cy};
  end else pcs_result = pc + {8'h00, pcs_source};
end
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    pc_buf <= `OC8051_RST_PC;
  end else begin
    if (pc_wr) begin
//
//case of writing new value to pc (jupms)
      case (pc_wr_sel)
        `OC8051_PIS_ALU: pc_buf        <= alu;
        `OC8051_PIS_AL:  pc_buf[7:0]   <= alu[7:0];
        `OC8051_PIS_AH:  pc_buf[15:8]  <= alu[7:0];
        `OC8051_PIS_I11: pc_buf[10:0]  <= {op1_out[7:5], op2_out};
        `OC8051_PIS_I16: pc_buf        <= {op2_out, op3_out};
        `OC8051_PIS_SO1: pc_buf        <= pcs_result;
        `OC8051_PIS_SO2: pc_buf        <= pcs_result;
      endcase
    end else
//
//or just remember current
      pc_buf <= pc;
  end
end
always @(posedge clk or posedge rst)
  if (rst)
    ddat_ir <= 8'h00;
  else if (dack_i)
    ddat_ir <= ddat_i;
*/
////////////////////////
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    rn_r      <= 5'd0;
    ri_r      <= 8'h00;
    imm_r     <= 8'h00;
    imm2_r    <= 8'h00;
    rd_addr_r <= 1'b0;
    op1_r     <= 8'h0;
    dack_ir   <= 1'b0;
    sp_r      <= 1'b0;
    pc_wr_r   <= 1'b0;
    pc_wr_r2  <= 1'b0;
  end else begin
    rn_r      <= rn;
    ri_r      <= ri;
    imm_r     <= imm;
    imm2_r    <= imm2;
    rd_addr_r <= rd_addr[7];
    op1_r     <= op1_out;
    dack_ir   <= dack_i;
    sp_r      <= sp;
    pc_wr_r   <= pc_wr && (pc_wr_sel != 3'b001);
    pc_wr_r2  <= pc_wr_r;
  end
end
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    inc_pc_r  <= 1'b1;
  end else if (istb) begin
    inc_pc_r  <= inc_pc;
  end
end

endmodule
