`timescale 1ns/1ps
module tb;

localparam TOTAL_BITS = 24584;

reg clk;
reg run;
reg rst_n;
wire [31:0] verinject__injector_state;

wire [7:0] real_index;
wire [31:0] real_sum;

wire [7:0] inj_index;
wire [31:0] inj_sum;

top u_top(.clk(clk), .rst_n(rst_n), .run(run), .index(real_index), .sum(real_sum));
top__injected i_top(.clk(clk), .rst_n(rst_n), .run(run),
  .index(inj_index), .sum(inj_sum),
  .verinject__injector_state(verinject__injector_state)
);

wire [47:0] cycle_number;
verinject_file_tester u_injector(
  .clock(clk),
  .reset_n(rst_n),
  .verinject__injector_state(verinject__injector_state),
  .cycle_number(cycle_number)
);

verinject_sim_monitor u_inject_monitor(
  .clock(clk),
  .verinject__injector_state(verinject__injector_state),
  .cycle_number(cycle_number)
);

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;
    clk = 1'b0;
    rst_n = 1'b1;
    run = 1'b1;
    #2560 $finish();
end

initial forever #5 clk = ~clk;

always @(negedge clk)
begin
  if (real_index != inj_index)
  begin
    $display("Index mismatch at cycle %d: real(%d) != injected(%d) xor(%08x)", cycle_number, real_index, inj_index, real_index ^ inj_index);
  end
  if (real_sum != inj_sum)
  begin
    $display("Sum mismatch at cycle %d: real(%08x) != injected(%08x) xor(%08x) absdifference(%08x)",
      cycle_number, real_sum, inj_sum,
      real_sum ^ inj_sum,
      (real_sum > inj_sum) ? (real_sum - inj_sum) : (inj_sum - real_sum));
  end
end

endmodule