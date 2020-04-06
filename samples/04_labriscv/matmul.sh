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
./vj-gentrace --seed 0 --cycles 2430 --faults 200 ./injected/cpu.map --exclude cpu.u_fetch_unit.iccm cpu.u_exec_unit.u_dccm_ram.dccm_b u_branch_predictor > verinject_trace.txt || exit 1
./runner_matmul.vvp 2>/dev/null > cur_run.log </dev/null || exit 1
../../vj-filter ./injected/cpu.map < cur_run.log
diff --color=always <(tail -n 1 cur_run.log) reference_out.txt && echo No difference
# $? = 1 if different, 0 if equal
echo Done test run

echo Starting main runs
export IVERILOG_DUMPER=none
STARTRUN=1
MAXRUNS=1000
printf "" > all_runs.log
echo > all_detailed.log

for RUN in $(seq $STARTRUN $MAXRUNS)
do
    echo Run $RUN/$MAXRUNS
    echo Seed $RUN >> all_runs.log
    echo Seed $RUN >> all_detailed.log
    # --exclude cpu.u_fetch_unit.iccm cpu.u_exec_unit.u_dccm_ram.dccm_b u_branch_predictor
    ./vj-gentrace --seed $RUN --cycles 2430 --faults 1 ./injected/cpu.map --include xreg > verinject_trace.txt || exit 1
    ./runner_matmul.vvp 2>/dev/null > cur_run.log </dev/null || exit 1
    # add 0 if no difference, 1 if different
    ../../vj-filter ./injected/cpu.map < cur_run.log >> all_detailed.log
    diff <(tail -n 1 cur_run.log) reference_out.txt >/dev/null && echo 0 >> all_runs.log || echo 1 >> all_runs.log
done
