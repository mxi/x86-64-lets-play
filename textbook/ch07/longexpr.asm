section .data
	A dq 3
	B dq 5
	C dq 7
	D dq 11
	E dq 13
	F dq 17
	G dq 19

section .bss
	Solution resq 1
	
section .text
global _start

_start:
	; compute the following expression given programmer
	; defined 64-bit signed integer constants:
	;
	; a % b - ((-c * d + e) / -7) * f / g
	; = r11 - r12

	; r11 = a % b
	mov rax, QWORD [A]
	cqo
	idiv QWORD [B]
	mov r11, rdx
	
	; rdx:rax = -c * d
	mov rax, QWORD [C]
	neg rax
	imul QWORD [D]

	; rdx:rax += e
	add rax, QWORD [E]
	adc rdx, 0

	; rax /= -7
	; rax *= f
	; rax /= g
	mov rbx, -7
	idiv rbx
	imul QWORD [F]
	idiv QWORD [G]

	; rax = r11 - rax
	sub r11, rax
	mov QWORD [Solution], r11
	
	; exit
	mov rax, 60
	mov rdi, 0
	syscall
