global _start

;-------MACRO AREA-------

;-------DISPLAY MACRO-------

%macro display 2

	MOV RAX , 01
	MOV RDI , 01
	MOV RSI , %1
	MOV RDX , %2
	SYSCALL

%endmacro

;-------READ MACRO-------

%macro read 2

	MOV RAX , 00
	MOV RDI , 00
	MOV RSI , %1
	MOV RDX , %2
	SYSCALL
	
%endmacro

;-------DATA SECTION-------

section .data

	welmsg db 10,"WELCOME TO CODE OF MULTIPLICATION OF HEX NUMBERS",10
	wellen equ $-welmsg
	
	tymsg db 10,"-------THANK YOU-------",10
	tylen equ $-tymsg
	
	multimsg db 10," ENTER A MULTIPLIER : "
	multilen equ $-multimsg
	
	mlpmsg db 10,"ENTER A MULTIPLICAND ( 2-digit HEX num) : "
	mlplen equ $-mlpmsg
	
	samsg db 10,": MULTIPLICATION USING SUCCESSIVE ADDITION : ",10
	salen equ $-samsg
	
	asmsg db 10,": MULTIPLICATION USING ADD AND SHIFT : ",10
	aslen equ $-asmsg
	
	resmsg db 10,"MULTIPLICATION = "
	reslen equ $-resmsg
	
	menumsg db 10,"         MENU          "
			db 10,"1. SUCCESSIVE ADDITION."
			db 10,"2. ADD - SHIFT METHOD. "
			db 10,"3. EXIT.",10
			db 10,"ENTER YOUR CHOICE : "
	menulen equ $-menumsg
	
	invalmsg db 10,"....INVALID CHOICE....",10
	invallen equ $-invalmsg
	
;------- BSS SECTION-------

section .bss

	chbuff 	resb 2				; to accept choice from the user 
	d4buff 	resb 4				; for disp4 procedure 
	d8buff 	resb 8				; for disp8 procedure
	num		resb 3				; to accept a two digit number from the user
	num1 	resb 1				; to store multiplier
	num2 	resb 2				; to store multplicand
	
;------- TEXT SECTION -------

section .txt

	_start:
		
		display welmsg,wellen
		
	menu:
		
		display menumsg,menulen
		read chbuff,2
		
		MOV AL , [chbuff]		; move the accepted choice to AL register to know which case to execute
		CMP AL , '1'			; compare AL to case 1 
		JNE case2				; if does not match to 1 jump to case 2
		CALL sap				; CALL successive addition procedure if matches
		loop menu
		
	case2:	
	
		CMP AL , '2'			; compare AL to case 2 
		JNE case3				; if does not match to 2 jump to case 3
		CALL aspro				; CALL ADD AND SHIFT procedure if matches
		loop menu
		
	case3:
	
		CMP AL , '3'			; compare AL to case 3
		JE exit					; if condition stands true then exit else display invalid message
		
		display invalmsg,invallen
		loop menu
		
	exit:
		
		display tymsg,tylen
		MOV RAX , 60
		MOV RDI , 0
		SYSCALL 

;-------PROCEDURE AREA-------

;-------SUCCESSIVE ADDITION PROCEDURE-------

sap:

	display samsg,salen			
	CALL accept					; CALL ACCEPT TO ACCEPT MULTIPLIEER AND MULTIPLICAND
	
	XOR AX , AX					; AX = 0
	XOR DX , DX					; DX = 0
	XOR RCX , RCX				; RCX = 0
	MOV CL , [num1]				; MOVE MULTIPLIER TO CL
	MOV DL , [num2]				; MOVE MULTIPLICAND TO DL
	JRCXZ skipsap				; JUMP IF RCX = 0

upsap:

	ADD AX , DX					; ADD DX TO AX UNTIL RCX BECOME 0 , i.e., num1 times
	loop upsap
	
skipsap:

	MOV BX , AX					; MOVE AX TO BX and CALL disp4 procedure to convert it to hex number
	display resmsg,reslen
	CALL disp4 					; call to disp4
	RET
	
;-------ADD AND SHIFT PROCEDURE-------

aspro:

	display asmsg,aslen
	CALL accept
		
	XOR RAX , RAX
	XOR RBX , RBX
	XOR RCX , RCX
	XOR RDX , RDX
	
	MOV AH , 00H
	MOV CL , 08
	MOV AL , [num1]
	MOV BL , [num2]
	CLC
	
upasp:
	
	BT AX , 00
	JNC shift
	ADD AH , BL

shift:

	RCR AX, 1
	loop upasp
	
	MOV BX , AX
	display resmsg,reslen
	CALL disp4
	RET
	
;------- ACCEPT PROCEDURE -------

accept:

	display multimsg,multilen
	read num,3					; read multiplier
	CALL convert2				; call convert2 which convert the hex input to ascii value 
	MOV [num1] , BL				; mov the converted multiplier to num1 
	
	display mlpmsg,mlplen
	read num,3					; read multiplicand
	CALL convert2				; call convert2 which convert the hex input to ascii value 
	MOV [num2] , BL				; mov the converted multiplicand to num2 
	
	RET 

	
;------- CONVERT PROCEDURE ( TO CONVERT ASCII VALUE TO HEX VALUE )-------

convert2:

	MOV RSI , num			; RSI points to num
	XOR BL , BL				; BL = 0
	MOV RCX , 2				; counter RCX = 2 as a 2 digit number
	
up1:

	ROL BL , 4				; ROTATE BL 
	MOV AL , [RSI]			; MOV first byte in AL
	SUB AL , 30H			
	CMP AL , 9H
	JE skip1
	SUB AL , 07H
	
skip1:
	
	ADD BL , AL				;ADD AL to BL to get the correct o/p
	INC RSI					; iNC RSi to point to next bit
	LOOP up1
	
	RET
	
;------- DISPLAY PROCEDURES ( TO CONVERT HEX VALUE TO ASCII VALUE AND DISPLAY IT )-------

;------- DISP4 PROCEDURE( USE BX REGISTER )-------

disp4:

	MOV RDI , d4buff
	MOV RCX , 4
	
d4up:

	ROL BX , 04					; ROTATE NUMBERS OF BX REGISTER
	MOV AL , BL					; MOVE 1ST BYTE TO AL
	AND AL , 0FH			
	ADD AL , 30H
	CMP AL , 39H
	JBE skip2
	ADD AL , 07H
	
skip2:
	
	MOV [RDI] , AL
	INC RDI
	LOOP d4up
	 
 	display d4buff , 4
	RET	 

;------- DISP8 PROCEDURE ( USE EBX REGISTER)------

disp8:

	MOV RDI , d8buff
	MOV RCX , 8
	
d8up:

	ROL EBX , 4
	MOV AL , BL
	ADD AL , 30H
	CMP AL , 09H
	JE d8skip
	ADD AL , 07H
	
d8skip:

	MOV [RDI] , AL
	INC RDI
	LOOP d8up
	
	display d8buff,8
	RET 	

