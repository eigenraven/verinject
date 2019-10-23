module simple_ff2(
  input clk,
  input dat,
  output reg val_r
);

always @(posedge clk)
  val_r <= dat;

endmodule;