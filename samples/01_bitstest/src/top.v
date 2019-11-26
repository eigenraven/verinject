module top(
  input clk
);

reg [31:0] all_zeros;
reg [31:0] neg_zeros;
reg [7:0] memory [0:3];
reg [7:0] mword;

initial
begin
  memory[0] <= 8'b0;
  memory[1] <= 8'b0;
  memory[2] <= 8'b0;
  memory[3] <= 8'b0;
end

always @*
begin
  mword = memory[1];
end

always @(posedge clk)
begin
  all_zeros <= 32'b0;
  neg_zeros <= ~all_zeros;
  memory[all_zeros[1:0]] <= all_zeros[15:8];
end

endmodule