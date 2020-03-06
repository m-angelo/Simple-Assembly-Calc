ASM=as
LINKER=ld

SRC:=calc.s

calc: $(SRC)
	$(ASM) -o serv.o $(SRC)
	$(LINKER) -o serv serv.o

run: calc
	./$<

clean:
	rm -rfv *.o
