compile:
	as -o calc.o calc.s
	ld -o calc calc.o
	clear