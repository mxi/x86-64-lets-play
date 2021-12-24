%macro call_itosfr 3
	; see itosfr label for details
	mov rdx, %3
	mov rsi, %2
	mov rdi, %1
	call itosfr
%endmacro


section .data
	Num1 dq - 28291946
	Num2 dq  401984161
	Num3 dq   73236900
	Num4 dq -492079933
	Num5 dq  199821803

section .bss
	Buffer1 resb 32
	Buffer2 resb 32
	Buffer3 resb 32
	Buffer4 resb 32
	Buffer5 resb 32
	

section .text
global itosfr
global _start

itosfr:
	; Integer to string format right aligned, space padded.
	; PARAMS
	;     rdi = buf ptr (char*)
	;     rsi = buf len (unsigned int64)
	;     rdx = num (int64)
	; RETURN
	;     rax = buf ptr (0 on failure)
	push rbx

	; validations
	mov rax, 0
	cmp rdi, 0 
	jz itosfr_end

	cmp rsi, 0
	jz itosfr_end

	; push digits
	mov r8, 0
	mov rbx, 10
	mov rcx, 0
	mov rax, rdx
	cmp rax, 0
	jge itosfr_push_loop
	mov r8, 1 ; isnegative = true
	neg rax
itosfr_push_loop:
	cqo
	div rbx
	push rdx
	inc rcx
	cmp rax, 0
	ja itosfr_push_loop

	; pop digits
	mov rax, rdi ; save buffer ptr in rax for return
	cmp r8, 0
	je itosfr_pop_loop_prepare
	mov r9, 0
	mov r9b, "-"
	sub r9, "0"
	push r9
	inc rcx
itosfr_pop_loop_prepare:
	cmp rcx, rsi
	jb itosfr_digit_underflow
itosfr_digit_overflow:
	mov r9, rcx
	sub r9, rsi
	inc r9
	lea rsp, QWORD [rsp+r9*8]
	mov rcx, rsi
	dec rcx
	jmp itosfr_pop_loop
itosfr_digit_underflow:
	mov r9, rsi
	sub r9, rcx
	dec r9
	add r9, rdi
itosfr_pad_loop:
	cmp rdi, r9
	jae itosfr_pop_loop
	mov BYTE [rdi], " "
	inc rdi
	jmp itosfr_pad_loop
itosfr_pop_loop:
	pop rdx
	add rdx, "0"
	mov BYTE [rdi], dl
	inc rdi
	loop itosfr_pop_loop
	mov BYTE [rdi], 0

itosfr_end:
	pop rbx
ret ; itosfr

_start:
	call_itosfr Buffer1, 8, QWORD [Num1]
	call_itosfr Buffer2, 8, QWORD [Num2]
	call_itosfr Buffer3, 8, QWORD [Num3]
	call_itosfr Buffer4, 8, QWORD [Num4]
	call_itosfr Buffer5, 8, QWORD [Num5]

	; exit
	mov rax, 60
	mov rdi, 0
	syscall
