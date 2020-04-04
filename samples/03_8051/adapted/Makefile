
asm/hello.bin: asm/hello.asm Makefile
	as31 -Fhex -Oasm/hello.intel asm/hello.asm
	head -n -1 asm/hello.intel | awk '{ print substr($$0, 10, length($$0)-11); }' | tr -d '\n\r \t' | fold -b -w2 > asm/hello.bin
