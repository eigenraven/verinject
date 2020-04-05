programs/testout.hex: programs/testout.c programs/linkmap.ld Makefile
	riscv32-elf-gcc -march=rv32im -mabi=ilp32 -O2 -c $< -o programs/testout.o
	riscv32-elf-ld -m elf32lriscv -o programs/testout.out -T programs/linkmap.ld programs/testout.o
	riscv32-elf-objcopy -O binary programs/testout.o programs/testout.bin
	cargo run -p mkvhex --release -- programs/testout.bin -o programs/testout.hex -w 32 -h 4096