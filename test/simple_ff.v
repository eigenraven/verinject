module simple_ff(
  input clk,
  input dat,
  output val
);

reg val_r;
assign val = val_r;

always @(posedge clk)
  val_r <= dat;

endmodule