section .text
global stoid
stoid:
	; String to integer with character delimiter. This function ignores
	; any leading spaces as so generated by `itosfr'.
	; PARAM
	;     rdi = out int ptr (int64*)
	;     rsi = buf ptr (char*)
	;     rdx = str len, exclude null term (unsigned int64)
	;      cl = ASCII delimiter (char) @ [cl]
	; RETURN
	;     rax = ptr to next delimiter in `buf ptr' (0 on failure)
	push rbx
	push r12
	push r13

	; validation
	mov rax, 0
	cmp rdi, 0
	jz stoid_end

	cmp rsi, 0
	jz stoid_end

	cmp rdx, 0
	jz stoid_end

	; skip any spaces
	mov QWORD [rdi], 0
	mov rax, rsi ; use rax in case of empty string for easy return
	mov r11, rax
	add r11, rdx ; r11 points to end of `buf ptr'.
stoid_skip_space_loop:
	cmp rax, r11
	je stoid_end ; reached end of string
	cmp BYTE [rax], " "
	jne stoid_skip_space_loop_end
	inc rax
	jmp stoid_skip_space_loop
stoid_skip_space_loop_end:
	mov r10, rax ; rax will be used as the accumulator next

	; check for positive/negative sign
	mov r12, 1 ; 1 = positive, -1 = negative
	cmp BYTE [r10], "-"
	je stoid_negative
	cmp BYTE [r10], "+"
	je stoid_positive
	jmp stoid_nosign
stoid_negative:
	mov r12, -1
stoid_positive:
	inc r10
stoid_nosign:
	
	; load in the digits
	mov rbx, 10 ; base 10
	mov rax, 0
	mov r13, 0 ; clear upper 56 bits for character
stoid_digit_loop:
	cmp r10, r11
	je stoid_digit_loop_end
	mov r13b, BYTE [r10]
	cmp r13b, cl
	je stoid_digit_loop_end
	sub r13b, "0"
	; check for digit validity
	cmp r13b, 0
	jl stoid_digit_loop_end_invalid
	cmp r13b, 9
	jg stoid_digit_loop_end_invalid
	; otherwise, add it to number
	imul rax, rbx
	add rax, r13
	inc r10
	jmp stoid_digit_loop
stoid_digit_loop_end_invalid:
	mov rax, 0 ; now rax is the pointer which on failure is 0
	jmp stoid_end
stoid_digit_loop_end:
	; use r13 as intermediary for QWORD [rdi]
	mov r13, rax
	imul r13, r12
	mov QWORD [rdi], r13
	mov rax, r10 ; restore rax as buf pointer
	
stoid_end:
	pop r13
	pop r12
	pop rbx
ret
