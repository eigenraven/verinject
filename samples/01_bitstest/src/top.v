module top(
  input clk
);

reg [31:0] all_zeros;
reg [31:0] neg_zeros;

always @(posedge clk)
begin
  all_zeros <= 32'b0;
  neg_zeros <= ~all_zeros;
end

endmodule