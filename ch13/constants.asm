section .rodata
	; characters
	LF           equ 0x0a

	; call codes
	SYS_read     equ 0
	SYS_write    equ 1
	SYS_exit     equ 60

	; sys params 
	SYS_stdin    equ 0
	SYS_stdout   equ 1
	SYS_stderr   equ 2

	EXIT_success equ 0
	EXIT_failure equ 1
