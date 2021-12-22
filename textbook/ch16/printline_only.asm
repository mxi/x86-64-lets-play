%include "constants.asm"

section .rodata
	LFc db LF

section .text
global printline
printline:
	; Emulates stdio's puts()
	; PARAMS
	;     rdi = buf ptr, null terminated (char*)
	; RETURN
	;     void

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
	mov rsi, LFc
	mov rdi, SYS_stdout
	mov rax, SYS_write
	syscall
printline_end:
ret
