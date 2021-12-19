%include "constants.asm"

section .rodata
	LFc db LF

section .text
global unsafe
unsafe:
	; Obtains a line of input from STDIN and prints it back out to
	; STDOUT with a fixed, unsafe buffer size.
	; RETURN
	;     rax = 0 on success, -1 on failure
	unsafe_BUFSZ equ 80
	push rbp
	mov rbp, rsp
	sub rsp, unsafe_BUFSZ
	push rbx
	push r12

	lea rbx, BYTE [rbp-unsafe_BUFSZ] 
	mov r12, 0 ; count
unsafe_read_loop:
	; read one char at a time
	mov rdx, 1
	mov rsi, rbx
	mov rdi, SYS_stdin
	mov rax, SYS_read
	syscall
	cmp rax, 0
	jl unsafe_err
	; check if LF, break
	cmp BYTE [rbx], LF
	je unsafe_write
	; otherwise incr and continue
	inc rbx
	inc r12
	jmp unsafe_read_loop
unsafe_write:
	; write user input
	lea rbx, BYTE [rbp-unsafe_BUFSZ]
	mov rdx, r12
	mov rsi, rbx
	mov rdi, SYS_stdout
	mov rax, SYS_write
	syscall
	cmp rax, 0
	jl unsafe_err
	; write newline
	mov rdx, 1
	mov rsi, LFc
	mov rdi, SYS_stdout
	mov rax, SYS_write
	syscall
	cmp rax, 0
	jl unsafe_err
	; we're done
	jmp unsafe_end
unsafe_err:
	mov rax, -1
unsafe_end:
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp
ret

global _start
_start:
	call unsafe

	; exit
	mov rdi, EXIT_success
	mov rax, SYS_exit
	syscall
