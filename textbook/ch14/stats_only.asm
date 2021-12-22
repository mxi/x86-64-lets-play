%include "nisqrt_only.asm"

%macro require_non_null 2
	; %1 = ptr
	; %2 = label
	cmp %1, 0
	jz %2
%endmacro


section .text
global stats

stats:
	; Compute statistics of a sorted integer array.
	; PARAM
	;     rdi = arr ptr (int64*)
	;     rsi = arr len (unsigned int64)
	;     rdx = min ptr (int64*)
	;     rcx = med1 ptr (int64*)
	;     r8  = med2 ptr (int64*)
	;     r9  = max ptr (int64*)
	;     rbp+16 = sum ptr (int64*)
	;     rbp+24 = avg ptr (int64*)
	;     rbp+32 = var ptr (int64*)
	;     rbp+40 = stdev ptr (int64*)
	; RETURN
	;     rax = arr ptr (0 on failure)
	push rbp
	mov rbp, rsp
	push rbx

	; validations
	mov rax, 0
	require_non_null rdi, stats_end
	require_non_null rsi, stats_end
	require_non_null rdx, stats_end
	require_non_null rcx, stats_end
	require_non_null r8, stats_end
	require_non_null r9, stats_end
	require_non_null QWORD [rbp+16], stats_end
	require_non_null QWORD [rbp+24], stats_end
	require_non_null QWORD [rbp+32], stats_end
	require_non_null QWORD [rbp+40], stats_end

	; fetch min
	mov r10, QWORD [rdi]
	mov QWORD [rdx], r10

	; fetch max
	lea r10, QWORD [rdi+rsi*8-8]
	mov r11, QWORD [r10]
	mov QWORD [r9], r11

	; fetch medians
	mov r10, rsi
	and r10, 1
	jnz stats_med_odd
stats_med_even:
	mov r10, rsi
	shr r10, 1
	mov r11, QWORD [rdi+r10*8-8]
	mov QWORD [rcx], r11
	mov r11, QWORD [rdi+r10*8]
	mov QWORD [r8], r11
	jmp stats_med_end
stats_med_odd:
	mov r10, rsi
	shr r10, 1
	mov r11, QWORD [rdi+r10*8]
	mov QWORD [rcx], r11
	mov QWORD [r8], r11
stats_med_end:

	; compute sum
	mov r10, 0 ; counter
	mov rax, 0 ; total
stats_sum_loop:
	add rax, QWORD [rdi+r10*8]
	inc r10
	cmp r10, rsi
	jb stats_sum_loop
	mov r11, QWORD [rbp+16] ; sum ptr
	mov QWORD [r11], rax

	; compute average
	push rdx
	cqo
	idiv rsi
	mov r11, QWORD [rbp+24] ; avg ptr
	mov QWORD [r11], rax
	pop rdx

	; compute variance
	push rdx
	mov rbx, QWORD [rbp+32] ; var ptr
	mov r10, 0 ; counter
	mov r11, rax ; average
stats_var_loop:
	mov rax, QWORD [rdi+r10*8]
	sub rax, r11
	imul rax
	add QWORD [rbx], rax
	inc r10
	cmp r10, rsi
	jb stats_var_loop

	; divide var ptr by length to get variance
	mov rax, QWORD [rbx]
	mov rdx, 0
	div rsi
	mov QWORD [rbx], rax
	pop rdx

	; compute stdev
	push rdi
	mov rdi, rax
	call nisqrt
	mov rbx, QWORD [rbp+40]
	mov QWORD [rbx], rax
	pop rdi

	; return arr ptr
	mov rax, rdi

stats_end:
	pop rbx
	mov rsp, rbp
	pop rbp
ret
