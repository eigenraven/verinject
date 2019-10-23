module simple_ff2(
  input clk, input dat, output val);

reg val_r; // this is a flip-flop
reg val_next;
reg other_val;

always @*
begin
  val_next = dat ^ val_r;
  other_val = val_next & val_r;
end

always @(posedge clk)
  val_r <= val_next;

endmodule