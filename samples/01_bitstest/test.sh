#!/bin/sh

if [[ ! -d injected ]]; then
  mkdir injected
fi

rm -f waveform.vcd

verilator --xml-only src/top.v &&
cargo run -- ./obj_dir/Vtop.xml -o injected &&
iverilog -g2005 tb/tb.v src/top.v injected/top__injected.v \
  ../../verilog/test/verinject_ff_injector.v ../../verilog/test/verinject_mem1_injector.v ../../verilog/gen/verinject_serial_tester.v ../../verilog/monitor/verinject_sim_monitor.v \
  -o runner.vvp &&
./runner.vvp | ../../vj-filter ./injected/top.map