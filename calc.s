.equ read,0x03
.equ write,0x04
.equ exit,0x01
.equ poll,168 # poll

.equ stdin, 0x00
.equ stdout, 0x01
.equ kernel, 0x80

.data

counter: .byte 0x00

txt_A:
    .ascii "Wprowadz a:\n"
txt_B:
    .ascii "Wprowadz b:\n"
txt_C:
    .ascii "Podaj dzialanie:\n"
text_eq:	
	.string	" = "
text_result:	
	.string	"     \n"
dataend:
	.equ	text_len, dataend - text_eq


io_buffer:
	.ascii "                                                                "
poll_fd:
	.long 0x00
poll_events:
	.short 0x01 # POLLIN
poll_revents:
	.short 0x00

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

.macro addition num1, num2
	mov \num1, %eax
	mov \num2, %ebx
	add  %ebx,%eax
	mov %eax ,%ebx
	call make_string
	
.endm

.macro multiplication num1, num2
	MOV \num1, %AL
	MOV \num2, %DL
	IMUL %DL
	mov %eax ,%ebx
	call make_string
	
.endm

_start:
	mov $stdin, %eax # poll stdin
	call poll_fd_read

	cmp $0, %eax
	jz _exit

	mov $0x10, %eax # read 16 bytes
	call read_stdin

    disp_str $txt_A, $11
	disp_str $io_buffer, $64

_exit:
    exit_prog $0


# rdi - starting index, ebx string
.type make_string,@function
make_string:
	MOVL $0x20202020,text_result
	MOV	%ebx,%eax		# convert index of vector element to string
	MOV	$text_result,%rdi
	CALL	num2dec
	RET	

#	Function:	num2dec
#	Parameters:	%eax - value
#			%rdi - address of last character
.type num2dec,@function
num2dec:

	PUSH	%rbx		# save register on stack
	PUSH	%rdx		# save register on stack
	MOV	$10,%ebx	# divisor in EBX, dividend in EAX
	MOV %rdi, %r13
	mov $0, %r12
nextdig:			
	XOR	%edx,%edx	# EDX = 0
	DIV	%ebx		# EDX:EAX div EBX
	ADD	$'0',%dl	# convert remainder (in EDX) to character
	push %rdx
	CMP	$0,%eax		# quotient in EAX 

	JZ	fill_string
	INC %r12
	DEC	%rdi		# RDI--
	

	JMP	nextdig	

fill_string:
	POP %rdx
	MOV	%dl,(%r13)	# *(RDI) = character (decimal digit)
	CMP	$0,%r12
	JZ	empty
	DEC %r12
	INC	%r13
	jmp fill_string


empty:		
	POP	%rdx		# restore register from stack
	POP	%rbx		# restore register from stack
	RET


#----------------------------------------
#
#	@func: poll_fd_read
# 	@args: %eax - fd to poll
# 	@retu: %eax - 0 if no data, anything else if theres data
# 	@note: Does not save the eax!
#
.type poll_fd_read, @function
poll_fd_read:
	mov %eax, poll_fd
	mov $poll, %eax
	mov $poll_fd, %ebx
	mov $0x01, %ecx
	mov $0x00, %edx
	int $kernel

	ret

#----------------------------------------
#
#	@func: read_stdin
# 	@args: %eax - bytes to read
# 	@retu: %eax - read bytes
# 	@note: Does not save the eax!
#
.type read_stdin, @function
read_stdin:
	push %rbx
	push %rcx
	push %rdx
	
	mov %eax, %edx # how much to read
	mov $read, %eax # sys func index
	mov $stdin, %ebx # from stdin
	mov $io_buffer, %ecx # into this buffer
	int $kernel

	pop %rdx
	pop %rcx
	pop %rbx
	
	ret
