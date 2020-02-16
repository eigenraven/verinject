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

reg [LEFT:RIGHT] xor_modifier_r;
reg [LEFT:RIGHT] xor_modifier_nxt;

assign modified = unmodified ^ xor_modifier_nxt;

wire reset_buffer;
assign reset_buffer = (verinject__injector_state == 32'hFFFF_FFFE);

initial
begin
  xor_modifier_r <= 0;
end

always @(posedge clock)
begin
  xor_modifier_r <= xor_modifier_nxt;
end

always @*
begin
  xor_modifier_nxt = xor_modifier_r;
  if (do_write || reset_buffer)
  begin
    xor_modifier_nxt = 0;
  end
  if (verinject__injector_state >= P_START && verinject__injector_state < (P_START + word_len))
  begin
    xor_modifier_nxt ^= (1 << (verinject__injector_state - P_START + bits_start));
  end
end

endmodule
