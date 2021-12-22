section .data
	Src dd  816265645, 3159309234, 3590723297, 1638587572, 3065398782,
	    dd 1174749576,  755639290, 2864156751, 3847614174, 2482430180,
	    dd 1340293909,  552995746, 3897018743, 2362120600, 1553755880,
	    dd  272441568,  567537773, 1135592872, 2512039951, 2342167270,
	    dd 1954478166, 2885361028,   35066349,  462300226, 1374852696,
	    dd  382803696, 1220148658, 3370649039,  968190228, 2148827474,
	    dd  467764806, 1072783176, 3985537899, 3978429400, 3023801567,
	    dd 2856185204, 2733399236,  500260645,  371292627, 2827006044,
	    dd 2824659567, 3414921471, 1766199170, 1639865385, 3806734751,
	    dd 2499666314, 1296261118, 2476266015, 1716681025, 2097830662,
		dd          0,          2, 4294967295
	
	N   equ 53

section .bss
	Dst resd N

section .text
global _start

_start:
	; Algorithm:
	; 
	; for ebx = 0; ebx < 50; ++ebx
	;   r8d = Src[ebx]
	;   esi = 0; edi = r8d
	;   while edi-esi > 1
	;     r9d = (edi-esi)/2 + esi
	;     eax = r9d * r9d
	;     if eax > r8d
	;        edi = r9d
	;     elif eax < r8d
	;        esi = r9d
	;     elif eax == r8d
    ;        break
	;   Dst[ebx] = r9d
	mov ecx, N
	mov ebx, 0
arr_loop: ; for ebx = 0; ebx < 50; ++ebx
	mov r8d, DWORD [Src+ebx*4]
	mov esi, 0
	mov edi, r8d
bin_loop: ; while esi  <= edi
	; r9d = (edi-esi)/2 + esi
	mov r9d, edi ; ~ movxz r9, edi
	sub r9d, esi
	shr r9d, 1
	add r9d, esi

	; eax = r9d * r9d
	mov eax, r9d ; ~ movzx rax, r9d
	mul rax

	; if eax > r8d
	cmp rax, r8
	jbe c_elif_1
	mov edi, r9d
	jmp c_endif
c_elif_1:
	; elif eax < r8d
	cmp rax, r8
	jae c_elif_2
	mov esi, r9d
	jmp c_endif
c_elif_2:
	; elif eax == r8d
	; no comparison needed because eax must equal r8d
	jmp end_bin_loop
c_endif:
	mov eax, edi
	sub eax, esi
	cmp eax, 1
	ja bin_loop
end_bin_loop:
	mov DWORD [Dst+ebx*4], r9d
	inc ebx
	loop arr_loop

	; exit
	mov rax, 60
	mov rdi, 0
	syscall
