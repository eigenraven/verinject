
all: programs/testout.hex programs/matmul.hex programs/native_matmul
.PHONY: all

programs/testout.hex: programs/testout.c programs/linkmap.ld Makefile
	riscv32-elf-gcc -march=rv32im -mabi=ilp32 -O2 -c $< -o programs/testout.o
	riscv32-elf-ld -m elf32lriscv -o programs/testout.out -T programs/linkmap.ld programs/testout.o
	riscv32-elf-objcopy -j .text -O binary programs/testout.out programs/testout.bin
	cargo run -p mkvhex --release -- programs/testout.bin -o programs/testout.hex -w 32 -h 2048 -e

programs/matmul.hex: programs/matmul.c programs/linkmap.ld Makefile
	riscv32-elf-gcc -march=rv32im -mabi=ilp32 -O2 -c $< -o programs/matmul.o
	riscv32-elf-ld -m elf32lriscv -o programs/matmul.out -T programs/linkmap.ld programs/matmul.o
	riscv32-elf-objcopy -j .text -O binary programs/matmul.out programs/matmul.bin
	cargo run -p mkvhex --release -- programs/matmul.bin -o programs/matmul.hex -w 32 -h 2048 -e

programs/native_matmul: programs/native_matmul.c Makefile
	gcc $< -o programs/native_matmul
