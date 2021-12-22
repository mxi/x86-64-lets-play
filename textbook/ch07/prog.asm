section .data
	limit        dq 10
	sq_sum       dq 0

	SYS_EXIT     equ 60
	EXIT_SUCCESS equ 0

section .text
global _start

_start:
	mov rcx, QWORD [limit]
	mov rbx, 1
loop_start:
	; while (rcx != 0)
	;   rax = rbx
	;   sq_sum += rax * rax
	;   rbx++
	;   rax--
	mov rax, rbx
	mul rax
	add QWORD [sq_sum], rax
	inc rbx
	dec rcx
	cmp rcx, 0
	jne loop_start
	; end loop
prog_exit:
	mov rax, SYS_EXIT
	mov rdi, EXIT_SUCCESS
	syscall
