// Testbench interacting with the AXI driver
`timescale 1ns/1ps
module tb(
  input wire clock,
  input wire [31:0] verinject__injector_state,
  input wire [47:0] cycle_number,
  input wire run_designs,
  output reg log_write,
  output reg [63:0] log_data
);

localparam TOTAL_BITS = 24584;

reg rst_n;

wire [7:0] real_index;
wire [31:0] real_sum;

wire [7:0] inj_index;
wire [31:0] inj_sum;

//wire [7:0] xor_index;
wire [31:0] xor_sum;
wire [31:0] diff_sum;

//assign xor_index = real_index ^ xor_index;
assign xor_sum = real_sum ^ inj_sum;
assign diff_sum = (real_sum > inj_sum) ? (real_sum - inj_sum) : (inj_sum - real_sum);

top u_top(.clk(clk), .rst_n(rst_n), .run(run_designs), .index(real_index), .sum(real_sum));
top__injected i_top(.clk(clk), .rst_n(rst_n), .run(run_designs),
  .index(inj_index), .sum(inj_sum),
  .verinject__injector_state(verinject__injector_state)
);


initial begin
    rst_n = 1'b0;
end

always @*
begin
  rst_n = run_designs;
  log_write = 1'b0;
  log_data = 64'bX;
  if (run_designs && xor_sum != 0)
  begin
    log_write = 1'b1;
    log_data = {cycle_number[31:0], xor_sum};
  end
end

endmodule