%include "constants.asm"
%include "strlend_only.asm"
%include "stoid_only.asm"
%include "bubsort_only.asm"
%include "stats_only.asm"
%include "itosd_only.asm"


section .data
;	Csv db " 188165028,-183071056,-141334040, -80646268,-135799982,"
;	    db "   2448913,-253985651, -12149829, 258563239,-147853288,"
;	    db " 245586288, -75674365, -44321865, 247780158,  11200664,"
;	    db "-117326699,-152886118,  86219465, 228898795, 142878994,"
;	    db " -76918841, -34805340,  42011204, 189384128,-123046037,"
;	    db " 239256533, -42120780, -88605672,  89333207, 130501453,"
;	    db " 235395866, 175387942, 166034012,-107195113, 264519584,"
;	    db "  26188742, -91704500,-150338023, -22103544, 112077706,"
;	    db "  14150300,  16814937,  69062451, 106129754, 114943936,"
;	    db " 175322954,-265604604,-186315983,  93835021,-245599920", 0

	Csv dd "-67,-48, 57, -1,"
	    dd "-75,-40,-93,100,"
	    dd " 36, 51,-66,-81,"
	    dd "-21, 81, 15,-41,"
	    dd "-78,-68,-57, 22", 0
	
	Del equ ","
	
section .bss
	Min  resq 1
	Med1 resq 1
	Med2 resq 1
	Max  resq 1
	Sum  resq 1
	Avg  resq 1
	Var  resq 1
	Stdv resq 1

section .text
global ovstat
ovstat:
	; Overloaded stat function. Takes a null terminated string of comma
	; delimited, base 10, 64-bit, signed integers; parses them; sorts
	; them; computes statistics with the regular stats function; and
	; writes out the sorted array back to the string.
	;
	; No validation will be performed because too many pointers—I'll
	; let it be for this challenge.
	;
	; PARAM
	;     rdi = data str (char*)
	;     rsi = min ptr (int64*)
	;     rdx = med1 ptr (int64*)
	;     rcx = med2 ptr (int64*)
	;     r8  = max ptr (int64*)
	;     r9  = sum ptr (int64*)
	;     rbp+16 = avg ptr (int64*)
	;     rbp+24 = var ptr (int64*)
	;     rbp+32 = stdev ptr (int64*)
	; RETURN
	;     rax = no. numbers parsed (-1 on error)

	; the quadword array size for parsed data
	ovstat_Narrsz equ 1024 * 8 
	; total local variables size on stack
	ovstat_Nlocsz equ   10 * 8

	; local: quadword buffer to store parsed numbers
%define ovstat_Lqbuf    QWORD [rbp-ovstat_Narrsz-( 0*8)]
	; local: delimiter pointer for string operations
%define ovstat_Ldelptr  QWORD [rbp-ovstat_Narrsz-( 1*8)]
	; local: number of numbers parsed
%define ovstat_Lnitems  QWORD [rbp-ovstat_Narrsz-( 2*8)]
	; local: parameter saves
%define ovstat_Ldatastr QWORD [rbp-ovstat_Narrsz-( 3*8)]
%define ovstat_Lminptr  QWORD [rbp-ovstat_Narrsz-( 4*8)]
%define ovstat_Lmed1ptr QWORD [rbp-ovstat_Narrsz-( 5*8)]
%define ovstat_Lmed2ptr QWORD [rbp-ovstat_Narrsz-( 6*8)]
%define ovstat_Lmaxptr  QWORD [rbp-ovstat_Narrsz-( 7*8)]
%define ovstat_Lsumptr  QWORD [rbp-ovstat_Narrsz-( 8*8)]
%define ovstat_Lavgptr  QWORD [rbp-ovstat_Narrsz-( 9*8)]
%define ovstat_Lvarptr  QWORD [rbp-ovstat_Narrsz-(10*8)]
%define ovstat_Lstdvptr QWORD [rbp-ovstat_Narrsz-(11*8)]

	push rbp
	mov rbp, rsp
	sub rsp, ovstat_Narrsz + ovstat_Nlocsz
	push rbx
	push r12
	push r13

	; save parameters to local vars
	mov ovstat_Ldatastr, rdi
	mov ovstat_Lminptr, rsi
	mov ovstat_Lmed1ptr, rdx
	mov ovstat_Lmed2ptr, rcx
	mov ovstat_Lmaxptr, r8
	mov ovstat_Lsumptr, r9

	mov rax, QWORD [rbp+16]
	mov ovstat_Lavgptr, rax
	mov rax, QWORD [rbp+24]
	mov ovstat_Lvarptr, rax
	mov rax, QWORD [rbp+32]
	mov ovstat_Lstdvptr, rax

	; parse loop
	mov r12, ovstat_Ldatastr ; str iterator
	lea r13, ovstat_Lqbuf ; quadbuffer iterator
