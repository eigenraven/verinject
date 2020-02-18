`ifndef VERINJECT_TRACE_FILE
`define VERINJECT_TRACE_FILE "verinject_trace.txt"
`endif

module verinject_file_tester
(
  input clock,
  input reset_n,
  output [31:0] verinject__injector_state,
  output [47:0] cycle_number
);

reg [63:0] trace_mem [0:1023];

reg [47:0] cycle_r;
reg [9:0] trace_ptr_r;
reg [9:0] trace_ptr_nxt;

wire [63:0] trace_read;
wire trace_here;
assign trace_read = trace_mem[trace_ptr_r];
assign trace_here = trace_read[63:32] == cycle_r;
assign verinject__injector_state = trace_here ? trace_read[31:0] : 32'hFFFFFFFF;
assign cycle_number = cycle_r;

initial
begin
  $readmemh(`VERINJECT_TRACE_FILE, trace_mem);
  cycle_r = 0;
  trace_ptr_r = 0;
end

always @*
begin
  trace_ptr_nxt = trace_ptr_r;
  if (trace_here && !(&trace_ptr_r)) // avoid overflow
  begin
    trace_ptr_nxt += 1;
  end
end

always @(posedge clock, negedge reset_n)
begin
  if (!reset_n)
  begin
    cycle_r <= 0;
    trace_ptr_r <= 0;
  end else begin
    cycle_r <= cycle_r + 1;
    trace_ptr_r <= trace_ptr_nxt;
  end
end

endmodule
