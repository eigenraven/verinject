#!/bin/bash

make programs/testout.hex || exit 1
rm -f wave_ledlog.vcd
rm -f runner_ledlog.vvp
export IVERILOG_DUMPER=lxt
echo Compiling...
iverilog '-DHEX_FILE="programs/testout.hex"' -g2005 -s tb tb/ledlog.v -y hdl -I hdl -o runner_ledlog.vvp || exit 1
echo Running...
./runner_ledlog.vvp || exit 1
echo Done
