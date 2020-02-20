
`ifndef MEMORY_A_FILE
`define MEMORY_A_FILE "mem/memory_a.mem"
`define MEMORY_B_FILE "mem/memory_b.mem"
`endif

module top(
  input clk,
  input rst_n,
  input run,
  output [7:0] index,
  output reg [31:0] sum
);

reg [31:0] memory_a [0:255];
reg [31:0] memory_b [0:255];

reg [31:0] word_a;
reg [31:0] word_b;

reg [7:0] index_r;
reg [7:0] index_nxt;

assign index = index_r;

initial
begin
  index_r = 8'b0;
  sum = 32'b0;
  $readmemh(`MEMORY_A_FILE, memory_a);
  $readmemh(`MEMORY_B_FILE, memory_b);
end

always @*
begin
  index_nxt = index_r;
  if (run)
  begin
   index_nxt = index_r + 8'b1;
  end

  word_a = memory_a[index_r];
  word_b = memory_b[index_r];
  sum = word_a + word_b;

end

always @(posedge clk, negedge rst_n)
begin
  if (!rst_n)
  begin
    index_r <= 0;
  end else if (run)
  begin
    index_r <= index_nxt;
  end
end

endmodule

