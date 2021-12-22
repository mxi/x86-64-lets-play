section .data
	Arr dd 1583, 5252, 6711, 3040, 4600,
	    dd 1407, 6529, 2226, 5083, 1682,
	    dd 6331, 5577, 3806, 3937, 4706,
	    dd 3105, 2030, 7040, 2857, 1037,
	    dd 1526, 6219, 8340, 5884, 5613,
	    dd 3163, 5720, 8392, 6586, 7609,
	    dd 4082, 6953, 8752, 7408, 8430,
	    dd 2923, 5484, 6548, 6000, 5086,
	    dd 4138, 3302, 4048, 6656, 9219,
	    dd 7608, 4697, 4040, 5799, 4325,
	
	Len equ 50

section .text
global _start

_start:
	; push
	mov rcx, Len
	mov rbx, 0
push_loop:
	mov eax, DWORD [Arr+rbx*4] ; ~ movzx rax, DWORD Arr[rbx]
	push rax
	inc rbx
	loop push_loop

	; pop
	mov rcx, Len
	mov rbx, 0
pop_loop:
	pop rax
	mov DWORD [Arr+rbx*4], eax
	inc rbx
	loop pop_loop

	; exit
	mov rax, 60
	mov rdi, 0
	syscall

