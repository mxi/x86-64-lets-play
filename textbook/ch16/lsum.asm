%include "constants.asm"
%include "printline_only.asm"
%include "strlend_only.asm"
%include "stoid_only.asm"
%include "itosd_only.asm"


section .rodata
	ESERIAL db "could not serialize sum result.", 0
	ENOTINT db "one argument is not an integer.", 0

section .text
global _start
_start:
	; prepare
	push rbp
	mov rbp, rsp
	_start_Nsumbufsz equ 64
%define _start_Lstoidres QWORD [rbp-8]
%define _start_Lsumbuf QWORD [rbp-8-_start_Nsumbufsz]
	sub rsp, 8+_start_Nsumbufsz ; room for local vars/buffers

	; loop over args and sum the integers
	mov rbx, 0 ; holds the sum
	mov r12, QWORD [rbp+8] ; argc
	dec r12                ; first arg is usually file path
	lea r13, QWORD [rbp+24] ; argv[1]
_start_parse_add_loop:
	cmp r12, 0
	je _start_parse_add_loop_end
	; first get string length
	mov  cl, 0
	mov rdx, 64 ; any number so long as it can fit 20 digits or so
	mov rsi, QWORD [r13]
	mov rdi, 0
	call strlend
	cmp rax, 0
	je _start_err_parse
	; now parse int
	mov  cl, 0
	mov rdx, rax
	mov rsi, QWORD [r13]
	lea rdi, _start_Lstoidres
	call stoid
	cmp rax, 0
	je _start_err_parse
	; all good, add and continue
	add rbx, _start_Lstoidres
	dec r12
	add r13, 8
	jmp _start_parse_add_loop
_start_parse_add_loop_end:
	mov  cl, 0
	mov rdx, _start_Nsumbufsz
	lea rsi, _start_Lsumbuf
	mov rdi, rbx
	call itosd
	cmp rax, 0
	je _start_err_serialize

	; print result out
	lea rdi, _start_Lsumbuf
	call printline

	mov rdi, EXIT_success
	jmp _start_finish
_start_err_serialize:
	mov rdi, ESERIAL
	call printline
	mov rdi, 2
	jmp _start_finish
_start_err_parse:
	mov rdi, ENOTINT
	call printline
	mov rdi, 1
_start_finish:
	; restore stack
	mov rsp, rbp
	pop rbp
	; exit
	mov rax, SYS_exit
	syscall
