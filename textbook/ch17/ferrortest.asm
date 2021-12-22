%include "constants.asm"


section .rodata
	File db "ferrortest.txt", 0
	BufSz equ 65535

section .bss
	Buf resb BufSz

section .text
global _start
_start:
	; open to read
	mov rdx, 0
	mov rsi, 0
	or  rsi, O_RDONLY
	mov rdi, File
	mov rax, SYS_open
	syscall
	cmp rax, 0
	jl _start_err_open

	; save fd
	mov r12, rax

	; read more than we need to
	mov rdx, BufSz
	mov rsi, Buf
	mov rdi, r12
	mov rax, SYS_read
	syscall
	cmp rax, 0
	jl _start_err_read1

	; read even more
	mov rdx, BufSz
	mov rsi, Buf
	mov rdi, r12
	mov rax, SYS_read
	syscall
	jl _start_err_read2

	; close
	mov rdi, r12
	mov rax, SYS_close
	syscall
	cmp rax, 0
	jl _start_err_close
	
	; exit
	mov rdi, EXIT_success
	jmp _start_end
_start_err_close:
	mov rdi, 4
	jmp _start_end
_start_err_read2:
	mov rdi, 3
	jmp _start_end
_start_err_read1:
	mov rdi, 2
	jmp _start_end
_start_err_open:
	mov rdi, 1
	jmp _start_end
_start_end:
	mov rax, SYS_exit
	syscall
