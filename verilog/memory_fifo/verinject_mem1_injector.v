`ifndef VERINJECT_MEM_FIFO_SIZE
`define VERINJECT_MEM_FIFO_SIZE 4
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
  output reg [LEFT:RIGHT] modified,
  // memory write capture
  input do_write,
  input [ADDR_LEFT:ADDR_RIGHT] write_address
);

localparam FIFO_SIZE_L2 = $clog2(VERINJECT_MEM_FIFO_SIZE);

localparam bits_start = (LEFT < RIGHT) ? LEFT : RIGHT;
localparam word_len = (LEFT < RIGHT) ? (RIGHT - LEFT + 1) : (LEFT - RIGHT + 1);
localparam mem_start = (MEM_LEFT < MEM_RIGHT) ? MEM_LEFT : MEM_RIGHT;
localparam mem_len = (MEM_LEFT < MEM_RIGHT) ? (MEM_RIGHT - MEM_LEFT + 1) : (MEM_LEFT - MEM_RIGHT + 1);

reg [31:0] active_injections [0:VERINJECT_MEM_FIFO_SIZE];
reg [FIFO_SIZE_L2:0] injection_wptr_r;
reg [FIFO_SIZE_L2:0] injection_wptr_nxt;
reg [VERINJECT_MEM_FIFO_SIZE-1:0] injection_matching;

wire [31:0] read_word_start;
wire [31:0] read_word_end;
assign read_word_start = P_START + (read_address - mem_start) * word_len;
assign read_word_end = read_word_start + word_len;

reg [LEFT:RIGHT] xor_modifier;

always @*
begin : fault_injection
  modified = unmodified;
  if (verinject__injector_state >= read_word_start && verinject__injector_state < read_word_end)
  begin
    xor_modifier = (1 << (verinject__injector_state - read_word_start + bits_start));
    modified = unmodified ^ xor_modifier;
  end
end

endmodule
