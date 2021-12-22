%include "constants.asm"

section .rodata
	Arr dd  0.26812, 0.42491,-0.96574,-0.06330, 0.10227,
	    dd -0.71006, 0.22973,-0.43017, 0.64855,-0.10180,
	    dd -0.74211,-0.31986,-0.21803, 0.91779, 0.41166,
	    dd  0.59364, 0.79454,-0.07162, 0.65202,-0.95068,
	    dd  0.66956,-0.60295,-0.89491, 0.35515,-0.32726,
	
	Zro dd 0.0
	Len dd 25

section .bss
	Sum resd 1
	Avg resd 1

section .text
global _start
_start:
	; find sum
	movss xmm0, DWORD [Zro]
	mov ecx, DWORD [Len]
	mov edx, 0
_start_sum_loop:
	addss xmm0, DWORD [Arr+edx*4]
	inc edx
	loop _start_sum_loop
	movss DWORD [Sum], xmm0

	; calc avg
	cvtsi2ss xmm1, DWORD [Len]
	divss xmm0, xmm1
	movss DWORD [Avg], xmm0

	; exit
	mov rdi, EXIT_success
	mov rax, SYS_exit
	syscall
