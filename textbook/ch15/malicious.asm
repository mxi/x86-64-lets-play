section .text
global _start
_start:
	; see if we can spawn a shell
	xor r15, r15
	mov r15, "/bin/sh"
	push r15
	mov rdi, rsp
	mov rax, 59 ; SYS_exec
	syscall

	; exit
	mov rdi, 0
	mov rax, 60
	syscall

