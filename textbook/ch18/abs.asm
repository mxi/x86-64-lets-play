%include "constants.asm"

%macro absf 1
	and DWORD [%1], 0x7fffffff
%endmacro

%macro absd 1
	and DWORD [%1+4], 0x7fffffff
%endmacro


section .rodata
	Zrof dd  0.0
	Negf dd -1.0

	Zrod dq  0.0
	Negd dq -1.0

section .data
	Numf0 dd -0.417425
	Numf1 dd  0.741303
	Numf2 dd  0.218798
	Numf3 dd -0.096345
	Numf4 dd -0.112993

	Numd0 dq -0.309781484341320
	Numd1 dq -0.311713116289328
	Numd2 dq -0.557200966505407
	Numd3 dq  0.752243806155183
	Numd4 dq -0.069248465625843

section .text
global _start
_start:
	; do stuff
	absf Numf0
	absf Numf1
	absf Numf2
	absf Numf3
	absf Numf4
	
	absd Numd0
	absd Numd1
	absd Numd2
	absd Numd3
	absd Numd4

;	absd QWORD [Numd0]
;	absd QWORD [Numd1]
;	absd QWORD [Numd2]
;	absd QWORD [Numd3]
;	absd QWORD [Numd4]

	; exit
	mov rdi, EXIT_success
	mov rax, SYS_exit
	syscall
