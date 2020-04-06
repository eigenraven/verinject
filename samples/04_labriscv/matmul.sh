#!/bin/bash

make programs/matmul.hex || exit 1
rm -f wave_matmul.vcd
rm -f runner_matmul.vvp
#export IVERILOG_DUMPER=lxt
export IVERILOG_DUMPER=none
echo Compiling...
iverilog '-DHEX_FILE="programs/matmul.hex"' -g2005 -s tb tb/matmul.v -y hdl -y injected \
  -y ../../verilog/ff -y ../../verilog/memory_fifo -y ../../verilog/monitor \
  -y ../../verilog/gen -I hdl -o runner_matmul.vvp \
  || exit 1
echo Running...
./runner_matmul.vvp || exit 1
echo Done
