.equ write,0x04
.equ exit,0x3c
.equ stdout, 0x01
.equ stdin, 0x03 
.equ kernel, 0x80

.data

counter: .byte 0x00
txt_A:
    .ascii "Wprowadz a:\n"
txt_B:
    .ascii "Wprowadz b:\n"
txt_C:
    .ascii "Podaj dzialanie:\n"

a_var: .long 0x0
b_var: .long 0x0
int_size: .byte 8

.text
.global _start

.macro disp_str address, length
	mov $write, %eax
	mov $stdout, %ebx
	mov \address, %ecx
	mov \length, %edx
	int $kernel
	.endm

.macro exit_prog exit_code
	mov $exit, %eax
	mov \exit_code, %ebx
	int $kernel
.endm

.macro input length
    ;Read and store the user input
   mov eax, $stdin
   mov ebx, 2
   mov ecx, num  
   mov edx, 5          ;5 bytes (numeric, 1 for sign) of that information
   int $kernel
.endm

.macro alloc_memory size
	mov %eax, $12 # get the current address of the program with brk
	xor %ebx, %ebx
	syscall

	add %eax, \size # add the amount of memory we want to allocate
	mov %ebx, %eax # as an arg
	mov %eax, $12
	syscall

	cmp %eax, $0
	jl _exit # we don't work if there is no memory
	mov	%edi, %eax	 #EDI = highest available address
	sub	%edi, $int_size		 #pointing to the last int  
	mov	%ecx, \size	 #number of ints allocated
	div %ecx, $int_size
	mov %ecx, $eax
	xor	%eax, %eax	 #clear eax
	std			 #set the direction flag to backwards
	rep	stosd            #do a memset to zero
	cld			 #resert direction flag to normal
.endm

_start:
	alloc_memory $16384 # alloc 16k of mem

_exit:
    exit_prog $0
