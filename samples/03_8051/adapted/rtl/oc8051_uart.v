//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores serial interface                                 ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   uart for 8051 core                                         ////
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
// Revision 1.14  2003/04/29 11:25:42  simont
// prepared start of receiving if ren is not active.
//
// Revision 1.13  2003/04/10 08:57:16  simont
// remove signal sbuf_txd [12:11]
//
// Revision 1.12  2003/04/07 14:58:02  simont
// change sfr's interface.
//
// Revision 1.11  2003/04/07 13:29:16  simont
// change uart to meet timing.
//
// Revision 1.10  2003/01/13 14:14:41  simont
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
module oc8051_uart (
input clk,
input rst,
input bit_in,
input wr,
input rxd,
input wr_bit,
input t1_ow,
input brate2,
input pres_ow,
input rclk,
input tclk,
input [7:0] data_in,
input [7:0] wr_addr,
output reg txd,
output intr,
output reg [7:0] scon,
output reg [7:0] pcon,
output [7:0] sbuf
);

reg t1_ow_buf;
//
reg trans;
reg receive;
reg tx_done;
reg rx_done;
reg rxd_r;
reg shift_tr;
reg shift_re;
reg [1:0]  rx_sam;
reg [3:0]  tr_count;
reg [3:0]  re_count;
reg [7:0]  sbuf_rxd;
reg [11:0] sbuf_rxd_tmp;
reg [10:0] sbuf_txd;
assign sbuf = sbuf_rxd;
assign intr = scon[1] | scon [0];
//
//serial port control register
//
wire ren;
wire tb8;
wire rb8;
wire ri;
assign ren = scon[4];
assign tb8 = scon[3];
assign rb8 = scon[2];
assign ri  = scon[0];

