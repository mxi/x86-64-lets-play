section .text
global itosd
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
