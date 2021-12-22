%include "constants.asm"
%include "printline_only.asm"
%include "fload_only.asm"


section .rodata
	EREAD db "failed to read file.", 0
	ENOFILE db "no file specified.", 0
	BufSz equ 65535

section .bss
	Buf resb BufSz

section .text
global _start
_start:
	; prepare 
	push rbp
	mov rbp, rsp

	; args
	mov r12, QWORD [rbp+8] ; argc
	lea r13, QWORD [rbp+24] ; argv[1]
	cmp r12, 1
	jle _start_err_no_file

	; load file
	mov rdx, BufSz
	mov rsi, Buf
	mov rdi, QWORD [r13]
	call fload
	cmp rax, 0
	jl _start_err_read

	; print contents out
	mov rdi, Buf
	call printline
	mov rdi, EXIT_success
	jmp _start_finish
_start_err_read:
	mov rdi, EREAD
	call printline
	mov rdi, 2
	jmp _start_finish
_start_err_no_file:
	mov rdi, ENOFILE
	call printline
	mov rdi, 1
_start_finish:
	mov rdi, EXIT_success
	mov rax, SYS_exit
	syscall
