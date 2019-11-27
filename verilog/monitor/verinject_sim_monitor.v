module verinject_sim_monitor
#(parameter TOTAL_BITS=0)
(
  input clock,
  input [31:0] verinject__injector_state,
  output reg [47:0] cycle_number
);

initial
begin
  cycle_number <= 32'h0;
end

always @(posedge clock)
begin
  if (&verinject__injector_state == 0)
  begin
    $display("verinject: at cycle %d injected into bit %d", cycle_number, verinject__injector_state);
  end
  cycle_number <= cycle_number + 1;
end

endmodule
