%include "constants.asm"
%include "printline_only.asm"

section .rodata
	MsgEq db "Are Same", 0
	MsgNe db "Are Not Same", 0

	; Naive things
	; N equ 10
	; Zro dd 0.0
	; Elem dd 0.1
	; Targ dd 1.0

	; Expert things
	N equ 10
	Zro dd 0.0
	Elem dd 1.0
	Targ dd 1.0

section .text
global _start
_start:
; Naive solution to summing 0.1 for 10 times
; 	; summation loop
; 	mov rcx, N
; 	movss xmm0, DWORD [Zro]
; _start_sum_loop:
; 	addss xmm0, DWORD [Elem]
; 	loop _start_sum_loop
; 	ucomiss xmm0, DWORD [Targ]
; 	jne _start_not_same
; 	mov rdi, MsgEq
; 	call printline
; 	jmp _start_cmp_end
; _start_not_same:
; 	mov rdi, MsgNe
; 	call printline
; _start_cmp_end:

; Proper solution 
	mov rcx, N
	cvtsi2ss xmm1, rcx
	movss xmm0, DWORD [Zro]
_start_sum_loop:
	addss xmm0, DWORD [Elem]
	loop _start_sum_loop
	divss xmm0, xmm1
	ucomiss xmm0, DWORD [Targ]
	jne _start_not_same
	mov rdi, MsgEq
	call printline
	jmp _start_cmp_end
_start_not_same:
	mov rdi, MsgNe
	call printline
_start_cmp_end:

	; exit
	mov rdi, EXIT_success
	mov rax, SYS_exit
	syscall
