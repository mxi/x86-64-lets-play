%include "nisqrt_alone.asm"

%macro call_stats 10
	push     %10
	push     %9
	push     %8
	push     %7
	mov r9,  %6
	mov r8,  %5
	mov rcx, %4
	mov rdx, %3
	mov rsi, %2
	mov rdi, %1
	call stats
	add rsp, 32 ; clear stack
%endmacro

%macro require_non_null 2
	; %1 = ptr
	; %2 = label
	cmp %1, 0
	jz %2
%endmacro


section .data
	Arr dq 1173, 1516, 1523, 2001, 2122,
	    dq 2169, 2244, 2512, 2614, 2638,
	    dq 2959, 3130, 3333, 3834, 3864,
	    dq 3928, 4421, 4533, 4843, 4928,
	    dq 5018, 5114, 5439, 5456, 5513,
	    dq 5565, 5580, 5634, 5912, 5995,
	    dq 6081, 6900, 7325, 7337, 7658,
	    dq 7789, 7825, 7842, 7851, 8034,
	    dq 8091, 8107, 8269, 8377, 8435,
	    dq 8750, 9035, 9439, 9468, 9940,
	
	Len dq 50

section .bss
	Min  resq 1
	Med1 resq 1
	Med2 resq 1
	Max  resq 1
	Sum  resq 1
	Avg  resq 1
	Var  resq 1
	Stdv resq 1

section .text
global stats
global _start

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
	call_nisqrt rax
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

_start:
	call_stats Arr, QWORD [Len], Min, Med1, Med2, Max, Sum, Avg, Var, Stdv

	; exit
	mov rax, 60
	mov rdi, 0
	syscall
