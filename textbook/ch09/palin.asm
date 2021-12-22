section .data
	Phrase db  "A man, a plan, a canal — Panama!", 0
	; Phrase db 0
	; Phrase db "Kevin", 0
	; Phrase db "Anna", 0

	; valid ascii ranges
	RangeStarts db 0x30, 0x41, 0x61
	RangeEnds   db 0x39, 0x5a, 0x7a

	NRANGES     equ 3

section .text
global _start
	; rsi = Phrase
	; while (*rsi)
	;   if acceptable_ascii(*rsi)
	;     push *rsi
	;   ++rsi
	; 
	; rsi = Phrase
	; palin = true
	; while (*rsi)
	;   if acceptable_ascii(*rsi)
	;      if (*rsi != pop)
	;        palin = false
	;        break
_start:
	mov rsi, Phrase

push_loop: ; --------------------------------
	cmp BYTE [rsi], 0
	jne push_loop_cont
	jmp push_loop_end

push_loop_cont:
	mov r14, RangeStarts
	mov r15, RangeEnds
	mov rcx, NRANGES

push_check_ascii_loop:
	mov al, BYTE [r15]
	sub al, BYTE [r14]
	mov bl, BYTE [rsi]
	sub bl, BYTE [r14]
	
	cmp bl, al
	jbe push_accept_ascii

	inc r14
	inc r15
	loop push_check_ascii_loop
	jmp push_end_ascii_check

push_accept_ascii:
	; within range so remove 0x20
	; to normalize alpha case
	mov rax, 0
	mov al, BYTE [rsi]
	and al, 0xdf ; ~0x20
	push rax

push_end_ascii_check:
	inc rsi
	jmp push_loop

push_loop_end:

	mov rsi, Phrase
	mov rdi, 0
pop_loop: ; --------------------------------
	cmp BYTE [rsi], 0
	jne pop_loop_cont 
	jmp pop_loop_end

pop_loop_cont:
	mov r14, RangeStarts
	mov r15, RangeEnds
	mov rcx, NRANGES

pop_check_ascii_loop:
	mov al, BYTE [r15]
	sub al, BYTE [r14]
	mov bl, BYTE [rsi]
	sub bl, BYTE [r14]
	
	cmp bl, al
	jbe pop_accept_ascii

	inc r14
	inc r15
	loop pop_check_ascii_loop
	jmp pop_end_ascii_check

pop_accept_ascii:
	; within range so remove 0x20
	; to normalize alpha case
	mov rax, 0
	mov rbx, 0
	mov al, BYTE [rsi]
	and al, 0xdf ; ~0x20
	pop rbx
	cmp rax, rbx
	jne not_palindrome

pop_end_ascii_check:
	inc rsi
	jmp pop_loop

not_palindrome:
	mov rdi, 1

pop_loop_end:

prog_exit:
	mov rax, 60
	syscall
