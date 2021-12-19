section .text
global strlend

strlend:
	; Delimited string length, including the delimiter. If a
	; delimiter is not encountered before the first null
	; terminator, the null terminator will be the delimiter.
	; PARAM
	;     rdi = out delimiter location (char**)
	;     rsi = buf ptr (char*)
	;     rdx = buf len (unsigned int64)
	;      cl = ascii delimiter
	; RETURN
	;     rax = strlen (0 on failure) including delimiter
	
	; validation
	mov rax, 0
	mov r10, rsi
	cmp rsi, 0
	jz strlend_finish

	cmp rdx, 0
	jz strlend_finish

strlend_loop:
	cmp BYTE [r10], 0
	je strlend_loop_end
	cmp BYTE [r10], cl
	je strlend_loop_end
	inc r10
	jmp strlend_loop
strlend_loop_end:
	mov rax, r10
	sub rax, rsi
strlend_finish:
	cmp rdi, 0
	jz strlend_end
	mov QWORD [rdi], r10
strlend_end:
ret
