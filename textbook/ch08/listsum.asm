section .data
	List dd	 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
	N    equ 10

section .bss
	Sum  resd 1
	Avg  resd 1

section .text
global _start

_start:
	mov eax, 0
	mov ecx, 0
sum_loop:
	add eax, DWORD [List+rcx*4]
	inc ecx
	cmp ecx, N
	jb sum_loop ; if rcx < N
	mov DWORD [Sum], eax

	; compute average
	mov edx, 0
	mov ebx, N
	idiv ebx
	mov DWORD [Avg], eax

	; exit
	mov rax, 60
	mov rdi, 0
	syscall
