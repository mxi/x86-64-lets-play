section .data
	NumStr db "26631", 0

section .bss
	Num resq 1

section .text
global _start

_start:
	mov rsi, NumStr
	mov rbx, 10
	mov rcx, 0
push_loop:
	cmp BYTE [rsi], 0
	je push_loop_end
	movzx rax, BYTE [rsi]
	sub rax, 0x30
	push rax
	inc rcx
	inc rsi
	jmp push_loop
push_loop_end:
	mov rsi, 0
	mov rdi, 1
pop_loop:
	pop rax
	mul rdi
	add rsi, rax
	mov rax, rdi
	mul rbx
	mov rdi, rax
	loop pop_loop
	mov QWORD [Num], rsi

	mov rax, 60
	mov rdi, 0
	syscall
