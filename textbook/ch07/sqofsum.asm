section .data
	N equ 10
	
section .bss
	SqSum resq 1

section .text
global _start

_start:
	; rax = 0, rbx = 1, rcx = N
	; while (rcx != 0)
	;   rax += rbx
	;   rbx++
	;   rcx--
	; rax *= rax
	; SqSum = rax
	mov rax, 0
	mov rbx, 1
	mov rcx, N
sum_loop:
	add rax, rbx
	inc rbx
	dec rcx
	cmp rcx, 0
	ja sum_loop
	mul rax
	mov QWORD [SqSum], rax
	; exit
	mov rax, 60
	mov rdi, 0
	syscall
