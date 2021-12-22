%macro call_bubsort 2
	; see bubsort label for details
	mov rsi, %2
	mov rdi, %1
	call bubsort
%endmacro


section .data
	Arr dq 3717, 5515, 7005, 7666, 8705,
	    dq 9538, 9464, 4245, 4333, 1193,
	    dq 4815, 6952, 9429, 6171, 8242,
	    dq 8222, 6392, 9266, 3812, 2805,
	    dq 7263, 2810, 7961, 7765, 3682,
	    dq 5596, 2305, 3129, 5867, 6051,
	    dq 1305, 7647, 7248, 9949, 4249,
	    dq 7539, 1242, 9755, 8766, 3331,
	    dq 4324, 3347, 1244, 2619, 4539,
	    dq 2422, 3052, 6186, 4427, 4201,
	
	Len dq 50

section .text
global bubsort
global _start

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


_start:
	call_bubsort Arr, QWORD [Len]
	
	; exit
	mov rax, 60
	mov rdi, 0
	syscall
