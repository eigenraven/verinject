
// A very simple test of the 8051 core

`timescale 1ns/100ps

module tb;

reg clk;
reg rst;

reg int0_i = 0;
reg int1_i = 0;
reg ea_in = 0;
wire wbd_we_o, wbd_stb_o, wbd_cyc_o, wbi_stb_o, wbi_cyc_o;
wire [7:0] wbd_dat_o;
wire [15:0] wbd_adr_o;
wire [15:0] wbi_adr_o;
reg [7:0] p0_i = 0;
reg [7:0] p1_i = 0;
reg [7:0] p2_i = 0;
reg [7:0] p3_i = 0;
wire [7:0] p0_o;
wire [7:0] p1_o;
wire [7:0] p2_o;
wire [7:0] p3_o;
reg rxd_i = 0;
wire txd_o;
reg t0_i = 0;
reg t1_i = 0;
reg t2_i = 0;
reg t2ex_i = 0;

reg wbd_ack_i = 0;
reg wbi_ack_i = 0;
reg wbd_err_i = 0;
reg wbi_err_i = 0;
reg [7:0] wbd_dat_i = 0;
reg [31:0] wbi_dat_i = 0;

reg [7:0] imem [0:302];

initial $readmemh("asm/fib.in", imem, 0, 302);

always @*
begin
    if (wbi_adr_o < 303) begin
        wbi_dat_i = {imem[wbi_adr_o+3],imem[wbi_adr_o+2],imem[wbi_adr_o+1],imem[wbi_adr_o]};
        //wbi_dat_i = {imem[wbi_adr_o],imem[wbi_adr_o+1],imem[wbi_adr_o+2],imem[wbi_adr_o+3]};
    end else begin
        wbi_dat_i = 32'h0;
    end
end

always @(posedge clk)
begin
    wbd_ack_i <= wbd_stb_o;
    wbi_ack_i <= wbi_stb_o;
end

always @(negedge clk)
begin
    if (wbd_we_o)
    begin
        $display("Write to %x: %x", wbd_adr_o, wbd_dat_o);
    end else if (wbd_cyc_o)
    begin
        $display("Read from %x", wbd_adr_o);
    end
end

always @(p0_o)
begin
    $display("Change to p0: %x", p0_o);
end
always @(p1_o)
begin
    $display("Change to p1: %x", p1_o);
end
always @(p2_o)
begin
    $display("Change to p2: %x", p2_o);
end
always @(p3_o)
begin
    $display("Change to p3: %x", p3_o);
end

oc8051_top top (
/* input */ .wb_clk_i(clk),  // clock input
/* input */ .wb_rst_i(rst),  // reset input
/* input */ .int0_i(int0_i),  // interrupt 0
/* input */ .int1_i(int1_i),  // interrupt 1
/* input */ .ea_in(ea_in),   // external access
/* input */ .wbd_ack_i(wbd_ack_i),   // data acknowalge
/* input */ .wbi_ack_i(wbi_ack_i),   // instruction acknowlage
/* input */ .wbd_err_i(wbd_err_i),   // data error
/* input */ .wbi_err_i(wbi_err_i),   // instruction error
/* input [7:0]   */ .wbd_dat_i(wbd_dat_i),   // ram data input
/* input [31:0]  */ .wbi_dat_i(wbi_dat_i),   // rom data input
/* output */ .wbd_we_o(wbd_we_o),  // data write enable
/* output */ .wbd_stb_o(wbd_stb_o),   // data strobe
/* output */ .wbd_cyc_o(wbd_cyc_o),   // data cycle
/* output */ .wbi_stb_o(wbi_stb_o),   // instruction strobe
/* output */ .wbi_cyc_o(wbi_cyc_o),   // instruction cycle
/* output [7:0]  */ .wbd_dat_o(wbd_dat_o),   // data output
/* output [15:0] */ .wbd_adr_o(wbd_adr_o),   // data address
/* output [15:0] */ .wbi_adr_o(wbi_adr_o),   // instruction address
/* input  [7:0]  */ .p0_i(p0_i),  // port 0 input
/* output [7:0]  */ .p0_o(p0_o),  // port 0 output
/* input  [7:0]  */ .p1_i(p1_i),  // port 1 input
/* output [7:0]  */ .p1_o(p1_o),  // port 1 output
/* input  [7:0]  */ .p2_i(p2_i),  // port 2 input
/* output [7:0]  */ .p2_o(p2_o),  // port 2 output
/* input  [7:0]  */ .p3_i(p3_i),  // port 3 input
/* output [7:0]  */ .p3_o(p3_o),  // port 3 output
/* input */ .rxd_i(rxd_i),   // receive
/* output */ .txd_o(txd_o),   // transnmit
/* input */ .t0_i(t0_i),  // counter 0 input
/* input */ .t1_i(t1_i),  // counter 1 input
/* input */ .t2_i(t2_i),  // counter 2 input
/* input */ .t2ex_i(t2ex_i)  //
);

initial forever #5 clk = ~clk;

initial
begin
    $dumpfile("wave_iotest.vcd");
    $dumpvars;
    clk = 0;
    rst = 1;
    #100 rst=0;
    #1000000 $finish();
end

endmodule
