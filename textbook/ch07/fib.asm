section .data
	; fib related
	Nth dq 0
	N equ 10

	; syscalls 
	SYS_EXIT equ 60
	EXIT_SUCCESS equ 0

section .text
global _start

_start:
	; a = 1, b = 1, z = 0
	; rcx = N
	; while (rcx != 0)
	;   z = a + b
	;   a = b
	;   b = z
	;   rcx--
	mov r8, 0
	mov r9, 1
	mov rcx, N
loop_start:
	; z = a + b
	mov rax, r8
	add rax, r9
	; a = b; b = z; rcx--
	mov r8, r9
	mov r9, rax
	dec rcx
	; rcx != 0
	cmp rcx, 0
	ja loop_start
	mov QWORD [Nth], r8
prog_end:
	mov rax, SYS_EXIT
	mov rdi, EXIT_SUCCESS
	syscall
