module verinject_ff_injector
#(parameter LEFT = 0, parameter RIGHT = 0, parameter D_START = 0)
(
  input [31:0] verinject__injector_state,
  input [LEFT:RIGHT] unmodified,
  output [LEFT:RIGHT] modified
);

assign modified = unmodified;

endmodule