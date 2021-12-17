%macro liststats 6 
	; %1=len ptr, 
	; %2=arr ptr, 
	; %3=tot ptr, 
	; %4=min ptr, 
	; %5=max ptr, 
	; %6=avg ptr
	mov rsi, %2
	mov ecx, DWORD [%1] ; ~movzx rcx, DWORD [Len]
	cmp ecx, 0
	jne %%stat_prep 
	jmp %%stat_end ; if no elements, don't do anything
%%stat_prep:
	mov edi, DWORD [rsi]
	mov DWORD [%4], edi
	mov DWORD [%5], edi
%%stat_loop:
	mov edi, DWORD [rsi]
	add DWORD [%3], edi
%%check_min:
	cmp DWORD [%4], edi
	jle %%check_max
	mov DWORD [%4], edi
%%check_max:
	cmp DWORD [%5], edi
	jge %%check_end
	mov DWORD [%5], edi
%%check_end:
	add rsi, 4
	loop %%stat_loop
	; compute avg
	mov ebx, DWORD [%1]
	mov eax, DWORD [%3] ; ~ movzx rax, DWORD [Tot]
	cdq
	idiv ebx
	mov DWORD [%6], eax
%%stat_end:
%endmacro


section .data
	Arr0  dd 0
	Len0  dd 0

	Arr1  dd 9508, -4025, 7496, 5856, -8070
	Len1  dd 5

	Arr2  dd 3677, -5354, 9848, 486, -9963 
	Len2  dd 5

	Arr3  dd -1072, 6200, 2381, -4375, 6344, -1700, -5925, 127, -2190
	Len3  dd 9

section .bss
	Tot0 resd 1
	Min0 resd 1
	Max0 resd 1
	Avg0 resd 1

	Tot1 resd 1
	Min1 resd 1
	Max1 resd 1
	Avg1 resd 1

	Tot2 resd 1
	Min2 resd 1
	Max2 resd 1
	Avg2 resd 1

	Tot3 resd 1
	Min3 resd 1
	Max3 resd 1
	Avg3 resd 1

section .text
global _start

_start:
	liststats Len0, Arr0, Tot0, Min0, Max0, Avg0
	liststats Len1, Arr1, Tot1, Min1, Max1, Avg1
	liststats Len2, Arr2, Tot2, Min2, Max2, Avg2
	liststats Len3, Arr3, Tot3, Min3, Max3, Avg3

	; exit
	mov rax, 60
	mov rdi, 0
	syscall
