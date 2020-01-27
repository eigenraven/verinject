module simple_multiple(
  input clk,
  input dat,
  output reg val
);

reg [1:0] ff1;
reg [1:0] ff2;
reg [1:0] mem [0:1];
reg ff3;

always @(posedge clk)
begin
  ff1 <= {1'b0, dat};
  ff2 <= {dat, 1'b0};
  ff3 <= ~dat;
  mem[dat] <= {dat, ~dat};
  val <= mem[~dat][0];
end

endmodule