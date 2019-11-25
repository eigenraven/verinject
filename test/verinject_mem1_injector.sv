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

assign modified = unmodified;

endmodule