ovstat_parse_loop:
	cmp r13, rbp
	je ovstat_parse_loop_done

	; get delimited strlen for number field
	mov  cl, Del
	mov rdx, 128 ; just a length strlend can reference, not too important
	mov rsi, r12
	lea rdi, ovstat_Ldelptr
	call strlend
	cmp rax, 0 ; if strlend returns 0, it failed
	jz ovstat_err

	; parse the delimited string region
	mov rbx, ovstat_Ldelptr
	mov  cl, BYTE [rbx]
	mov rdx, rax
	mov rsi, r12
	mov rdi, r13
	call stoid
	cmp rax, 0 ; if stoid returns 0, it failed
	jz ovstat_err
	mov r12, rax ; delimiter after the parsed integer

	; check if we're at then of the data string, otherwise increment 
	; past.
	cmp BYTE [r12], 0
	jz ovstat_parse_loop_done
	inc r12
	add r13, 8
	jmp ovstat_parse_loop
ovstat_parse_loop_done:
	; calculate the # of numbers parsed
	lea rbx, ovstat_Lqbuf
	sub r13, rbx
	shr r13, 3 ; div 8
	mov ovstat_Lnitems, r13

	; sort the array
	mov rsi, ovstat_Lnitems
	lea rdi, ovstat_Lqbuf
	call bubsort
	cmp rax, 0 ; bubsort returns 0 on error
	jz ovstat_err

	; finally get the statistics we're after
	push ovstat_Lstdvptr
	push ovstat_Lvarptr
	push ovstat_Lavgptr
	push ovstat_Lsumptr
	mov r9, ovstat_Lmaxptr
	mov r8, ovstat_Lmed2ptr
	mov rcx, ovstat_Lmed1ptr
	mov rdx, ovstat_Lminptr
	mov rsi, ovstat_Lnitems
	lea rdi, ovstat_Lqbuf
	call stats
	cmp rax, 0 ; stats returns 0 on failure
	jz ovstat_err

	; override string with the sorted version
	mov rbx, ovstat_Ldatastr
	lea r12, ovstat_Lqbuf
	mov r13, ovstat_Lnitems
ovstat_marshal_loop:
	cmp r13, 0
	je ovstat_end
	cmp r13, 1
	je ovstat_marshal_last_elem
	mov  cl, Del
	jmp ovstat_marshal_just_write_the_thing
ovstat_marshal_last_elem:
	mov  cl, 0
ovstat_marshal_just_write_the_thing:
	mov rdx, 128 ; again, we know the buffer is large enough
	mov rsi, rbx
	mov rdi, QWORD [r12]
	call itosd
	cmp rax, 0
	jz ovstat_err
	mov rbx, rax
	inc rbx ; skip previously written delimiter; prepare for next item
	add r12, 8
	dec r13
	jmp ovstat_marshal_loop
ovstat_err:
	mov rax, -1
ovstat_end:
	pop r13
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp
ret

global _start
_start:
	; do the stuff 
	push Stdv
	push Var
	push Avg
	mov r9, Sum
	mov r8, Max
	mov rcx, Med2
	mov rdx, Med1
	mov rsi, Min
	mov rdi, Csv
	call ovstat

	; exit
	mov rax, SYS_exit
	mov rdi, EXIT_success
	syscall
