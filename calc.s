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


_start:

    disp_str txt_A, $11

_exit:
    exit_prog $0
