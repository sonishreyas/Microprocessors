global _start			; entry point of program

;------- MACRO AREA -------

%macro scall 4

	mov rax , %1		
	mov rdi , %2
	mov rsi , %3
	mov rdx , %4
	syscall

%endmacro

;------- DATA SECTION -------

section .data
	
	welmsg db 10,"|+|+|+| WELCOME TO DOS COMMAND CODE |+|+|+|",10
	wellen equ $ - welmsg
		
	tymsg db 10,"|+|+|+| THANK YOU !! |+|+|+|",10
	tylen equ $ - tymsg
	
	menumsg db 10,"     DOS COMMANDS     ",10
			db 10,"1. TYPE. "
			db 10,"2. TO DELETE."
			db 10,"3. TO COPY. "
			db 10,"4. EXIT. "
			db 10,10,"ENTER YOUR CHOICE = "
	menulen equ $ - menumsg
	
	fmsg db 10,"FILE OPENED SUCCESSFULLY...",10
	flen equ $ - fmsg
	
	errmsg db 10,"ERROR ! OPENING A FILE...",10
	errlen equ $ - errmsg
	
	wrierrmsg db 10,"ERROR ! WRITING IN A FILE...",10
	wrierrlen equ $ - wrierrmsg
	
	erargmsg db 10,"ERROR ! NUMBER OF ARGUMENTS ARE LESS ...",10
	erarglen equ $ - erargmsg
	
	invalmsg db 10,"INVALID CHOICE...",10
	invallen equ $ - invalmsg
	
	derrmsg db 10,"ERROR ! IN DELETION OF FILE",10
	derrlen equ $ - derrmsg
	
	delmsg db 10,"FILE HAS BEEN DELETED",10
	dellen equ $ - delmsg
	
	fcopymsg db 10 , "-----copying in 2nd file -------",10
	fcopylen equ $-fcopymsg
	
	fwritemsg db 10 , "------writing in file------",10
	fwritelen equ $-fwritemsg
	
;------- BSS SECTION -------

section .bss

	chbuff resb 2		;	choice buffer to input menu choice
	
	;------- VARIABLES FOR FILE2 -------
	
	f1buff	resb	500
	f1len	resq	1
	f1name	resq	1
	f1desc	resq	1	 
	
	;------- VARIABLES FOR FILE2 -------
	
	f2buff	resb	500
	f2len	resq	1
	f2name	resq	1
	f2desc	resq	1
	
;------- TEXT SECTION -------

section .txt

	_start:
		
		scall 01 , 01 , welmsg,wellen
		
		;------- CHECK IF ARGUMENTS PROVIDED ARE VALID -------
		
		pop rcx
		cmp rcx , 3
		jl error
		
		pop rsi					; to pop 1st argument
		
		pop rsi					; to pop 1st file name
		mov [f1name] , rsi		; load 1st file name in f1name buffer
		
		pop rsi					; to pop 2nd file name
		mov [f2name] , rsi		; load 2nd file name in f2name buffer
	
	menu:
		
		scall 01 , 01 , menumsg , menulen
		scall 00 , 00 , chbuff , 2
		
		mov al , [chbuff]
		cmp al , '1'
		jne case2
		call typefun
		call openf2
		jmp menu
		
	case2: 
		
		cmp al , '2'
		jne case3
		call delfun
		jmp menu
		
	case3: 
		
		cmp al , '3'
		jne case4
		call cpyfun
		jmp menu
		
	case4: 
		
		cmp al , '4'
		je exit
		
		scall 01 , 01 , invalmsg,invallen
		jmp menu
		
	error:
		
		scall 01 , 01 , erargmsg , erarglen
		jmp exit
	
	exit:
	
		scall 01 , 01 , tymsg,tylen
		mov rax , 60
		mov rdi , 00
		syscall
		 
;------- PROCEDURE AREA -------

;------- TYPE PROCEDURE -------

typefun:

	mov rax , 02 
	mov rdi , [f1name]
	mov rsi , 00
	syscall
	
	cmp rax , 00
	jl erfile
	
	mov [f1desc] , rax
	scall 01,01,fmsg,flen
	
	;------- READ THE FILE -------
	
	scall 00,[f1desc],f1buff,500
	
	mov [f1len] , rax				; moving actual length in f1len buffer
	scall 01 , 01 ,f1buff,[f1len]		; display contents of file
	
	;------- CLOSING THE FILE -------
	
	mov rax , 03
	mov rdi , [f1desc]
	syscall 
	ret
	
erfile:
	
	scall 01,01,errmsg,errlen
	jmp exit

openf2:
	
	mov rax , 02 
	mov rdi , [f2name]
	mov rsi , 02
	syscall	
	
	cmp rax , 00
	jl erfile1
	
	mov [f2desc] , rax
	scall 01,01,fmsg,flen
	
	;------- READ THE FILE -------
	
	scall 00,[f2desc],f2buff,500
	
	mov [f2len] , rax				; moving actual length in f1len buffer
	
	scall 01 , 01 ,f2buff,[f2len]		; display contents of file
	
	;------- CLOSING THE FILE -------
	
	mov rax , 03
	mov rdi , [f2desc]
	syscall 
	ret
erfile1:
	
	scall 01,01,errmsg,errlen
	
	ret
	
;------- DELETE PROCEDURE -------

delfun:

	mov rax , 87					; KERNEL CALL FOR delete operation
	mov rdi , [f2name]
	syscall
	
	cmp rax , 00
	jl derror
	
	scall 01,01,delmsg,dellen
	ret
	
	derror:
	
		scall 01,01,derrmsg,derrlen
		jmp exit

;------- COPY PROCEDURE -------

cpyfun:

	call typefun
	
	mov rax , 02
	mov rdi , [f2name]
	mov rsi , 02
	syscall
	
	cmp rax , 00
	JL erropen
	
	mov [f2desc] , rax
	
	mov rax , 01
	mov rdi , [f2desc]
	mov rsi , f1buff
	mov rcx , [f1len]
	syscall
	
	cmp rax , 00
	jl wrierr
	
	mov [f2len] , rax
	
	scall 01,01, f1buff , [f2len]
	
	mov rax ,03
	mov rdi , [f2desc]
	syscall
	
	ret
	
	erropen:
	
		scall 01,01,errmsg,errlen
		jmp exit	
	
	wrierr:
	
		scall 01,01,wrierrmsg,wrierrlen
		jmp exit	
	
		
	
	
