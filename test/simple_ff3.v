module simple_ff3(
  input clk,
  input dat,
  output reg [2:0] val_r
);

always @(posedge clk)
begin
  val_r[0] <= dat;
  val_r[2:1] <= {dat,~dat};
end

endmodule