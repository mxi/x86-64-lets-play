%include "constants.asm"
%include "printline_only.asm"


section .rodata
	File db "data.txt", 0
	BufSz equ 128

section .bss
	Buf resb BufSz

section .text
global freadline
freadline:
	; Reads a line from STDIN into the given buffer.
	; PARAM
	;     rdi = buf ptr (char*)
	;     rsi = buf len, including null terminator (uint64)
	;     rdx = fd (int64)
	; RETURN
	;     rax = no. chars read excluding null terminator (-1 on failure)
	freadline_BUFSZ equ 256

	push rbp
	mov rbp, rsp
	sub rsp, freadline_BUFSZ ; create local buffer to read into [rbp-256]
	push rbx
	push r12
	push r13
	push r14

	mov r13, rdx ; save fd 
	mov r14, 0 ; position in file will be here

	; prepare for readbuf_loop now so we don't have to save params
	mov rbx, rdi ; save rdi for later
	mov r10, rdi ; iterator
	mov r11, rsi ; buf countdown
	dec r11 ; make room for null terminator

	; obtain the current file pos
	mov rdx, SEEK_CUR
	mov rsi, 0
	mov rdi, r13
	mov rax, SYS_lseek
	syscall
	cmp rax, 0
	jl freadline_err
	mov r14, rax

freadline_readbuf_loop:
	lea r12, BYTE [rbp-freadline_BUFSZ]
	mov rdx, freadline_BUFSZ
	mov rsi, r12
	mov rdi, r13
	mov rax, SYS_read
	push r11 ; save
	push r10 ; save
	syscall
	pop r10 ; restore
	pop r11 ; restore
	cmp rax, 0
	jl freadline_err
	je freadline_readbuf_loop_end
freadline_strcpy_loop:
	cmp r11, 0
	je freadline_readbuf_loop_end
	cmp r12, rbp
	je freadline_readbuf_loop
	cmp rax, 0
	je freadline_readbuf_loop
	inc r14 ; increment file position before rest to skip LF
	mov dl, BYTE [r12]
	cmp dl, LF
	je freadline_readbuf_loop_end
	mov BYTE [r10], dl
	dec rax
	inc r10
	dec r11
	inc r12
	jmp freadline_strcpy_loop
freadline_readbuf_loop_end:
	; if we overread, seek back
	push r10 ; save
	mov rdx, SEEK_SET
	mov rsi, r14
	mov rdi, r13
	mov rax, SYS_lseek
	syscall
	cmp rax, 0
	jl freadline_err
	pop r10 ;restore 
	; set return pointer
	mov BYTE [r10], 0
	mov rax, r10
	sub rax, rbx
	jmp freadline_end
freadline_err:
	mov rax, -1
freadline_end:
	pop r14
	pop r13
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp
ret

global _start
_start:
	; try open a data file
	mov rdx, 0
	mov rsi, 0
	or  rsi, O_RDONLY
	mov rdi, File
	mov rax, SYS_open
	syscall
	cmp rax, 0
	jl _start_err
	mov r12, rax ; r12 now has fd

	; test it out
_start_read_loop:
	mov rdx, r12
	mov rsi, BufSz
	mov rdi, Buf
	call freadline
	cmp rax, 0
	jle _start_read_loop_end
	mov rdi, Buf
	call printline
	jmp _start_read_loop
_start_read_loop_end:

	; close data file
	mov rdi, r12
	mov rax, SYS_close
	syscall
	cmp rax, 0
	jl _start_err

	; exit
	mov rdi, EXIT_success
	jmp _start_end
_start_err:
	mov rdi, EXIT_failure
_start_end:
	mov rax, SYS_exit
	syscall
