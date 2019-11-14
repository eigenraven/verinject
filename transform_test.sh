#!/bin/zsh
mkdir test_out
mkdir obj_dir
#rm -f test_out/*
#rm -f obj_dir/*

cargo build

for f in test/*.v ; do
  echo Verilating $f
  verilator --xml-only -Itest $f
done

echo '* Verilated all'

for f in test/*.v ; do
  xml=$(echo $f | sed -e 's/^test\//obj_dir\/V/' -e 's/v$/xml/')
  # ofile=$(echo $f | sed -e 's/^test\//test_out\//')
  echo "* Transforming $f -> $ofile"
  ./target/debug/verinject "$xml" -o "./test_out/" -v
done
