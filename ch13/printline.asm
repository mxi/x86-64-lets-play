%include "constants.asm"

%macro call_printline 1
	mov rdi, %1
	call printline
%endmacro


section .rodata
	LFc           db LF

	Str1          db "Hello World", 0
	Str2          db 0
	Str3          db "John", LF, "From", LF, "Uptown", 0

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

global _start
_start:
	call_printline Str1
	call_printline Str2
	call_printline Str3

	; exit
	mov rax, SYS_exit
	mov rdi, EXIT_success
	syscall

