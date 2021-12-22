%macro call_nisqrt 1
	mov rdi, %1
	call nisqrt
%endmacro

section .data
	NumArr  dq   0,  1,  2,  3,  4,  5,  6,  7,  8,  9,
	        dq  10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
	        dq  20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
	        dq  30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
	        dq  40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
	        dq  50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
	        dq  60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
	        dq  70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
	        dq  80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
	        dq  90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
	        dq 100,
	
	Len    equ 101

section .bss
	SqrtArr resq Len

section .text
global nisqrt
global _start

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

_start:
	; mov rdi, QWORD [Num1]
	; call nisqrt
	; mov QWORD [Sqrt1], rax

	mov rcx, Len
	mov r14, NumArr
	mov r15, SqrtArr
_start_sqrt_loop:
	mov rdi, QWORD [r14]
	call nisqrt
	mov QWORD [r15], rax
	add r14, 8
	add r15, 8
	loop _start_sqrt_loop

	; exit
	mov rax, 60
	mov rdi, 0
	syscall
