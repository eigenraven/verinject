#!/bin/sh

if [[ ! -d injected ]]; then
  mkdir injected
fi

rm -f waveform.vcd

verilator --xml-only src/top.v &&
cargo run -- ./obj_dir/Vtop.xml -o injected &&
iverilog -g2005 tb/tb.v src/top.v injected/top__injected.v ../../sim/ff/verinject_ff_injector.v ../../sim/memory_transient/verinject_mem1_injector.v -o runner.vvp &&
./runner.vvp