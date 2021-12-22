%include "constants.asm"

section .rodata
	LFc db LF

section .text
global canary
canary:
	; Obtains a line of input from STDIN and prints it back out to
	; STDOUT with a fixed, unsafe buffer size.
	;
	; This time, we implement a twig and check if it's broken
	; before we call ret.
	;
	; RETURN
	;     rax = 0 on success, -1 on failure
	canary_BUFSZ equ 72 ; because of the extra 8 byte canary, drop it 
	                    ; from 80 -> 72
	push rbp
	mov rbp, rsp
	; set the canary field
	push rsp
	mov DWORD [rsp], 0xCDCDCDCD
	; go about the stack
	sub rsp, canary_BUFSZ
	push rbx
	push r12

	lea rbx, BYTE [rbp-canary_BUFSZ-8] ; take into account canary
	mov r12, 0 ; count
canary_read_loop:
	; read one char at a time
	mov rdx, 1
	mov rsi, rbx
	mov rdi, SYS_stdin
	mov rax, SYS_read
	syscall
	cmp rax, 0
	jl canary_err
	; check if LF, break
	cmp BYTE [rbx], LF
	je canary_write
	; otherwise incr and continue
	inc rbx
	inc r12
	jmp canary_read_loop
canary_write:
	; check canary
	cmp DWORD [rbp-8], 0xCDCDCDCD
	je canary_write_continue 
	; sound alarms (by exiting)
	mov rdi, 103
	mov rax, 60
	syscall
canary_write_continue:
	; write user input
	lea rbx, BYTE [rbp-canary_BUFSZ-8]
	mov rdx, r12
	mov rsi, rbx
	mov rdi, SYS_stdout
	mov rax, SYS_write
	syscall
	cmp rax, 0
	jl canary_err
	; write newline
	mov rdx, 1
	mov rsi, LFc
	mov rdi, SYS_stdout
	mov rax, SYS_write
	syscall
	cmp rax, 0
	jl canary_err
	; we're done
	jmp canary_end
canary_err:
	mov rax, -1
canary_end:
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp
ret

global _start
_start:
	call canary

	; exit
	mov rdi, EXIT_success
	mov rax, SYS_exit
	syscall
