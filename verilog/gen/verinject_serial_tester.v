module verinject_serial_tester
#(parameter TOTAL_BITS=0)
(
  input clock,
  input reset_n,
  output reg [31:0] verinject__injector_state
);

reg [31:0] next_state;

initial
begin
  verinject__injector_state <= 32'hFFFFFFFF;
end

always @*
begin
  next_state = verinject__injector_state + 1;
  if (next_state >= TOTAL_BITS)
    next_state = 0;
end

always @(posedge clock, negedge reset_n)
begin
  if (!reset_n)
  begin
    verinject__injector_state <= 32'hFFFFFFFF;
  end else begin
    verinject__injector_state <= next_state;
  end
end

endmodule
