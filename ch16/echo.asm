%include "constants.asm"
%include "printline_only.asm"


section .text

global _start
_start:
	; args are on the stack
	push rbp
	mov rbp, rsp

	; iterate over cli args and print them
	mov r12, QWORD [rbp+8]
	lea rbx, QWORD [rbp+16]
_start_arg_loop:
	cmp r12, 0
	je _start_arg_loop_end
	mov rdi, QWORD [rbx]
	call printline
	add rbx, 8
	dec r12
	jmp _start_arg_loop
_start_arg_loop_end:

	; be a good boy and restore the stack
	mov rsp, rbp
	pop rbp

	; exit
	mov rdi, EXIT_success
	mov rax, SYS_exit
	syscall
