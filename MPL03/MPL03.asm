global _start

;-------MACRO AREA-------

%macro display 2
		MOV RAX,1
		MOV RDI,1
		MOV RSI,%1
		MOV RDX,%2
		SYSCALL
%endmacro

%macro read 2
		MOV RAX,0
		MOV RDI,0
		MOV RSI,%1
		MOV RDX,%2
		SYSCALL
%endmacro

;######## DATA SECTION ########

section .data
	
	welmsg db 10,"**********WELCOME TO CODE CONVERSION BY SHREYAS**********",10
	wmsglen equ $-welmsg
	
	thmsg db 10,"|_|_|_|_|_|THANK YOU TO VISIT BLOCK DATA TRANSFER BY SHREYAS|_|_|_|_|_|",10
	thsglen equ $-thmsg
	
	menumsg db 10,10,"##########<-- MENU -->##########"
			db 10,"1. HEX TO BCD."
			db 10,"2. BCD TO HEX."
			db 10,"3.EXIT."
			db 10,10,"Please enter your choice :: "
	menumsglen equ $-menumsg
	
	invalmsg db 10,"INVALID CHOICE",10
	invalmsglen equ $-invalmsg
	
	h2bmsg db 10,"WELCOME TO HEX TO BCD CODE CONVERSION ",10
	h2bmsglen equ $-h2bmsg
	
	b2hmsg db 10,"WELCOME TO BCD TO HEX CODE CONVERSION ",10
	b2hmsglen equ $-b2hmsg
	
	hinmsg db 10,"PLEASE ENTER A 4 DIGIT HEX NUMBER (IN CAPITAL) ::  "
	hinmsglen equ $-hinmsg
	
	boutmsg db 10,"EQUIVALENT BCD ::  "
	boutmsglen equ $-boutmsg
	
	binmsg db 10,"PLEASE ENTER A 5 DIGIT BCD NUMBER  ::  "
	binmsglen equ $-binmsg
	
	houtmsg db 10,"EQUIVALENT HEX ::  "
	houtmsglen equ $-houtmsg
	
;########## BSS SECTION #########
	
section .bss

	chbuff resb 2
	hexinbuff resb 5
	boutcnt resb 1
	boutbuff resb 5
	binbuff resb 6
	d8buff resb 8
		
;######## TEXT SECTION#########
	
section .text

_start:

	display welmsg,wmsglen

menu:

	display menumsg,menumsglen
	
	read chbuff,2							;Accept choice
	
	MOV AL,[chbuff]
	CMP AL,'1'
	JNE case2
	CALL h2b
	JMP menu
	
case2:  CMP AL,'2'
	   	JNE case3
		CALL b2h
		JMP menu	
	
case3:	CMP AL,'3'
		JE exit
		
		display invalmsg,invalmsglen
		JMP menu
		
exit:	
	
	
	display thmsg,thsglen
	MOV RAX,60
	MOV RDI,0
	SYSCALL

; ########## PROEDURES #########

; ########## PROCEDURE INVOLVING CONVERSION OF HEX TO BCD #############	

h2b:
	
	display h2bmsg,h2bmsglen
	display hinmsg,hinmsglen	
	
	read hexinbuff,5
	CALL convert4
	
	MOV AX,BX				;Moving accepted number
	MOV BX,0ah				;divisor
	MOV byte [boutcnt],0
	
h2up1:

	MOV DX,0				;DX:AX/BX = Q->AX R->DX
	DIV BX 
	PUSH RDX
	INC byte [boutcnt]
	CMP AX,0
	JNE h2up1
	
	MOV RDI,boutbuff		;initialize pointer to rdi
	XOR RCX,RCX
	MOV CL,[boutcnt]
	
h2up2:
	POP RDX
	ADD DL,30H				;calculate ASCII EQUIVALENT
	MOV [RDI],DL
	INC RDI
	LOOP h2up2
	
	display boutmsg,boutmsglen
	
	XOR RCX,RCX	
	MOV CL,[boutcnt]
	
	display boutbuff,RCX
	
	RET

; ########## PROCEDURE INVOLVING CONVERSION OF BCD TO HEX #############

b2h:

	display b2hmsg,b2hmsglen
	display binmsg,binmsglen
	
	read binbuff,6
	
	MOV RCX,5
	MOV RSI,binbuff
	XOR EAX,EAX
	MOV EBX,10
	
b2up1:
	MUL EBX
	MOV DL,[RSI]
	SUB DL,30H
	ADD EAX,EDX
	
	INC RSI
	LOOP b2up1
	
	MOV EBX,EAX
	
	display houtmsg,houtmsglen
	CALL disp8
			
	RET

; ########## CONVERSION PROCEDURE #############

convert4:

		MOV BX,0
		MOV RSI,hexinbuff
		MOV RCX,4
		
c4up:	
	
		ROL BX,4
		MOV AL,[RSI]
		SUB AL,30H
		CMP AL,9
		JBE c4skip	
		SUB AL,7
		
c4skip:

		ADD BL,AL
		INC RSI
		LOOP c4up
		
	RET			;return bx
	
	
disp8:

	MOV RDI,d8buff
	MOV RCX,8

d2up:
	
	ROL EBX,4
	MOV AL,BL
	AND AL,0fh	
	ADD AL,30h
	CMP AL,39h
	JBE d2skip
	ADD AL,07h
	
d2skip:

	MOV [RDI],AL
	INC RDI
	LOOP d2up
	
	display d8buff,8
	RET
