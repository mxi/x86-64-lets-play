%macro itos 2
	; %1=buf ptr,
	; %2=num ptr (qword)

	; push digits
	mov rbx, 0
	mov rdi, 10
	mov rcx, 0
	mov rax, QWORD [%2]
	cmp rax, 0
	jge %%push_loop
	mov rbx, 1 ; isnegative = true
	neg rax
%%push_loop:
	cqo
	div rdi
	push rdx
	inc rcx
	cmp rax, 0
	jg %%push_loop

	; pop digits
	mov rsi, 0
	cmp rbx, 0
	je %%pop_loop
	mov BYTE [%1+rsi], "-"
	inc rsi
%%pop_loop:
	pop rdx
	add rdx, 0x30
	mov BYTE [%1+rsi], dl
	inc rsi
	loop %%pop_loop
	mov BYTE [%1+rsi], 0
%endmacro


section .data
	Num1 dq - 28291946
	Num2 dq  401984161
	Num3 dq   73236900
	Num4 dq -492079933
	Num5 dq  199821803

section .bss
	Buffer1 resb 32
	Buffer2 resb 32
	Buffer3 resb 32
	Buffer4 resb 32
	Buffer5 resb 32
	

section .text
global _start

_start:
	itos Buffer1, Num1
	itos Buffer2, Num2
	itos Buffer3, Num3
	itos Buffer4, Num4
	itos Buffer5, Num5

	; exit
	mov rax, 60
	mov rdi, 0
	syscall
