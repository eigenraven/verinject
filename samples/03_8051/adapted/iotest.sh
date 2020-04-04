#!/bin/sh

rm -f wave_iotest.vcd
rm -f runner_iotest.vvp
export IVERILOG_DUMPER=lxt
echo Compiling...
iverilog -g2005 -s tb tb/iotest.v -y rtl -o runner_iotest.vvp || exit 1
echo Running...
./runner_iotest.vvp || exit 1
echo Done