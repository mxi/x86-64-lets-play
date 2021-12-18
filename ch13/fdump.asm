%include "constants.asm"
%include "strlend_only.asm"


section .rodata
	File db "fdump.data-out", 0
	Data db "Hello world, how are you", 0

section .text
global fdump
fdump:
	; Dumps contents of a given buffer into the specified file.
	; PARAM
	;    rdi = file path, null terminated (char*)
	;    rsi = buf ptr (char*)
	;    rdx = buf size (uint64)
	; RETURN
	;    rax = no. bytes written (< 0 on failure)
	;        = -1 (failed to open)
	;        = -2 (failed to close)
	;        = -3 (failed to write)
	;        = -4 (null file path)
	;        = -5 (null buf ptr)
	;        = -6 (null buf size)
%define fdump_Lfile   QWORD [rbp-8]
%define fdump_Lbufptr QWORD [rbp-16]
%define fdump_Lbuflen QWORD [rbp-24]
%define fdump_Lfd     QWORD [rbp-32]
%define fdump_Lnwrote QWORD [rbp-40]
	push rbp
	mov rbp, rsp
	sub rsp, 40 ; local variables and register saves

	; validation
	cmp rdi, 0
	je fdump_err_null_file_path
	cmp rsi, 0
	je fdump_err_null_buf_ptr
	cmp rdx, 0
	je fdump_err_null_buf_size

	; save registers and initialize local vars
	mov fdump_Lfile, rdi
	mov fdump_Lbufptr, rsi
	mov fdump_Lbuflen, rdx
	mov fdump_Lfd, -1
	mov fdump_Lnwrote, 0

	; setup open flags & try open
	mov rdx, 0
	or  rdx, S_IWUSR
	or  rdx, S_IRUSR
	or  rdx, S_IRGRP
	mov rsi, 0
	or  rsi, O_CREAT
	or  rsi, O_WRONLY
	; mov rdi, rdi -- already set
	mov rax, SYS_open
	syscall
	cmp rax, 0
	jl fdump_err_open
	mov fdump_Lfd, rax

	; write out buffer contents
	mov rdx, fdump_Lbuflen
	mov rsi, fdump_Lbufptr
	mov rdi, fdump_Lfd
	mov rax, SYS_write
	syscall
	cmp rax, 0
	jl fdump_err_write
	mov fdump_Lnwrote, rax

	; close file
	mov rdi, fdump_Lfd
	mov rax, SYS_close
	syscall
	cmp rax, 0
	jl fdump_err_close

	jmp fdump_finish
fdump_err_null_buf_size:
	mov rax, -6
	jmp fdump_end
fdump_err_null_buf_ptr:
	mov rax, -5
	jmp fdump_end
fdump_err_null_file_path:
	mov rax, -4
	jmp fdump_end
fdump_err_write:
	mov rax, -3
	jmp fdump_end
fdump_err_close:
	mov rax, -2
	jmp fdump_end
fdump_err_open:
	mov rax, -1
	jmp fdump_end
fdump_finish:
	mov rax, fdump_Lnwrote
fdump_end:
	mov rsp, rbp
	pop rbp
ret

global _start
_start:
%define _start_Ldelimptr QWORD [rbp-8]
	push rbp
	mov rbp, rsp
	sub rsp, 8 ; delim ptr room

	; get data length
	mov  cl, 0
	mov rdx, 4096 ; something large for strlend to eat
	mov rsi, Data
	lea rdi, _start_Ldelimptr
	call strlend
	
	; dump the Data string
	mov rdx, rax
	mov rsi, Data
	mov rdi, File
	call fdump

	; restore stack
	mov rsp, rbp
	pop rbp

	; exit
	mov rax, SYS_exit
	mov rdi, EXIT_success
	syscall
