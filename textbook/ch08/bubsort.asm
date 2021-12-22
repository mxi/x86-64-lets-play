section .data
	Arr dd 9624, 3498, 9130, 8595, 9368,
	    dd 9621, 6309, 2771, 9366, 7771,
	    dd 6322, 8454, 8927, 9916, 6019,
	    dd 1293, 5901, 1123, 5864, 2813,
	    dd 6160, 7358, 4252, 5295, 8514,
	    dd 5945, 6466, 3650, 8907, 2069,
	    dd 9048, 1494, 5791, 4952, 7577,
	    dd 2172, 5933, 3118, 1327, 3448,
	    dd 3078, 6388, 9593, 2354, 7502,
	    dd 5395, 6201, 7066, 8905, 4931,

	Len dd 50

section .text
global _start

_start:
	; for (i = len-1; i > 0; --i)
	;   swapped = false
	;   for (j = 0; j < i; ++j)
	;     a = Arr[j]
	;     b = Arr[j+1]
	;     if a > b
	;       Arr[j] = b
	;       Arr[j+1] = a
	;       swapped = true
	;   if !swapped
	;     break

	mov ecx, DWORD [Len]
	dec ecx
i_loop:
	; swapped := r8b = 0
	mov r8b, 0
	mov ebx, 0

j_loop:
	; a = r9d, b = r10d
	mov r9d, DWORD [Arr+ebx*4]
	mov r10d, DWORD [Arr+ebx*4+4]

	; if a > b, swap
	cmp r9d, r10d
	jbe j_endif
	mov DWORD [Arr+ebx*4], r10d
	mov DWORD [Arr+ebx*4+4], r9d
	mov r8b, 1
	
j_endif:
	; if j < i, continue
	inc ebx
	cmp ebx, ecx
	jb j_loop

j_endloop:
	; if !swapped, break
	cmp r8b, 0
	je i_endloop

	; if i > 0, continue
	dec ecx
	jnz i_loop

i_endloop:
	; exit
	mov rax, 60
	mov rdi, 0
	syscall
