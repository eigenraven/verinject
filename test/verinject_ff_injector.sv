module verinject_ff_injector(
  input [31:0] state,
  input unmodified,
  output modified
);

assign modified = unmodified;

endmodule