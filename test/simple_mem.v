module simple_mem(
  input clk,
  input [9:0] addr,
  output [31:0] memword
);

reg [31:0] word_memory [0:1023];
reg [31:0] outword;

assign memword = outword;

always @(posedge clk)
begin
  outword <= word_memory[addr];
end

endmodule
