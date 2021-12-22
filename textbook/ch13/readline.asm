%include "constants.asm"

%macro call_readline 2
	mov rsi, %2
	mov rdi, %1
	call readline
%endmacro


section .data
	BufSize1 equ 8
	BufSize2 equ 32

section .bss
	Buf1 resb BufSize1
	Buf2 resb BufSize2

section .text
global readline
readline:
	; Reads a line from STDIN into the given buffer.
	; PARAM
	;     rdi = buf ptr (char*)
	;     rsi = buf len, including null terminator (uint64)
	; RETURN
	;     rax = no. chars read excluding null terminator.
%define readline_BUFSZ 256
	push rbp
	mov rbp, rsp
	sub rsp, readline_BUFSZ ; create local buffer to read into [rbp-256]
	push rbx
	push r12

	; tracking
	mov rbx, rdi ; save rdi for later
	mov r10, rdi ; iterator
	mov r11, rsi ; buf countdown
	dec r11 ; make room for null terminator
readline_readbuf_loop:
	lea r12, BYTE [rbp-readline_BUFSZ]
	mov rdx, readline_BUFSZ
	mov rsi, r12
	mov rdi, SYS_stdin
	mov rax, SYS_read
	push r11 ; syscall modifies $r11, so save it here
	syscall
	pop r11
	cmp rax, 0
	jl readline_readbuf_err
readline_strcpy_loop:
	cmp r11, 0
	je readline_readbuf_loop_end
	cmp r12, rbp
	je readline_readbuf_loop
	mov dl, BYTE [r12]
	cmp dl, LF
	je readline_readbuf_loop_end
	mov BYTE [r10], dl
	inc r10
	dec r11
	inc r12
	jmp readline_strcpy_loop
readline_readbuf_loop_end:
	mov BYTE [r10], 0
	mov rax, r10
	sub rax, rbx
	jmp readline_end
readline_readbuf_err:
	mov rax, -1
readline_end:
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp
ret

global _start
_start:
	; test it out
	call_readline Buf1, BufSize1
	call_readline Buf2, BufSize2

	; exit
	mov rax, SYS_exit
	mov rdi, EXIT_success
	syscall
