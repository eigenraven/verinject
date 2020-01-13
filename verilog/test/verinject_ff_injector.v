module verinject_ff_injector
#(parameter LEFT = 0, parameter RIGHT = 0, parameter P_START = 0)
(
  input clock,
  input do_write,
  input [LEFT:RIGHT] unmodified,
  output reg [LEFT:RIGHT] modified,
  input [31:0] verinject__injector_state
);

localparam bits_start = (LEFT < RIGHT) ? LEFT : RIGHT;
localparam word_len = (LEFT < RIGHT) ? (RIGHT - LEFT + 1) : (LEFT - RIGHT + 1);

reg [LEFT:RIGHT] xor_modifier;

always @*
begin : fault_injection
  modified = unmodified;
  if (verinject__injector_state >= P_START && verinject__injector_state < (P_START + word_len))
  begin
    xor_modifier = (1 << (verinject__injector_state - P_START + bits_start));
    modified = unmodified ^ xor_modifier;
  end
end

endmodule
