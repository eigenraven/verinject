module verinject_sim_monitor
(
  input clock,
  input [47:0] cycle_number,
  input [31:0] verinject__injector_state
);

always @(posedge clock)
begin
  if (&verinject__injector_state == 0)
  begin
    if (verinject__injector_state == 32'hFFFF_FFFE)
      $display("verinject-reset");
    else
      $display("verinject: at cycle %d injected into bit %d", cycle_number, verinject__injector_state);
  end
end

endmodule
