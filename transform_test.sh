#!/bin/zsh
mkdir test_out
mkdir obj_dir
#rm -f test_out/*
#rm -f obj_dir/*

RST="\e[0m"
YELLOW="\e[93m"
RED="\e[91m"
GREEN="\e[92m"

cargo build || exit 1

for f in test/*.v ; do
  echo Verilating $f
  verilator --xml-only -Itest $f
done

echo '* Verilated all'

for f in test/*.v ; do
  xml=$(echo $f | sed -e 's/^test\//obj_dir\/V/' -e 's/v$/xml/')
  echo "$YELLOW* Transforming $f ($xml)"
  echo "$YELLOW$ ./target/debug/verinject \"$xml\" -o ./test_out/ -v$RST"
  ./target/debug/verinject "$xml" -o "./test_out/" -v && echo "$GREEN OK$RST" || echo "$RED ERR$RST"
done

for f in test_out/*.v ; do
  echo "$YELLOW* Linting $f"
  echo "$YELLOW$ verilator --lint-only -Itest -Itest_out \"$f\"$RST"
  verilator --lint-only -Itest -Itest_out "$f" && echo "$GREEN OK$RST" || echo "$RED ERR$RST"
done
