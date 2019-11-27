`timescale 1ns/1ps
module tb;

localparam TOTAL_BITS = 96;

reg clk;
reg rst_n;
wire [31:0] verinject__injector_state;

top u_top(.clk(clk));
top__injected i_top(.clk(clk), .verinject__injector_state(verinject__injector_state));

verinject_serial_tester #(.TOTAL_BITS(TOTAL_BITS)) u_injector(
  .clock(clk),
  .reset_n(rst_n),
  .verinject__injector_state(verinject__injector_state)
);

wire [47:0] cycle_number;
verinject_sim_monitor #(.TOTAL_BITS(TOTAL_BITS)) u_inject_monitor(
  .clock(clk),
  .verinject__injector_state(verinject__injector_state),
  .cycle_number(cycle_number)
);

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;
    clk = 1'b0;
    rst_n = 1'b1;
    #10000 $finish();
end

initial forever #10 clk = ~clk;

endmodule