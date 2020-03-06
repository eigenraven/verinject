// Define VERINJECT_SELU_LATCH_UP for a latch-up or nothing for a latch-down

module verinject_ff_injector
#(parameter LEFT = 0, parameter RIGHT = 0, parameter P_START = 0)
(
  input clock,
  input do_write,
  input [LEFT:RIGHT] unmodified,
  output [LEFT:RIGHT] modified,
  input [31:0] verinject__injector_state
);

localparam bits_start = (LEFT < RIGHT) ? LEFT : RIGHT;
localparam word_len = (LEFT < RIGHT) ? (RIGHT - LEFT + 1) : (LEFT - RIGHT + 1);

reg [LEFT:RIGHT] modifier_r;
reg [LEFT:RIGHT] modifier_nxt;

`ifdef VERINJECT_SELU_LATCH_UP
assign modified = unmodified | modifier_nxt;
`else
assign modified = unmodified & ~modifier_nxt;
`endif

wire reset_buffer;
assign reset_buffer = (verinject__injector_state == 32'hFFFF_FFFE);

initial
begin
  modifier_r <= 0;
end

always @(posedge clock)
begin
  modifier_r <= modifier_nxt;
end

always @*
begin
  modifier_nxt = modifier_r;
  if (reset_buffer)
  begin
    modifier_nxt = 0;
  end
  if (verinject__injector_state >= P_START && verinject__injector_state < (P_START + word_len))
  begin
    modifier_nxt = modifier_nxt ^ (1 << (verinject__injector_state - P_START + bits_start));
  end
end

endmodule
