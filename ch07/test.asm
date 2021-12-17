section .text
global _start

_start:
	mov ax, 0
	mov al, -1
	nop 
	movsx ax, al
	mov rax, 60
	mov rdi, 0
	syscall
