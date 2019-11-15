module verinject_ff_injector
#(parameter LEFT = 0, parameter RIGHT = 0, parameter P_START = 0)
(
  input [LEFT:RIGHT] unmodified,
  output reg [LEFT:RIGHT] modified,
  input [31:0] verinject__injector_state
);

always @*
begin : fault_injection
  modified = unmodified;
  if (LEFT < RIGHT) begin
    // size is RIGHT - LEFT + 1
    if (verinject__injector_state >= P_START && verinject__injector_state <= (P_START + RIGHT - LEFT)) begin
      modified[verinject__injector_state - P_START] = ~modified[verinject__injector_state - P_START];
    end
  end else begin
    if (verinject__injector_state >= P_START && verinject__injector_state <= (P_START + LEFT - RIGHT)) begin
      modified[verinject__injector_state - P_START] = ~modified[verinject__injector_state - P_START];
    end
  end
end

endmodule
