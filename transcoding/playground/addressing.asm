section .text
global _start
_start:
	; esp addressing notes
	mov eax, [eax]
	mov eax, [esp]

	; ebp addressing notes
	add  ax, [7]
	add eax, [7]
	add eax, [ebp]
	add eax, [ebp+7]

	; 64-bit direct addressing?
	; mov rax, QWORD [0xa0b0c0d0e0f0a1b1]

	; rip relative vs 32-bit displacement
	mov rax, [7]
	mov rax, [rip]
	mov rax, [rip+7]

	; messing with addresses
	; mov rax, 0xa0b0c0d0e0f0a1b1
	; mov rsp, 0xa0b0c0d0e0f0a1b1

	; mov eax, [esp+eax*4]
	; mov eax, [ebp+eax*4]
	; mov eax, [ebp+eax*4+2]

	; mov rax, [rsp+rax*4]
	; mov rax, [rbp+rax*4]
	; mov rax, [rbp+rax*4+2]
	; mov rax, [rbp]

	; mov rax, [r13+rax*4]
	; mov rax, [r13+rax*4+2]
	; mov rax, [r13]
	; mov rax, [rip]
	; mov rax, [0xa0b0c0d0]

	; mov [r13+rax*4], rax
	; mov [r13+rax*4+2], rax
	; mov [r13], rax

	; ModR/M, SIB special cases
	; 1. RSP cannot be an index, ever, I'm assuming
	;    because of the 
	; mov rax, [rsp*4] ; illegal

	; rsp v. r12
	; mov rax, [rsp+5]
	; mov rax, [r12+5]
	; mov rax, [r12+r12*4+5]
