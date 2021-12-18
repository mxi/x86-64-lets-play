%include "constants.asm"


section .text
global printline
printline:
	; Emulates stdio's puts()
	; PARAMS
	;     rdi = buf ptr, null terminated (char*)
	; RETURN
	;     void
%define printline_LF BYTE [rbp-1]
	push rbp
	mov rbp, rsp
	dec rsp ; space for LF character
	mov printline_LF, 0x0a

	; validation
	cmp rdi, 0
	jz printline_end

	; puts
	mov rsi, rdi
printline_strlen_loop:
	cmp BYTE [rsi], 0
	jz printline_strlen_loop_end
	inc rsi
	jmp printline_strlen_loop
printline_strlen_loop_end:
	; write line
	mov rdx, rsi
	sub rdx, rdi
	mov rsi, rdi
	mov rdi, SYS_stdout
	mov rax, SYS_write
	syscall
	; write newline character 
	mov rdx, 1
	lea rsi, printline_LF
	mov rdi, SYS_stdout
	mov rax, SYS_write
	syscall
printline_end:
	mov rsp, rbp
	pop rbp
ret
