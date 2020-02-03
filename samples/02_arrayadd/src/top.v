module top(
  input clk,
  input run,
  output [7:0] index,
  output reg [31:0] sum
);

reg [31:0] memory_a [0:255];
reg [31:0] memory_b [0:255];
reg [31:0] memory_result [0:255];

reg [31:0] word_a;
reg [31:0] word_b;

reg [7:0] index_r;
reg [7:0] index_nxt;

assign index = index_r;

initial
begin
  index_r = 8'b0;
  sum = 32'b0;
  $readmemh("mem/memory_a.mem", memory_a);
  $readmemh("mem/memory_b.mem", memory_b);
  $readmemh("mem/memory_result.mem", memory_result);
end

always @*
begin
  if (run)
  begin
   index_nxt = index_r + 8'b1;
  end

  word_a = memory_a[index_r];
  word_b = memory_b[index_r];
  sum = word_a + word_b;

end

always @(posedge clk)
begin
  if (run)
  begin
    memory_result[index_r] <= sum;
    index_r <= index_nxt;
  end
end

endmodule

