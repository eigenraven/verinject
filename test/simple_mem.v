module simple_mem(
  input clk,
  input [9:0] raddr,
  input [9:0] waddr,
  input [31:0] wrword,
  output reg [31:0] rdword
);

reg [31:0] word_memory [0:1023];

always @*
begin
  rdword = word_memory[raddr];
end

always @(posedge clk)
begin
  word_memory[waddr] <= wrword;
end

endmodule