always @(posedge clk or posedge rst)
begin
  if (rst)
    scon <= 8'b0000_0000;
  else if ((wr) & !(wr_bit) & (wr_addr==8'h98))
    scon <= data_in;
  else if ((wr) & (wr_bit) & (wr_addr[7:3]==5'b10011))
    scon[wr_addr[2:0]] <= bit_in;
  else if (tx_done)
    scon[1] <= 1'b1;
  else if (!rx_done) begin
    if (scon[7:6]==2'b00) begin
      scon[0] <= 1'b1;
    end else if ((sbuf_rxd_tmp[11]) | !(scon[5])) begin
      scon[0] <= 1'b1;
      scon[2] <= sbuf_rxd_tmp[11];
    end else begin
      scon[2] <= sbuf_rxd_tmp[11];
    end
  end
end
//
//power control register
//
wire smod;
assign smod = pcon[7];
always @(posedge clk or posedge rst)
begin
  if (rst)
  begin
    pcon <= 8'b0000_0000;
  end else if ((wr_addr==8'h87) & (wr) & !(wr_bit)) begin
    pcon <= data_in;
  end
end
//
//serial port buffer (transmit)
//
wire wr_sbuf;
assign wr_sbuf = (wr_addr==8'h99) & (wr) & !(wr_bit);
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    txd      <= 1'b1;
    tr_count <= 4'd0;
    trans    <= 1'b0;
    sbuf_txd <= 11'h00;
    tx_done  <= 1'b0;
//
// start transmiting
//
  end else if (wr_sbuf) begin
    case (scon[7:6]) /* synopsys parallel_case */
      2'b00: begin  // mode 0
        sbuf_txd <= {3'b001, data_in};
      end
      2'b01: begin // mode 1
        sbuf_txd <= {2'b01, data_in, 1'b0};
      end
      default: begin  // mode 2 and mode 3
        sbuf_txd <= {1'b1, tb8, data_in, 1'b0};
      end
    endcase
    trans    <= 1'b1;
    tr_count <= 4'd0;
    tx_done  <= 1'b0;
//
// transmiting
//
  end else if (trans & (scon[7:6] == 2'b00) & pres_ow) // mode 0
  begin
    if (~|sbuf_txd[10:1]) begin
      trans   <= 1'b0;
      tx_done <= 1'b1;
    end else begin
      {sbuf_txd, txd} <= {1'b0, sbuf_txd};
      tx_done         <= 1'b0;
    end
  end else if (trans & (scon[7:6] != 2'b00) & shift_tr) begin // mode 1, 2, 3
    tr_count <= tr_count + 4'd1;
    if (~|tr_count) begin
      if (~|sbuf_txd[10:0]) begin
        trans   <= 1'b0;
        tx_done <= 1'b1;
        txd <= 1'b1;
      end else begin
        {sbuf_txd, txd} <= {1'b0, sbuf_txd};
        tx_done         <= 1'b0;
      end
    end
  end else if (!trans) begin
    txd     <= 1'b1;
    tx_done <= 1'b0;
  end
end
//
//
reg sc_clk_tr, smod_clk_tr;
always @*
begin
  if (scon[7:6]==8'b10) begin //mode 2
    sc_clk_tr = 1'b1;
  end else if (tclk) begin //
    sc_clk_tr = brate2;
  end else begin //
    sc_clk_tr = !t1_ow_buf & t1_ow;
  end
end

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    smod_clk_tr <= 1'b0;
    shift_tr    <= 1'b0;
  end else if (sc_clk_tr) begin
    if (smod) begin
      shift_tr <= 1'b1;
    end else begin
      shift_tr    <=  smod_clk_tr;
      smod_clk_tr <= !smod_clk_tr;
    end
  end else begin
    shift_tr <= 1'b0;
  end
end
//
//serial port buffer (receive)
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    re_count     <= 4'd0;
    receive      <= 1'b0;
    sbuf_rxd     <= 8'h00;
    sbuf_rxd_tmp <= 12'd0;
    rx_done      <= 1'b1;
    rxd_r        <= 1'b1;
    rx_sam       <= 2'b00;
  end else if (!rx_done) begin
    receive <= 1'b0;
    rx_done <= 1'b1;
    sbuf_rxd <= sbuf_rxd_tmp[10:3];
  end else if (receive & (scon[7:6]==2'b00) & pres_ow) begin //mode 0
    {sbuf_rxd_tmp, rx_done} <= {rxd, sbuf_rxd_tmp};
  end else if (receive & (scon[7:6]!=2'b00) & shift_re) begin //mode 1, 2, 3
    re_count <= re_count + 4'd1;
    case (re_count) /* synopsys full_case parallel_case */
      4'h7: begin rx_sam[0] <= rxd; end
      4'h8: begin rx_sam[1] <= rxd; end
      4'h9: begin
        {sbuf_rxd_tmp, rx_done} <= {(rxd==rx_sam[0] ? rxd : rx_sam[1]), sbuf_rxd_tmp};
      end
    endcase
//
//start receiving
//
  end else if (scon[7:6]==2'b00) begin //start mode 0
    rx_done <= 1'b1;
    if (ren && !ri && !receive) begin
      receive      <= 1'b1;
      sbuf_rxd_tmp <= 10'h0ff;
    end
  end else if (ren & shift_re) begin
    rxd_r <= rxd;
    rx_done <= 1'b1;
    re_count <= 4'h0;
    receive <= (rxd_r & !rxd);
    sbuf_rxd_tmp <= 10'h1ff;
  end else if (!ren) begin
    rxd_r <= rxd;
  end else begin
    rx_done <= 1'b1;
  end
end
//
//
reg sc_clk_re, smod_clk_re;
always @*
begin
  if (scon[7:6]==8'b10) begin //mode 2
    sc_clk_re = 1'b1;
  end else if (rclk) begin //
    sc_clk_re = brate2;
  end else begin //
    sc_clk_re = !t1_ow_buf & t1_ow;
  end
end
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    smod_clk_re <= 1'b0;
    shift_re    <= 1'b0;
  end else if (sc_clk_re) begin
    if (smod) begin
      shift_re <= 1'b1;
    end else begin
      shift_re    <=  smod_clk_re;
      smod_clk_re <= !smod_clk_re;
    end
  end else begin
    shift_re <= 1'b0;
  end
end
//
//
//
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    t1_ow_buf <= 1'b0;
  end else begin
    t1_ow_buf <= t1_ow;
  end
end
endmodule
