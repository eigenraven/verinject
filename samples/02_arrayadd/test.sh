#!/bin/sh

if [ ! -d injected ]; then
  mkdir injected
fi

rm -f waveform.vcd

verilator --xml-only src/top.v &&
cargo run -- ./obj_dir/Vtop.xml -o injected || exit 1
mkdir runs.log &> /dev/null

TOTALRUNS=1000
#export IVERILOG_DUMPER=lxt
export IVERILOG_DUMPER=none

echo "run,sxor" > test_results.csv

for RUN in $(seq $TOTALRUNS)
do
  TF=./runs.log/trace$RUN.txt
  echo "* Run $RUN/$TOTALRUNS"
  ../../vj-gentrace ./injected/top.map --seed $RUN --cycles 256 --faults 1 > $TF || exit 1
  iverilog -g2005 -s tb tb/tb.v src/top.v injected/top__injected.v \
    ../../verilog/ff/verinject_ff_injector.v ../../verilog/memory_fifo/verinject_mem1_injector.v ../../verilog/gen/verinject_file_tester.v ../../verilog/monitor/verinject_sim_monitor.v \
    -I mem "-DVERINJECT_TRACE_FILE=\"$TF\"" -o runner.vvp &&
  ./runner.vvp | ../../vj-filter ./injected/top.map > runs.log/run$RUN.log || exit 1
  # zstd -15 --rm -f waveform.vcd -o runs.log/waveform$RUN.vcd.zst
  xor=$(grep -E -o 'xor\(([^)]+)\)' ./runs.log/run$RUN.log | cut -c4- | grep -E -o '[0-9a-fA-F]+')
  delta=$(grep -E -o 'absdifference\(([^)]+)\)' ./runs.log/run$RUN.log | cut -c14- | grep -E -o '[0-9a-fA-F]+')
  if [ -z "$xor" ]; then
    xor=0
  fi
  if [ -z "$delta" ]; then
    delta=0
  fi
  echo "$RUN,$xor,$delta" >> test_results.csv
done

# echo "run,sxor,diff" > test_results.csv
# for RUN in $(seq $TOTALRUNS)
# do
#   xor=$(grep -E -o 'xor\(([^)]+)\)' ./runs.log/run$RUN.log | cut -c4- | grep -E -o '[0-9a-fA-F]+')
#   delta=$(grep -E -o 'absdifference\(([^)]+)\)' ./runs.log/run$RUN.log | cut -c14- | grep -E -o '[0-9a-fA-F]+')
#   if [ -z "$xor" ]; then
#     xor='00000000'
#   fi
#   if [ -z "$delta" ]; then
#     delta='00000000'
#   fi
#   echo "$RUN,$xor,$delta" >> test_results.csv
# done
