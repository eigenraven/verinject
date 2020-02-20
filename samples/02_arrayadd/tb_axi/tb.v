// Testbench interacting with the AXI driver
`timescale 1ns/1ps
`default_nettype none
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

reg [7:0] real_index_r;
reg [31:0] real_sum_r;

reg [7:0] inj_index_r;
reg [31:0] inj_sum_r;

reg [47:0] cycle_number_r;

//wire [7:0] xor_index;
wire [31:0] xor_sum;
wire [31:0] diff_sum;

//assign xor_index = real_index ^ xor_index;
assign xor_sum = real_sum_r ^ inj_sum_r;
assign diff_sum = (real_sum_r > inj_sum_r) ? (real_sum_r - inj_sum_r) : (inj_sum_r - real_sum_r);

top u_top(.clk(clock), .rst_n(rst_n), .run(run_designs), .index(real_index), .sum(real_sum));
top__injected i_top(.clk(clock), .rst_n(rst_n), .run(run_designs),
  .index(inj_index), .sum(inj_sum),
  .verinject__injector_state(verinject__injector_state)
);


initial begin
  rst_n = 1'b0;
  real_index_r = 8'b0;
  real_sum_r = 0;
  inj_index_r = 8'b0;
  inj_sum_r = 0;
  cycle_number_r = 0;
end

always @(posedge clock)
begin
  real_index_r <= real_index;
  real_sum_r <= real_sum;
  inj_index_r <= inj_index;
  inj_sum_r <= inj_sum;
  cycle_number_r <= cycle_number;

  rst_n <= run_designs;
  log_write = 1'b0;
  log_data = 64'bX;
  if (rst_n && xor_sum != 0)
  begin
    log_write = 1'b1;
    log_data = {cycle_number_r[31:0], xor_sum};
  end
end

endmodule

`default_nettype wire
