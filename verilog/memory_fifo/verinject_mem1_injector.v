`ifndef VERINJECT_MEM_FIFO_SIZE
`define VERINJECT_MEM_FIFO_SIZE 4
`define VERINJECT_MEM_FIFO_SIZE_LOG2 2
`endif

module verinject_mem1_injector
#(parameter LEFT = 0, parameter RIGHT = 0,
  parameter ADDR_LEFT = 0, parameter ADDR_RIGHT = 0,
  parameter MEM_LEFT = 0, parameter MEM_RIGHT = 0,
  parameter P_START = 0)
(
  // injector parameters
  input [31:0] verinject__injector_state,
  // clocking
  input clock,
  // memory read injection
  input [LEFT:RIGHT] unmodified,
  input [ADDR_LEFT:ADDR_RIGHT] read_address,
  output [LEFT:RIGHT] modified,
  // memory write capture
  input do_write,
  input [ADDR_LEFT:ADDR_RIGHT] write_address
);

localparam bits_start = (LEFT < RIGHT) ? LEFT : RIGHT;
localparam word_len = (LEFT < RIGHT) ? (RIGHT - LEFT + 1) : (LEFT - RIGHT + 1);
localparam mem_start = (MEM_LEFT < MEM_RIGHT) ? MEM_LEFT : MEM_RIGHT;
localparam mem_len = (MEM_LEFT < MEM_RIGHT) ? (MEM_RIGHT - MEM_LEFT + 1) : (MEM_LEFT - MEM_RIGHT + 1);

localparam idx_start = P_START;
localparam idx_end = P_START + mem_len*word_len;

integer ii;

reg [31:0] active_injections [0:`VERINJECT_MEM_FIFO_SIZE];
reg [`VERINJECT_MEM_FIFO_SIZE_LOG2:0] injection_wptr_r;
reg [`VERINJECT_MEM_FIFO_SIZE_LOG2:0] injection_wptr_nxt;
reg injection_writing;

wire [31:0] read_word_start;
wire [31:0] read_word_end;
assign read_word_start = P_START + (read_address - mem_start) * word_len;
assign read_word_end = read_word_start + word_len;

wire [31:0] write_word_start;
wire [31:0] write_word_end;
assign write_word_start = P_START + (write_address - mem_start) * word_len;
assign write_word_end = write_word_start + word_len;

reg [LEFT:RIGHT] xor_modifier;

assign modified = unmodified ^ xor_modifier;

wire reset_fifo;
assign reset_fifo = (verinject__injector_state == 32'hFFFF_FFFE);

initial
begin
  xor_modifier = 0;
  injection_wptr_r = 0;
  for (ii = 0; ii < `VERINJECT_MEM_FIFO_SIZE; ii=ii+1)
  begin
    active_injections[ii] = 32'hFFFF_FFFF;
  end
end

always @*
begin : fault_injection
  xor_modifier = 0;

  injection_writing = 0;
  injection_wptr_nxt = injection_wptr_r;
  if (verinject__injector_state >= idx_start && verinject__injector_state < idx_end)
  begin
    injection_writing = 1'b1;
    injection_wptr_nxt = injection_wptr_r + 1;
  end

  for (ii = 0; ii < `VERINJECT_MEM_FIFO_SIZE; ii=ii+1)
  begin
    if (active_injections[ii] >= read_word_start && active_injections[ii] < read_word_end)
    begin
      xor_modifier = xor_modifier ^ (1 << (active_injections[ii] - read_word_start + bits_start));
    end
  end
  if (verinject__injector_state >= read_word_start && verinject__injector_state < read_word_end)
  begin
    xor_modifier = xor_modifier ^ (1 << (verinject__injector_state - read_word_start + bits_start));
  end
end

always @(posedge clock)
begin : fault_memory_fifo
  // using blocking assignments for fifo writes to ensure priority of writes
  // erase from fifo
  for(ii = 0; ii < `VERINJECT_MEM_FIFO_SIZE; ii=ii+1)
  begin
    if (reset_fifo || (do_write && active_injections[ii] >= write_word_start && active_injections[ii] < write_word_end))
    begin
      active_injections[ii] = 0;
    end
  end
  // write to fifo
  if (injection_writing)
  begin
    active_injections[injection_wptr_r] = verinject__injector_state;
  end
  // update registers
  injection_wptr_r <= injection_wptr_nxt;
end

endmodule
