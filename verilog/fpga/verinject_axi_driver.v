////////////////////////////////////////////////////////////////////////////////
//	Note that the AXI spec requires that there be no combinatorial
//	logic between input ports and output ports.  Hence all of the *valid
//	and *ready signals produced here are registered.  This forces us into
//	the buffered handshake strategy.
//
//	Some curious variable meanings below:
//
//	!axi_arvalid is synonymous with having a request, but stalling because
//		of a current request sitting in axi_rvalid with !axi_rready
//	!axi_awvalid is also synonymous with having an axi address being
//		received, but either the axi_bvalid && !axi_bready, or
//		no write data has been received
//	!axi_wvalid is similar to axi_awvalid.
//
// Template Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
// Original template license notice:
//
// Copyright (C) 2018-2019, Gisselquist Technology, LLC
//
// This file is part of the WB2AXIP project.
//
// The WB2AXIP project contains free software and gateware, licensed under the
// Apache License, Version 2.0 (the "License").  You may not use this project,
// or this file, except in compliance with the License.  You may obtain a copy
// of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//
////////////////////////////////////////////////////////////////////////////////
//
`default_nettype none
/* verilator lint_off WIDTH */
`timescale 1 ns / 1 ps

module	verinject_axi_driver
  #(
    // Users to add parameters here
    parameter [0:0] OPT_READ_SIDEEFFECTS = 1,
    parameter integer LOG_QWORDS = 128,
    parameter integer LOG_QWORDS_LOG2 = 7,
    // User parameters ends
    // Do not modify the parameters beyond this line
    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH	= 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH	= 16
  ) (
    // Users ports begin
    // Data to append to log
    input wire [63:0] log_data,
    // Enables appending the above data in current clock cycle
    input wire log_write,
    // Bit id to inject a fault into, or all 1's if no fault currently injected, 32'hFFFF_FFFE if injector reset requested
    output wire [31:0] verinject__injector_state,
    // Current cycle number
    output wire [47:0] cycle_number,
    // Asserted when target design is requested to run by the host
    output wire run_designs,
    // User ports ends

    // Do not modify the ports beyond this line
    // Global Clock Signal
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
      // privilege and security level of the transaction, and whether
      // the transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master
    // signaling valid write address and control information.
    input wire  S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave
    // is ready to accept an address and associated control signals.
    output wire  S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave)
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
      // valid data. There is one write strobe bit for each eight
      // bits of the write data bus.
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
      // data and strobes are available.
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
      // can accept the write data.
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
      // of the write transaction.
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
      // is signaling a valid write response.
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
      // can accept a write response.
    input wire  S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
      // and security level of the transaction, and whether the
      // transaction is a data access or an instruction access.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
      // is signaling valid read address and control information.
    input wire  S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
      // ready to accept an address and associated control signals.
    output wire  S_AXI_ARREADY,
    // Read data (issued by slave)
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. This signal indicates the status of the
      // read transfer.
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
      // signaling the required read data.
    output wire  S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
      // accept the read data and response information.
    input wire  S_AXI_RREADY
  );

  // AXI4LITE signals
  reg		axi_awready;
  reg		axi_wready;
  reg		axi_bvalid;
  reg		axi_arready;
  reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
  reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata_nxt;
  reg		axi_rvalid;

  // Example-specific design signals
  // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  // ADDR_LSB is used for addressing 32/64 bit registers/memories
  // ADDR_LSB = 2 for 32 bits (n downto 2)
  // ADDR_LSB = 3 for 64 bits (n downto 3)
  localparam integer ADDR_LSB = 2;
  localparam integer AW = C_S_AXI_ADDR_WIDTH-2;
  localparam integer DW = C_S_AXI_DATA_WIDTH;
  integer ii;

  localparam [31:0] REGID_LOG_QWORD_COUNT = 0;
  localparam [31:0] REGID_TRACE_QWORD_COUNT = 1;
  localparam [31:0] REGID_CYCLE_NUMBER = 2;
  localparam [31:0] REGID_RUNNING = 3; // 0 - not ran, 1 - running/start, 2 - stopped
  localparam [31:0] REGID_STOP_CYCLE_NUMBER = 4; // 0 - don't stop
  localparam [31:0] REGID_LOG_POSITION = 5;
  localparam [31:0] REGID_TRACE_POSITION = 6;
  localparam [31:0] REGID_LOG_DATA = 8;
  localparam [31:0] REGID_TRACE_DATA = REGID_LOG_DATA + LOG_QWORDS*2;
  localparam [31:0] REGID_TRACE_DATA_END = REGID_LOG_DATA + LOG_QWORDS*2 + 2048;
  //----------------------------------------------
  //-- Signals for user logic register space example
  //------------------------------------------------
  reg [63:0] log_mem [0:LOG_QWORDS-1];
  reg [63:0] trace_mem [0:1023];

  reg [LOG_QWORDS_LOG2:0] log_wptr_r;
  initial log_wptr_r = 0;
  reg [9:0] trace_ptr_r;
  reg [9:0] trace_ptr_nxt;
  initial trace_ptr_r = 0;
  reg [47:0] cycle_r;
  initial cycle_r = 0;
  reg [31:0] stop_cycle_r;
  initial stop_cycle_r = 0;
  reg run_designs_r;
  initial run_designs_r = 0;
  reg stopped_r;
  initial stopped_r = 0;

  wire [LOG_QWORDS_LOG2-1:0] log_read_idx;
  assign log_read_idx = rd_addr[AW+ADDR_LSB-1:3] - REGID_LOG_DATA;
  wire [LOG_QWORDS_LOG2-1:0] log_write_idx;
  assign log_write_idx = waddr[AW+ADDR_LSB-1:3] - REGID_LOG_DATA;
  wire [63:0] log_read_word;
  assign log_read_word = log_mem[log_read_idx];

  wire [9:0] trace_axiread_idx;
  assign trace_axiread_idx = rd_addr[AW+ADDR_LSB-1:3] - REGID_TRACE_DATA;
  wire [9:0] trace_axiwrite_idx;
  assign trace_axiwrite_idx = waddr[AW+ADDR_LSB-1:3] - REGID_TRACE_DATA;
  wire [63:0] trace_axiread_word;
  assign trace_axiread_word = trace_mem[trace_axiread_idx];
  
  wire [63:0] trace_read;
  wire trace_here;
  assign trace_read = trace_mem[trace_ptr_r];
  assign trace_here = trace_read[63:32] == cycle_r;
  assign verinject__injector_state = trace_here ? trace_read[31:0] : 32'hFFFFFFFF;
  assign cycle_number = cycle_r;
  assign run_designs = run_designs_r;

  initial
  begin
    for (ii = 0; ii < LOG_QWORDS; ii=ii+1)
      log_mem[ii] = 64'b0;
    for (ii = 0; ii < 1024; ii=ii+1)
      trace_mem[ii] = ~64'b0;
  end

  always @*
  begin
    trace_ptr_nxt = trace_ptr_r;
    if (run_designs_r && !stopped_r && trace_here && !(&trace_ptr_r)) // avoid overflow
    begin
      trace_ptr_nxt += 1;
    end
  end

  always @(posedge S_AXI_ACLK)
  begin
    cycle_r <= cycle_r + 1;
    trace_ptr_r <= trace_ptr_nxt;
    if (trace_read[63:32] == 32'hFFFF_FFFF)
    begin
      stopped_r <= 1'b1;
    end
    if (stop_cycle_r != 0 && cycle_r >= stop_cycle_r)
    begin
      stopped_r <= 1'b1;
      run_designs_r <= 1'b0;
    end
    if (log_write)
    begin
      log_mem[log_wptr_r] <= log_data;
      log_wptr_r <= log_wptr_r + 1;
    end
  end


  // I/O Connections assignments

  assign S_AXI_AWREADY	= axi_awready;
  assign S_AXI_WREADY	= axi_wready;
  assign S_AXI_BRESP	= 2'b00; // The OKAY response
  assign S_AXI_BVALID	= axi_bvalid;
  assign S_AXI_ARREADY	= axi_arready;
  assign S_AXI_RDATA	= axi_rdata;
  assign S_AXI_RRESP	= 2'b00; // The OKAY response
  assign S_AXI_RVALID	= axi_rvalid;
  // Implement axi_*wready generation

  //////////////////////////////////////
  //
  // Read processing
  //
  //
  wire	valid_read_request,
    read_response_stall;

  assign	valid_read_request  =  S_AXI_ARVALID || !S_AXI_ARREADY;
  assign	read_response_stall =  S_AXI_RVALID  && !S_AXI_RREADY;

  //
  // The read response channel valid signal
  //
  initial	axi_rvalid = 1'b0;
  always @( posedge S_AXI_ACLK )
  if (!S_AXI_ARESETN)
    axi_rvalid <= 0;
  else if (read_response_stall)
    // Need to stay valid as long as the return path is stalled
    axi_rvalid <= 1'b1;
  else if (valid_read_request)
    axi_rvalid <= 1'b1;
  else
    // Any stall has cleared, so we can always
    // clear the valid signal in this case
    axi_rvalid <= 1'b0;

  reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	pre_raddr, rd_addr;

  // Buffer the address
  always @(posedge S_AXI_ACLK)
  if (S_AXI_ARREADY)
    pre_raddr <= S_AXI_ARADDR;

  always @(*)
  if (!axi_arready)
    rd_addr = pre_raddr;
  else
    rd_addr = S_AXI_ARADDR;

  //
  // Read the data
  //
  always @*
  begin
    // axi_rdata_nxt = slv_mem[rd_addr];
    axi_rdata_nxt = 0;
    case (rd_addr[AW+ADDR_LSB-1:ADDR_LSB])
      REGID_LOG_QWORD_COUNT : axi_rdata_nxt = LOG_QWORDS;
      REGID_TRACE_QWORD_COUNT : axi_rdata_nxt = 1024;
      REGID_CYCLE_NUMBER : axi_rdata_nxt = cycle_r[31:0];
      REGID_RUNNING : axi_rdata_nxt = {30'b0, stopped_r, run_designs_r};
      REGID_STOP_CYCLE_NUMBER : axi_rdata_nxt = stop_cycle_r;
      REGID_LOG_POSITION : axi_rdata_nxt = log_wptr_r;
    endcase
    if (rd_addr[AW+ADDR_LSB-1:ADDR_LSB] >= REGID_LOG_DATA && rd_addr[AW+ADDR_LSB-1:ADDR_LSB] < REGID_TRACE_DATA)
    begin
      axi_rdata_nxt = rd_addr[2] ? log_read_word[63:32] : log_read_word[31:0];
    end
    if (rd_addr[AW+ADDR_LSB-1:ADDR_LSB] >= REGID_TRACE_DATA && rd_addr[AW+ADDR_LSB-1:ADDR_LSB] < REGID_TRACE_DATA_END)
    begin
      axi_rdata_nxt = rd_addr[2] ? trace_axiread_word[63:32] : trace_axiread_word[31:0];
    end
  end

  always @(posedge S_AXI_ACLK)
  if (!read_response_stall
    &&(!OPT_READ_SIDEEFFECTS || valid_read_request))
    // If the outgoing channel is not stalled (above)
    // then read
  begin
    axi_rdata <= axi_rdata_nxt;
  end

  //
  // The read address channel ready signal
  //
  initial	axi_arready = 1'b0;
  always @(posedge S_AXI_ACLK)
  if (!S_AXI_ARESETN)
    axi_arready <= 1'b1;
  else if (read_response_stall)
  begin
    // Outgoing channel is stalled
    //  As long as something is already in the buffer,
    //  axi_arready needs to stay low
    axi_arready <= !valid_read_request;
  end else
    axi_arready <= 1'b1;

  //////////////////////////////////////
  //
  // Write processing
  //
  //
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]		pre_waddr, waddr;
  reg [C_S_AXI_DATA_WIDTH-1 : 0]		pre_wdata, wdata;
  reg [(C_S_AXI_DATA_WIDTH/8)-1 : 0]	pre_wstrb, wstrb;

  wire	valid_write_address, valid_write_data,
    write_response_stall;

  assign	valid_write_address = S_AXI_AWVALID || !axi_awready;
  assign	valid_write_data  = S_AXI_WVALID  || !axi_wready;
  assign	write_response_stall= S_AXI_BVALID  && !S_AXI_BREADY;

  //
  // The write address channel ready signal
  //
  initial	axi_awready = 1'b1;
  always @(posedge S_AXI_ACLK)
  if (!S_AXI_ARESETN)
    axi_awready <= 1'b1;
  else if (write_response_stall)
  begin
    // The output channel is stalled
    //	If our buffer is full, we need to remain stalled
    //	Likewise if it is empty, and there's a request,
    //	  we'll need to stall.
    axi_awready <= !valid_write_address;
  end else if (valid_write_data)
    // The output channel is clear, and write data
    // are available
    axi_awready <= 1'b1;
  else
    // If we were ready before, then remain ready unless an
    // address unaccompanied by data shows up
    axi_awready <= ((axi_awready)&&(!S_AXI_AWVALID));
    // This is equivalent to
    // axi_awready <= !valid_write_address

  //
  // The write data channel ready signal
  //
  initial	axi_wready = 1'b1;
  always @(posedge S_AXI_ACLK)
  if (!S_AXI_ARESETN)
    axi_wready <= 1'b1;
  else if (write_response_stall)
    // The output channel is stalled
    //	We can remain ready until valid
    //	write data shows up
    axi_wready <= !valid_write_data;
  else if (valid_write_address)
    // The output channel is clear, and a write address
    // is available
    axi_wready <= 1'b1;
  else
    // if we were ready before, and there's no new data avaialble
    // to cause us to stall, remain ready
    axi_wready <= (axi_wready)&&(!S_AXI_WVALID);
    // This is equivalent to
    // axi_wready <= !valid_write_data


  // Buffer the address
  always @(posedge S_AXI_ACLK)
  if (S_AXI_AWREADY)
    pre_waddr <= S_AXI_AWADDR;

  // Buffer the data
  always @(posedge S_AXI_ACLK)
  if (S_AXI_WREADY)
  begin
    pre_wdata <= S_AXI_WDATA;
    pre_wstrb <= S_AXI_WSTRB;
  end

  always @(*)
  if (!axi_awready)
    // Read the write address from our "buffer"
    waddr = pre_waddr;
  else
    waddr = S_AXI_AWADDR;

  always @(*)
  if (!axi_wready)
  begin
    // Read the write data from our "buffer"
    wstrb = pre_wstrb;
    wdata = pre_wdata;
  end else begin
    wstrb = S_AXI_WSTRB;
    wdata = S_AXI_WDATA;
  end

  //
  // Actually (finally) write the data
  //
  always @( posedge S_AXI_ACLK )
  // If the output channel isn't stalled, and
  if (!write_response_stall
    // If we have a valid address, and
    && valid_write_address
    // If we have valid data
    && valid_write_data)
  begin
    for (ii = 0; ii < 4; ii = ii + 1)
    begin
      if (wstrb[ii])
      begin
        // slv_mem[waddr[AW+ADDR_LSB-1:ADDR_LSB]][8*ii+7:8*ii] <= wdata[8*ii+7:8*ii];
        case (waddr[AW+ADDR_LSB-1:ADDR_LSB])
          // REGID_LOG_QWORD_COUNT : Read-only
          // REGID_TRACE_QWORD_COUNT : Read-only
          REGID_CYCLE_NUMBER : cycle_r[8*ii +: 8] <= wdata[8*ii +: 8];
          REGID_RUNNING : if (ii == 0) {stopped_r, run_designs_r} <= wdata[1:0];
          REGID_STOP_CYCLE_NUMBER : stop_cycle_r[8*ii +: 8] <= wdata[8*ii +: 8];
          REGID_LOG_POSITION : log_wptr_r[8*ii +: 8] <= wdata[8*ii +: 8];
        endcase
        if (waddr[AW+ADDR_LSB-1:ADDR_LSB] >= REGID_LOG_DATA && waddr[AW+ADDR_LSB-1:ADDR_LSB] < REGID_TRACE_DATA)
        begin
          if (waddr[2])
            log_mem[log_write_idx][32+8*ii +: 8] <= wdata[8*ii +: 8];
          else
            log_mem[log_write_idx][8*ii +: 8] <= wdata[8*ii +: 8];
        end
        if (waddr[AW+ADDR_LSB-1:ADDR_LSB] >= REGID_TRACE_DATA && waddr[AW+ADDR_LSB-1:ADDR_LSB] < REGID_TRACE_DATA_END)
        begin
          if (waddr[2])
            trace_mem[trace_axiwrite_idx][32+8*ii +: 8] <= wdata[8*ii +: 8];
          else
            trace_mem[trace_axiwrite_idx][8*ii +: 8] <= wdata[8*ii +: 8];
        end
      end
    end
  end

  //
  // The write response channel valid signal
  //
  initial	axi_bvalid = 1'b0;
  always @( posedge S_AXI_ACLK )
  if (!S_AXI_ARESETN)
    axi_bvalid <= 1'b0;
  //
  // The outgoing response channel should indicate a valid write if ...
    // 1. We have a valid address, and
  else if (valid_write_address
      // 2. We had valid data
      && valid_write_data)
    // It doesn't matter here if we are stalled or not
    // We can keep setting ready as often as we want
    axi_bvalid <= 1'b1;
  else if (S_AXI_BREADY)
    // Otherwise, if BREADY was true, then it was just accepted
    // and can return to idle now
    axi_bvalid <= 1'b0;

  // Make Verilator happy
  // Verilator lint_off UNUSED
  wire	[4*ADDR_LSB+5:0]	unused;
  assign	unused = { S_AXI_AWPROT, S_AXI_ARPROT,
        S_AXI_AWADDR[ADDR_LSB-1:0],
        rd_addr[ADDR_LSB-1:0],
        waddr[ADDR_LSB-1:0],
        S_AXI_ARADDR[ADDR_LSB-1:0] };
  // Verilator lint_on UNUSED

endmodule
`ifndef	YOSYS
`default_nettype wire
`endif
