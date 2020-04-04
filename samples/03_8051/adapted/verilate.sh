#!/bin/bash

TOP=rtl/oc8051_top.v
if ! [ -d injected ]
then
    mkdir injected
fi
verilator -Wno-lint --language 1364-2001 --xml-only -Irtl $TOP || exit 1
cargo run -- -o injected obj_dir/Voc8051_top.xml || exit 1
verilator -Wno-lint -Wno-unoptflat --language 1364-2001 --lint-only -Irtl -Iinjected -I../../../test injected/oc8051_top__injected.v || exit 1
