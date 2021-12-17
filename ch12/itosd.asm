%macro call_itosd 4
	mov rcx, %4
	mov rdx, %3
	mov rsi, %2
	mov rdi, %1
	call itosd
%endmacro


section .data
	Num1 dq -22938
	Num2 dq  84935
	Num3 dq  0xFAFAFAFAFAFAFAFA ; should not be written (buf 0)
	Num4 dq  0xCDCDCDCDCDCDCDCD ; should not be written (buf 1)
	Num5 dq  11222 ; only 2's should be written (buf 4, 3 chars)
	Num6 dq -12345 ; only 12345 should be written (buf 6, 5 chars)
	Num7 dq  54321 ; should end with a comma (,)
	Num8 dq  19283 ; should end with an ex. pt. (!)

section .bss
	Str1 resb 32
	Str2 resb 32
	Str3 resb  0
	Str4 resb  1
	Str5 resb  4
	Str6 resb  6
	Str7 resb 32
	Str8 resb 32

section .text
global itosd
global _start


itosd:
	; Integer to string terminated by given delimiter.
	; PARAMS
	;     rdi = num (int64)
	;     rsi = buf ptr (char*)
	;     rdx = buf len (unsigned int64)
	;      cl = ASCII delimiter (char)
	; RETURN
	;     rax = ptr to end delimiter in `buf ptr' (0 on failure)
	push rbx
	push r12

	; validations
	mov rax, 0
	cmp rsi, 0 
	jz itosd_end

	cmp rdx, 0
	jz itosd_end

	; push digits
	mov r12, rdx ; save rdx value for following arithmetic
	mov rbx, 10
	mov r10, 0 ; 0 = positive, 1 = negative
	mov r11, 0 ; counter
	mov rax, rdi
	cmp rax, 0
	jge itosd_push_loop
	mov r10, 1
	neg rax
itosd_push_loop:
	cqo
	div rbx
	push rdx
	inc r11
	cmp rax, 0
	ja itosd_push_loop
	mov rdx, r12

	; pop digits
	mov rax, rsi ; save buffer ptr in rax for return
	cmp r10, 0 ; if negative, add minus sign
	je itosd_pop_loop_prepare
	mov r12, 0
	mov r12b, "-"
	sub r12, "0" ; "0" is added back later
	push r12
	inc r11
itosd_pop_loop_prepare:
	cmp r11, rdx
	jb itosd_pop_loop
itosd_digit_overflow:
	mov r12, r11
	sub r12, rdx
	inc r12
	lea rsp, [rsp+r12*8] ; remove overflow characters
	sub r11, r12
itosd_pop_loop:
	cmp r11, 0
	je itosd_pop_loop_end
	pop r12
	add r12, "0"
	mov BYTE [rax], r12b
	inc rax
	dec r11
	jmp itosd_pop_loop
itosd_pop_loop_end:
	mov BYTE [rax], cl
itosd_end:
	pop r12
	pop rbx
ret ; itosd

_start:
	call_itosd QWORD [Num1], Str1, 32, 0
	call_itosd QWORD [Num2], Str2, 32, 0
	call_itosd QWORD [Num3], Str3,  0, 0
	call_itosd QWORD [Num4], Str4,  1, 0
	call_itosd QWORD [Num5], Str5,  4, 0
	call_itosd QWORD [Num6], Str6,  6, 0
	call_itosd QWORD [Num7], Str7, 32, ","
	call_itosd QWORD [Num8], Str8, 32, "!"
	
	; exit
	mov rax, 60
	mov rdi, 0
	syscall
