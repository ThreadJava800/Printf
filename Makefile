ASM=nasm
LINKER=ld

ASMFLAGS = -f elf64 -l printf.lst printf.s
LINKERFLAGS = -s -o printf printf.o

 
all: compile link

erase:
	clear

compile:
	@${ASM} ${ASMFLAGS}

link:
	@${LINKER} ${LINKERFLAGS}


clean:
	@rm -rf ${EXECUTABLE}