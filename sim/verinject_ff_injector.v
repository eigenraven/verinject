module verinject_ff_injector
#(parameter LEFT = 0, parameter RIGHT = 0)
(
  input [LEFT:RIGHT] unmodified,
  output [LEFT:RIGHT] modified
);

always @(modified)
begin : fault_injection
    
end

endmodule
