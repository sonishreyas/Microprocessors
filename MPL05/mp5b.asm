global _blank					; entry point of program

extern filelen , filebuff		; Variable of other procedure

;------- MACRO AREA -------

%macro display 2

	MOV RAX , 01
	MOV RDI , 01
	MOV RSI , %1
	MOV RDX , %2
	SYSCALL
	
%endmacro

%macro read 2

	MOV RAX , 00
	MOV RDI , 00
	MOV RSI , %1
	MOV RDX , %2
	SYSCALL
	
%endmacro

;------- DATA SECTION-------

section .data

	spmsg db 10,"Space Count     = "
	spmsglen equ $-spmsg
	
	chmsg db 10,"Character Count = "
	chmsglen equ $-chmsg
	
	nlmsg db 10,"New line Count  = "
	nlmsglen equ $-nlmsg
	
	inchmsg db 10,"ENTER CHARACTER TO BE SEARCHED = "
	inchmsglen equ $-inchmsg
	
;------- BSS SECTION-------

section .bss

	chbuff resb 2
	spcnt resb 1
	chcnt resb 1
	nlcnt resb 1
	d2buff resb 2
	
;------- TEXT SECTION -------

section .txt

	_blank:
	
		display inchmsg,inchmsglen
		read chbuff , 2
		
		MOV AL , 0			; COUNT to store spaces
		MOV DL , 0			; COUNT to store character
		MOV BL , 0			; COUNT to store new line
		
		MOV AH , 20H		;	ASCII value of space
		MOV BH , 0AH		;	ASCII value of newline (ENTER)
		MOV DH , [chbuff]	; 	input character 
		
		MOV RSI , filebuff
		MOV RCX , [filelen]
		
		_search:
			
			CMP [ RSI ], AH
			JNE case2
			INC AL
			JMP case4
			
		case2:
			
			CMP [RSI] , BH
			JNE case3
			INC BL
			JMP case4
			
		case3:
		
			CMP [RSI] , DH
			JNE case4
			INC DL
			JMP case4
			
		case4:
		
			INC RSI
			LOOP _search
			
		MOV [spcnt] , AL
		MOV [chcnt] , DL
		MOV [nlcnt] , BL
		
		display spmsg,spmsglen
		MOV BL , [spcnt]
		CALL disp2 
	
		display chmsg,chmsglen
		MOV BL , [chcnt]
		CALL disp2 
			
		display nlmsg,nlmsglen
		MOV BL , [nlcnt]
		CALL disp2 
		
		RET
		
disp2:

	MOV RDI , d2buff
	MOV RCX , 2
	
d2up:

	ROL BL , 4
	MOV AL , BL
	AND AL , 0FH
	ADD AL , 30H
	CMP AL , 39H
	JBE d2skip
	ADD AL , 07H

d2skip:

	MOV [RDI],AL
	INC RDI
	LOOP d2up
	
	display d2buff, 2
	RET

