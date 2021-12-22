%include "constants.asm"
%include "itosd_only.asm"
%include "printline_only.asm"

section .data
	NTH      equ 2 ; no. threads spawned
	MAX      equ 1000000000 ; sum loop required
	ValBufSz equ 64
	Val      dq 0
	X        dq 1
	Y        dq 1

section .bss
	ThrIds dq NTH
	ValBuf db ValBufSz

section .text
extern pthread_create
extern pthread_join
global main
main:
	push rbp
	mov rbp, rsp
	push r12
	push r13  ; align 16-bytes

	; spawn threads
	mov r12, 0
main_spawn_thread_loop:
	cmp r12, NTH
	je main_spawn_thread_loop_end
	; pthread_create(&ThrIds[r12], NULL, thread_func, NULL);
	mov rcx, NULL
	mov rdx, thread_func
	mov rsi, NULL
	lea rdi, QWORD [ThrIds+r12*8]
	call pthread_create
	; for part 1, we have to run threads in series
	; mov rsi, NULL
	; mov rdi, QWORD [ThrIds+r12*8]
	; call pthread_join
	inc r12
	jmp main_spawn_thread_loop
main_spawn_thread_loop_end:

	; join threads
	mov r12, 0
main_join_loop:
	cmp r12, NTH
	je main_join_loop_end
	mov rsi, NULL
	mov rdi, QWORD [ThrIds+r12*8]
	call pthread_join
	inc r12
	jmp main_join_loop
main_join_loop_end:

	; itos result and print it
	mov  cl, NULL
	mov rdx, ValBufSz
	mov rsi, ValBuf
	mov rdi, QWORD [Val]
	call itosd

	mov rdi, ValBuf
	call printline

	; exit
	mov rdi, EXIT_success
	mov rax, SYS_exit
	syscall
main_end:
	pop r13
	pop r12
	mov rsp, rbp
	pop rbp
ret

; for part 1, use the naive function which access global variable
; thread_func:
; 	push rbx
; 	mov rax, MAX
; 	mov rbx, NTH
; 	cqo
; 	div rbx
; 	mov rcx, rax
; thread_sum_loop:
; 	mov rax, QWORD [Val]
; 	cqo
; 	div QWORD [X]
; 	add rax, QWORD [Y]
; 	mov QWORD [Val], rax
; 	loop thread_sum_loop
; thread_func_end:
; 	pop rbx
; ret

; for part 3, use smarter function that computes sum locally
thread_func:
	push rbx
	push r12 ; contains X
	push r13 ; contains Y
	mov rax, MAX
	mov rbx, NTH
	cqo
	div rbx
	mov rcx, rax
	mov r12, QWORD [X]
	mov r13, QWORD [Y]
	mov rax, 0 ; sum
thread_sum_loop:
	cqo
	div r12
	add rax, r13
	loop thread_sum_loop
	lock add QWORD [Val], rax
thread_func_end:
	pop r13
	pop r12
	pop rbx
ret
