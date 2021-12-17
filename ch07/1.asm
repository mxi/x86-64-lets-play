section .data
	bNum1 db 7
	bNum2 db 11
	bNum3 db 13
	bNum4 db 17

section .bss
	; addition
	bAns1  resb 1
	bAns2  resb 1
	bAns3  resb 1
	; subtraction
	bAns6  resb 1
	bAns7  resb 1
	bAns8  resb 1
	; multiplication
	wAns11 resw 1
	wAns12 resw 1
	wAns13 resw 1
	; division
	bAns16 resb 1
	bAns17 resb 1
	bAns18 resb 1
	; mod
	bRem18 resb 1
	
section .text
global _start

_start:
	; unsigned byte expressions:
	; bAns1  = bNum1 + bNum2 = 18
	mov al, BYTE [bNum1]
	add al, BYTE [bNum2]
	mov BYTE [bAns1], al

	; bAns2  = bNum1 + bNum3 = 20
	mov al, BYTE [bNum1]
	add al, BYTE [bNum3]
	mov BYTE [bAns2], al

	; bAns3  = bNum3 + bNum4 = 30
	mov al, BYTE [bNum3]
	add al, BYTE [bNum4]
	mov BYTE [bAns3], al

	; bAns6  = bNum1 - bNum2 = -4
	mov al, BYTE [bNum1]
	sub al, BYTE [bNum2]
	mov BYTE [bAns6], al

	; bAns7  = bNum1 - bNum3 = -6
	mov al, BYTE [bNum1]
	sub al, BYTE [bNum3]
	mov BYTE [bAns7], al

	; bAns8  = bNum2 - bNum4 = -6
	mov al, BYTE [bNum2]
	sub al, BYTE [bNum4]
	mov BYTE [bAns8], al

	; wAns11 = bNum1 * bNum3 = 91
	mov al, BYTE [bNum1]
	mul BYTE [bNum3]
	mov WORD [wAns11], ax

	; wAns12 = bNum2 * bNum2 = 121
	mov al, BYTE [bNum2]
	mul al
	mov WORD [wAns12], ax

	; wAns13 = bNum2 * bNum4 = 187
	mov al, BYTE [bNum2]
	mul BYTE [bNum4]
	mov WORD [wAns13], ax

	; bAns16 = bNum2 / bNum1 = 1
	mov al, BYTE [bNum2]
	cbw
	div BYTE [bNum1]
	mov BYTE [bAns16], al

	; bAns17 = bNum4 / bNum3 = 1
	mov al, BYTE [bNum4]
	cbw
	div BYTE [bNum3]
	mov BYTE [bAns17], al

	; bAns18 = bNum4 / bNum1 = 2
	mov al, BYTE [bNum4]
	cbw
	div BYTE [bNum1]
	mov BYTE [bAns18], al

	; bRem18 = bNum4 % bNum1 = 3
	mov BYTE [bRem18], ah

	; exit
	mov rax, 60
	mov rdi, 0
	syscall

