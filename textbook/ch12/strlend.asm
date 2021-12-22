%macro call_strlend 4
	mov  cl, %4
	mov rdx, %3
	mov rsi, %2
	mov rdi, %1
	call strlend
%endmacro

section .data
	Str1 db "Hello World", 0
	Str2 db 0
	Str3 db "Hello,World,", 0
	Str4 db "No matching delimiter", 0

section .bss
	Len1   resq 1
	Len2   resq 1
	Len3   resq 1
	Len4   resq 1

	ChrPt1 resq 1
	ChrPt2 resq 1
	ChrPt3 resq 1
	ChrPt4 resq 1

section .text
global strlend
global _start

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

_start:
	call_strlend ChrPt1, Str1, 4096, 0
	mov QWORD [Len1], rax
	call_strlend ChrPt2, Str2, 4096, 0
	mov QWORD [Len2], rax
	call_strlend ChrPt3, Str3, 4096, ","
	mov QWORD [Len3], rax
	call_strlend ChrPt4, Str4, 4096, "!"
	mov QWORD [Len4], rax

	; exit
	mov rax, 60
	mov rdi, 0
	syscall
