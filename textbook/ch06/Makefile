sources := $(wildcard *.asm)
objects := $(sources:.asm=.o)
target := a.out

$(target): $(objects)
	ld -g -o $@ $^

$(objects): %.o: %.asm
	yasm -g dwarf2 -f elf64 -o $@ $^

clean:
	rm $(objects)
	rm $(target)

.PHONY: list clean
