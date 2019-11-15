`timescale 1ns/1ps
module tb;

reg clk;
reg [31:0] inject_state;

top u_top(.clk(clk));
top__injected i_top(.clk(clk), .verinject__injector_state(inject_state));

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;
    clk = 1'b0;
    inject_state = 0;
end

initial forever #10 clk = ~clk;
initial forever #30 inject_state = (inject_state + 1) & (64-1);
initial #10000 $finish();

endmodule