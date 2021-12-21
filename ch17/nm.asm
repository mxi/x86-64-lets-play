%include "constants.asm"


section .rodata
	EMsgFewArgs db "too few arguments: nm INFILE OUTFILE", LF, 0
	EMsgLotArgs db "too many arguments: nm INFILE OUTFILE", LF, 0
	EMsgSrcOpen db "failed to open INFILE: nm INFILE OUTFILE", LF, 0
	EMsgDstOpen db "failed to open OUTFILE: nm INFILE OUTFILE", LF, 0

section .data
	RdBufSz equ 128
	WrBufSz equ 128

section .bss
	RdItr resq 1 ; read buffer iterator 
	RdEnd resq 1 ; points to end of valid date in the read buffer
	RdFiDes resq 1
	RdBuf resb RdBufSz

	WrItr resq 1 ; write buffer iterator
	WrEnd resq 1 ; points to the end of the buffer always
	WrFiDes resq 1
	WrBuf resb WrBufSz

	NumBuf resb 5

section .text
global _start
global readbuf
global writebuf
global print
global itos

_start:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15

	; check args
	; argv[1] ~ rbp+24 -- source file path
	; argv[2] ~ rbp+32 -- dest file path
	mov r12, QWORD [rbp+8] ; argc
	cmp r12, 3
	jl _start_err_few_args
	jg _start_err_lot_args

	; try open source file -- argv[1]
	mov rdx, 0
	mov rsi, 0
	or  rsi, O_RDONLY
	mov rdi, QWORD [rbp+24]
	mov rax, SYS_open
	syscall
	cmp rax, 0
	jl _start_err_src_open
	mov QWORD [RdFiDes], rax

	; try open/create dest file -- argv[2]
	mov rdx, 0
	or  rdx, S_IRUSR
	or  rdx, S_IWUSR
	or  rdx, S_IRGRP
	or  rdx, S_IROTH
	mov rsi, 0
	or  rsi, O_CREAT
	or  rsi, O_WRONLY
	mov rdi, QWORD [rbp+32]
	mov rax, SYS_open
	syscall
	cmp rax, 0
	jl _start_err_dst_open
	mov QWORD [WrFiDes], rax

	; number input file lines and transfer to output
	mov rbx, 1 ; line numbers
	jmp _start_flush ; actually starts the loop
_start_read_loop:
	call readbuf
	mov r12, QWORD [RdItr]
	cmp r13, QWORD [RdEnd]
	je _start_read_loop_end
_start_transfer_loop:
	cmp r14, r15
	je _start_flush
	cmp r12, r13
	je _start_read_loop
	mov r10b, BYTE [r12]
	mov BYTE [r14], r10b
	inc r12
	inc r14
	cmp r10b, LF ; if newline, flush
	jne _start_transfer_loop
_start_flush:
	call writebuf ; when write buffer is empty, this is basically noop

	mov r14, QWORD [WrItr]
	mov r15, QWORD [WrEnd]
	jmp _start_transfer_loop
_start_read_loop_end:
	

	; close file descriptors
	mov rdi, RdFiDes
	mov rax, SYS_close
	syscall

	mov rdi, WrFiDes
	mov rax, SYS_close
	syscall

	; all good, skip error handlers
	mov rdi, EXIT_success
	jmp _start_end

	; error handling 
%macro _start_ehandler 3
_start_err_%1:
	mov rsi, %2
	mov rdi, SYS_stderr
	call print
	mov rdi, %3
	jmp _start_end
%endmacro

	_start_ehandler dst_open, EMsgDstOpen, 4
	_start_ehandler src_open, EMsgSrcOpen, 3
	_start_ehandler few_args, EMsgFewArgs, 2
	_start_ehandler lot_args, EMsgLotArgs, 1
; _start_err_src_open:
; 	mov rsi, EMsgSrcOpen
; 	mov rdi, SYS_stderr
; 	call print
; 	mov rdi, 3
; 	jmp _start_end
; _start_err_few_args:
; 	mov rsi, EMsgFewArgs
; 	mov rdi, SYS_stderr
; 	call print
; 	mov rdi, 2
; 	jmp _start_end
; _start_err_lot_args:
; 	mov rsi, EMsgLotArgs
; 	mov rdi, SYS_stderr
; 	call print
; 	mov rdi, 1
; 	jmp _start_end
_start_end:
	mov rsp, rbp
	pop rbp
	; exit
	mov rax, SYS_exit
	syscall


print:
	; Prints a null terminated string to the given file descriptor.
	; PARAMS
	;     rdi = file descriptor (int64)
	;     rsi = buf ptr, null terminated (char*)
	; RETURN
	;     void

	; validation
	cmp rdi, 0
	jz print_end
	cmp rsi, 0
	jz print_end

	; puts
	mov r10, rsi
print_strlen_loop:
	cmp BYTE [r10], 0
	jz print_strlen_loop_end
	inc r10
	jmp print_strlen_loop
print_strlen_loop_end:
	mov rdx, r10
	sub rdx, rsi
	; mov rsi, rsi -- already set
	; mov rdi, rdi -- already set
	mov rax, SYS_write
	syscall
print_end:
ret


itos:
	; Writes an integer into a string buffer.
	; PARAMS
	;     rdi = dest buf (char*)
	;     rsi = dest buf len (uint64)
	;     rdx = number (int64)
	; RETURN
	;     rax = position in the buffer right after the number.
	push rbx
	push r12

	; validation
	mov rax, rdi
	cmp rdi, 0
	jz itos_end
	
	cmp rsi, 0
	jz itos_end

	; check for negativity
	mov rax, rdx
	mov rbx, 10
	mov r12, 0 ; 0 = positive, 1 = negative
	mov r13, 0
	cmp rax, 0
	jge itos_digit_push_loop
	mov r12, 1
	inc r13
	neg rax
itos_digit_push_loop:
	cmp r13, rsi
	je itos_digit_push_loop_end
	xor rdx, rdx
	div rbx
	add rdx, 0x30
	push rdx
	inc r13
	cmp rax, 0
	je itos_digit_push_loop_end
	jmp itos_digit_push_loop
itos_digit_push_loop_end:
	cmp r12, 1
	jne itos_digit_pop_loop
	mov rbx, 0
	mov  bl, "-"
	push rbx
itos_digit_pop_loop:
	cmp r13, 0
	je itos_end
	pop r12
	mov BYTE [rdi], r12b
	inc rdi
	dec r13
	jmp itos_digit_pop_loop
itos_end:
	mov rax, rdi
	pop r12
	pop rbx
ret
