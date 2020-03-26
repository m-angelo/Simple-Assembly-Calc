ASM=as
LINKER=ld

SRC:=calc.s

calc: $(SRC)
	$(ASM) -o calc.o $(SRC)
	$(LINKER) -o calc calc.o

run: calc
	./$<

clean:
	rm -rfv *.o
