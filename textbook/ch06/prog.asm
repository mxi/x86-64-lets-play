section .data
	EXIT_SUCCESS equ 0
	SYS_exit     equ 60

	; bytes
	bVar1   db 17
	bVar2   db 9

	; words 
	wVar1   dw 17000
	wVar2   dw 9000

	; double words
	dVar1   dd 17000000
	dVar2   dd 9000000

	; quad words
	qVar1   dq 170000000
	qVar2   dq 90000000

section .bss
	bResult resb 1
	wResult resw 1
	dResult resd 1
	qResult resq 1

section .text
global _start

_start:
	lea rax, BYTE [bVar1]

	; bResult = bVar1 + bVar2
	mov al, BYTE [bVar1]
	add al, BYTE [bVar2]
	mov BYTE [bResult], al

	; wResult = wVar1 + wVar2
	mov ax, WORD [wVar1]
	add ax, WORD [wVar2]
	mov WORD [wResult], ax

	; dResult = dVar1 + dVar2
	mov eax, dVar1
	add eax, DWORD [dVar2]
	mov DWORD [dResult], eax

	; qResult = qVar1 + qVar2
	mov rax, QWORD [qVar1]
	add rax, QWORD [qVar2]
	mov QWORD [qResult], rax

	; exit(0);
	mov rax, SYS_exit
	mov rdi, EXIT_SUCCESS
	syscall
