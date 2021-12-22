section .text
global nisqrt

nisqrt:
	; Nearest integer square root.
	; PARAM
	;     rdi = num (unsigned int64)
	; RETURN
	;     rax = num sqrt (unsigned int64)
	push rbx

	mov r10, 0
	mov r11, rdi
	mov rbx, r11
nisqrt_bin_loop:
	mov rax, r11
	sub rax, r10
	cmp rax, 1
	jbe nisqrt_bin_loop_end
	shr rax, 1
	add rax, r10
	mov rbx, rax ; rbx is temp for sqrt est.
	mul rax
	cmp rax, rdi
	jb nisqrt_too_low
	ja nisqrt_too_high
	jmp nisqrt_bin_loop_end ; matches exactly
nisqrt_too_low:
	mov r10, rbx
	jmp nisqrt_bin_loop
nisqrt_too_high:
	mov r11, rbx
	jmp nisqrt_bin_loop
nisqrt_bin_loop_end:
	mov rax, rbx
	mul rax
	cmp rax, rdi
	jb nisqrt_test_incr_nearest
	ja nisqrt_test_decr_nearest
	jmp nisqrt_test_end
nisqrt_test_incr_nearest:
	mov r10, rdi
	sub r10, rax ; delta rdi - rbx^2
	mov rax, rbx
	inc rax
	mul rax
	mov r11, rax
	sub r11, rdi ; delta (rbx+1)^2 - rdi
	cmp r10, r11
	ja nisqrt_test_accept_incr
	jmp nisqrt_test_end
nisqrt_test_accept_incr:
	inc rbx
	jmp nisqrt_test_end
nisqrt_test_decr_nearest:
	mov r10, rax
	sub r10, rax ; delta rbx^2 - rdi
	mov rax, rbx
	dec rax
	mul rax
	mov r11, rdi
	sub r11, rax ; delta rdi - (rbx-1)^2
	cmp r10, r11
	ja nisqrt_test_accept_decr
	jmp nisqrt_test_end
nisqrt_test_accept_decr:
	dec rbx
nisqrt_test_end:
	mov rax, rbx
nisqrt_end:
	pop rbx
ret
