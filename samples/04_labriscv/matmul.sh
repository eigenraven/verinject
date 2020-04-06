#!/bin/bash

make programs/matmul.hex || exit 1
rm -f wave_matmul.vcd
rm -f runner_matmul.vvp
echo Compiling...
export IVERILOG_DUMPER=lxt
iverilog '-DHEX_FILE="programs/matmul.hex"' -g2005 -s tb tb/matmul.v -y hdl -y injected \
  -y ../../verilog/ff -y ../../verilog/memory_fifo -y ../../verilog/monitor \
  -y ../../verilog/gen -I hdl -o runner_matmul.vvp \
  || exit 1
echo Test run...
echo Test run > all_runs.log
# --exclude cpu.u_fetch_unit.iccm cpu.u_fetch_unit.u_branch_predictor.u_branch_cache.bc_ram
./vj-gentrace --seed 3 --cycles 4900 --faults 200 ./injected/cpu.map --include xreg > verinject_trace.txt || exit 1
./runner_matmul.vvp 2>/dev/null > cur_run.log </dev/null || exit 1
diff <(tail -n 1 cur_run.log) reference_out.txt
echo $?
echo Done test run
export IVERILOG_DUMPER=none
