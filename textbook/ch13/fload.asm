%include "constants.asm"
%include "printline_only.asm"


section .rodata
	File    db "fdump.data-out", 0
	BufSz  equ 65535

section .bss
	Buf   resb BufSz

section .text
global fload
fload:
	; Loads the contents of a file into the specified buffer, including
	; a null terminator.
	; PARAM
	;     rdi = file path, null terminated (char*)
	;     rsi = buf ptr (char*)
	;     rdx = buf size, with room for null term. (uint64)
	; RETURN
	;     rax = no. bytes read, excluding null term. (< 0 on failure)
	;         = -1 (failed to open/file not found)
	;         = -2 (failed to close)
	;         = -3 (failed to read)
	;         = -4 (null file path)
	;         = -5 (null buf ptr)
%define fload_Lfile   QWORD [rbp-8]
%define fload_Lbufptr QWORD [rbp-16]
%define fload_Lbuflen QWORD [rbp-24]
%define fload_Lfd     QWORD [rbp-32]
%define fload_Lnread  QWORD [rbp-40]
	push rbp
	mov rbp, rsp
	sub rsp, 40 ; local variables and register saves

	; save registers and initialize local vars
	mov fload_Lfile, rdi
	mov fload_Lbufptr, rsi
	; mov fload_Lbuflen, rdx -- initialized in validation
	mov fload_Lfd, -1
	mov fload_Lnread, 0

	; validation
	cmp rdx, 0
	jl fload_finish
	cmp rsi, 0
	jl fload_err_null_buf_ptr
	cmp rdi, 0
	jl fload_err_null_file_path

	dec rdx ; make room for null terminator
	mov fload_Lbuflen, rdx

	; open file
	mov rdx, 0
	mov rsi, 0
	or  rsi, O_RDONLY
	; mov rdi, rdi -- already set
	mov rax, SYS_open
	syscall
	cmp rax, 0
	jl fload_err_open
	mov fload_Lfd, rax

	; read buffer
	mov rdx, fload_Lbuflen
	mov rsi, fload_Lbufptr
	mov rdi, fload_Lfd
	mov rax, SYS_read
	syscall
	cmp rax, 0
	jl fload_err_read
	mov fload_Lnread, rax
	
	; insert null terminator
	mov rsi, fload_Lbufptr
	lea rsi, BYTE [rsi+rax]
	mov BYTE [rsi], 0

	; close file
	mov rdi, fload_Lfd
	mov rax, SYS_close
	syscall
	cmp rax, 0
	jl fload_err_close
	
	jmp fload_finish
fload_err_null_buf_ptr:
	mov rax, -5
	jmp fload_end
fload_err_null_file_path:
	mov rax, -4
	jmp fload_end
fload_err_read:
	mov rax, -3
	jmp fload_end
fload_err_close:
	mov rax, -2
	jmp fload_end
fload_err_open:
	mov rax, -1
	jmp fload_end
fload_finish:
	mov rax, fload_Lnread
fload_end:
	mov rsp, rbp
	pop rbp
ret

global _start
_start:
	mov rdx, BufSz
	mov rsi, Buf
	mov rdi, File
	call fload

	; print the content
	mov rdi, Buf
	call printline

	; exit
	mov rax, SYS_exit
	mov rdi, EXIT_success
	syscall
