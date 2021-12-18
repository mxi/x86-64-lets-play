section .rodata
	; characters
	LF           equ 0x0a

	; call codes
	SYS_read     equ 0
	SYS_write    equ 1
	SYS_open     equ 2
	SYS_close    equ 3
	SYS_exit     equ 60

	; std fds
	SYS_stdin    equ 0
	SYS_stdout   equ 1
	SYS_stderr   equ 2

	; open/(u/g/o)id params
	O_ACCMODE	 equ 00000003q
	O_RDONLY	 equ 00000000q
	O_WRONLY	 equ 00000001q
	O_RDWR		 equ 00000002q
	O_CREAT		 equ 00000100q
	O_EXCL		 equ 00000200q
	O_NOCTTY	 equ 00000400q
	O_TRUNC		 equ 00001000q
	O_APPEND	 equ 00002000q
	O_NONBLOCK	 equ 00004000q
	O_DSYNC		 equ 00010000q
	FASYNC		 equ 00020000q
	O_DIRECT	 equ 00040000q
	O_LARGEFILE	 equ 00100000q
	O_DIRECTORY	 equ 00200000q
	O_NOFOLLOW	 equ 00400000q
	O_NOATIME	 equ 01000000q
	O_CLOEXEC	 equ 02000000q

	S_IRWXU      equ 00700q
	S_IRUSR      equ 00400q
	S_IWUSR      equ 00200q
	S_IXUSR      equ 00100q

	S_IRWXG      equ 00070q
	S_IRGRP      equ 00040q
	S_IWGRP      equ 00020q
	S_IXGRP      equ 00010q

	S_IRWXO      equ 00007q
	S_IROTH      equ 00004q
	S_IWOTH      equ 00002q
	S_IXOTH      equ 00001q

	; exit params
	EXIT_success equ 0
	EXIT_failure equ 1
