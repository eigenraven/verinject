module simple_ff(
  input clk,
  input dat,
  output val
);

reg val_r;
simple_comb_neg u_val_setter(
  .i(val_r),
  .o(val)
);

always @(posedge clk)
  val_r <= dat;

endmodule