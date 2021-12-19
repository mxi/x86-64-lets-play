section .text
global bubsort

bubsort:
	; In-place array bubble sort.
	; PARAMS
	;     rdi = arr ptr (int64*)
	;     rsi = arr len (unsigned int64)
	; RETURN
	;     rax = arr ptr (0 on failure)

	; validations
	mov rax, 0
	cmp rdi, 0
	jz bubsort_end

	cmp rsi, 0
	jz bubsort_end

	; begin
	mov rax, rdi
	mov rcx, rsi
	dec rcx
bubsort_pass_loop:
	mov r8, 0 ; noswap = 0, swap = 1
	mov rdi, 0
bubsort_swap_loop:
	cmp rdi, rcx
	jae bubsort_swap_loop_end
	mov r10, QWORD [rax+rdi*8]
	mov r11, QWORD [rax+rdi*8+8]
	cmp r10, r11
	jle bubsort_noswap
	mov QWORD [rax+rdi*8], r11
	mov QWORD [rax+rdi*8+8], r10
	or r8, 1
bubsort_noswap:
	inc rdi
	jmp bubsort_swap_loop
bubsort_swap_loop_end:
	cmp r8, 0
	jz bubsort_end
	loop bubsort_pass_loop
bubsort_end:
ret
