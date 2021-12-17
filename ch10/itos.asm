section .data
	Nums    dq 401984161, 73236900, -28291946, -492079933, 199821803

	LEN    equ 5
	BUFSZ  equ 16

section .bss
	Buffer resb BUFSZ

section .text
global _start

_start:
	mov rcx, LEN
	mov r9, 0
nums_loop:
	mov rbx, 0 ; isnegative = false
	mov rdi, 0 ; ndigits = 0
	mov r8, 10
	mov rax, QWORD [Nums+r9*8]
	cmp rax, 0
	jge push_loop
	mov rbx, 1 ; isnegative = true
	neg rax

	; push digits
push_loop:
	cqo
	div r8
	push rdx
	inc rdi
	cmp rax, 0
	jg push_loop

	; pop digits
	mov rsi, 0
	cmp rbx, 0
	je pop_loop
	mov BYTE [Buffer+rsi], "-"
	inc rsi
	inc rdi
pop_loop:
	pop rdx
	add rdx, 0x30
	mov BYTE [Buffer+rsi], dl
	inc rsi
	cmp rsi, rdi
	jb pop_loop
	mov BYTE [Buffer+rsi], 0
	inc r9
	loop nums_loop

	; exit
	mov rax, 60
	mov rdi, 0
	syscall
