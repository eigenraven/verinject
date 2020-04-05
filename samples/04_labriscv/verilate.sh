#!/bin/bash

TOP=hdl/cpu.v
if ! [ -d injected ]
then
    mkdir injected
fi
verilator -Wno-lint -Wno-unoptflat --language 1364-2005 --xml-only -Ihdl $TOP || exit 1
cargo run -- -o injected obj_dir/Vcpu.xml || exit 1
verilator -Wno-lint -Wno-unoptflat --language 1364-2005 --lint-only -Ihdl -Iinjected -I../../test injected/cpu__injected.v || exit 1
