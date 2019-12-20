global _start

;------- MACRO AREA -------

%macro display 2
	
	MOV RAX , 01
	MOV RDI , 01
	MOV RSI , %1
	MOV RDX , %2
	SYSCALL
	
%endmacro

;------- DATA SECTION -------

section .data

	wel db 10,"!! WELCOME TO FACTORIAL !!",10
	wellen equ $ - wel
	
	ty db 10,":::: THANK YOU :::: ",10
	tylen equ $ - ty
	
	fmsg db 10,"FACTORIAL :: "
	flen equ $ - fmsg
	
	
    
    errmsg db 10,"ERROR ! TOO FEW ARGUMENTS ...",10
    errlen equ $ - errmsg
    
;------- BSS SECTION -------

section .bss

	d16buff resq 1
	hexinbuff resb 1				; to store the ascii value of the input number 
	
;------- TEXT SECTION -------

section .txt

	_start:
		
		display wel,wellen
		
		;------- CHECK WHETHER NUMBER OF ARGUMENTS ARE VALID -------
		
		POP RCX						; dec argc
		CMP RCX , 01				; if argc is 1 then error is generated
		JE error
		
		POP RSI
		POP RSI
		
		CALL convert2
		
		XOR RAX , RAX
		XOR RBX , RBX
		XOR RCX , RCX
		
		MOV BL , [ hexinbuff ]
		MOV AL , 01
		CALL factorial
		
		MOV RBX , RAX
		display fmsg , flen
		CALL disp16
		JMP exit
		
	error:
		
		display errmsg, errlen
		
	exit:
		
		MOV RAX , 60
		MOV RDI , 00
		SYSCALL
		
;--------PROCEDURE AREA-------

;--------CONVERT 2 PROCEDURE ( TO CONVERT ASCII - HEX )-------

convert2:

	XOR RBX , RBX
	MOV RCX , 02
	
up:

	ROL BL , 4
	MOV AL , [RSI]
	SUB AL , 30h
	CMP AL , 09H
	JBE skip
	SUB AL , 07H

skip:

	ADD BL , AL
	INC RSI
	LOOP up
	
	MOV [hexinbuff] , BL
	RET
	

;------- DISP 16 FUNCTION -------

disp16:

	MOV RDI , d16buff
	MOV RCX , 16
	
d16up:

	ROL RBX , 4
	MOV AL , BL
	AND AL , 0FH
	ADD AL , 30H
	CMP AL , 39H
	JBE d16skip
	ADD AL , 07H
	
d16skip:
	
	MOV [RDI], AL 
	INC RDI
	LOOP d16up
	
	display d16buff , 16
	RET
	
;------- FACTORIAL PROCEDURE -------

factorial:

	PUSH RBX
	CMP RBX , 01
	JBE stackempty
	DEC RBX
	
	call factorial
	
stackempty:
	
	POP RBX 
	MUL RBX
	
	RET
	
