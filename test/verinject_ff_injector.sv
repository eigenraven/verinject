module verinject_ff_injector
#(parameter LEFT = 0, parameter RIGHT = 0)
(
  input [LEFT:RIGHT] unmodified,
  output [LEFT:RIGHT] modified
);

assign modified = unmodified;

endmodule