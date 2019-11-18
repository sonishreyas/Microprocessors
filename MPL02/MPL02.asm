global _start

;-------MACRO AREA-------;

%macro display 2
	
	mov rax , 01	;write() function code
	mov rdi , 01	;File Descriptor 
	mov rsi , %1	;Buffer Address
	mov rdx , %2	;Length/Count
	syscall			;LINUX KERNEL call
	
%endmacro

%macro read 2

	mov rax , 00
	mov rdi , 00
	mov rsi , %1
	mov rdx , %2
	syscall
	
%endmacro

;-------DATA SECTION-------;

section .data

	wcmsg db 10,"WELCOME TO THE CODE",10
	wcmsglen equ $-wcmsg
	
	beforeblock db 10,"BLOCK CONTENTS BEFORE TRANSFER",10
	bmsglen equ $-beforeblock
	
	srcmsg db 10,"SOURCE BLOCK 		:: "
	smsglen equ $-srcmsg
	
	dstmsg db 10,"DESTINATION BLOCK :: "
	dglen equ $-dstmsg
	
	afterblock db 10,"BLOCK CONTENTS AFTER TRANSFER",10
	amsglen equ $-afterblock
	
	menumsg db 10,"**************MENU*****************"
			db 10,"1. NON-OVERLAPPED WITHOUT STRING."
			db 10,"2. NON-OVERLAPPED WITH STRING."
			db 10,"3. OVERLAPPED WITHOUT STRING."
			db 10,"4. OVERLAPPED WITH STRING."
			db 10,"5. EXIT."
			db 10,10,"Please enter your choice :: "
	menumsglen equ $-menumsg
	 
	 
	invalmsg db 10,"INVALID CHOICE",10
	invalmsglen equ $-invalmsg
 
	space db 20h
	
	srcblk db 45h,0adh,3fh,29h,0e9h
	dstblk db 0,0,0,0,0 
	blkcnt equ 5 
	
	tymsg db 10,"THANK YOU",10
	tymsglen equ $-tymsg
	
;-------BSS SECTION-------;

section .bss

	;UNDEFINED VARIABLES
	d2buff resb 2
	chbuff resb 2
	
;-------TEXT SECTION-------;

section .text

	_start:
	
		display wcmsg,wcmsglen
		
		;-------BEFORE BLOCK TRANSFER-------
		
		display beforeblock,bmsglen
		
		;-------SOURCE BLOCK CONTENT BEFORE TRANSFER-------
		
		display srcmsg,smsglen
		MOV RSI,srcblk	
		MOV RCX,blkcnt
		call write  
		
		;-------DESTINATION BLOCK CONTENT BEFORE TRANSFER-------
		
		display dstmsg,dglen	
		MOV RSI,dstblk	
		MOV RCX,blkcnt
		call write  
		
menu: 
		display menumsg,menumsglen
		read chbuff,2

		mov al,[chbuff]

		;-------NON-OVERLAPPED WITHOUT STRING BLOCK TRANSFER
		
		cmp al,'1'
		JNE case2	
		call wos_non
		
		;-------NON-OVERLAPPED WITH STRING BLOCK TRANSFER
		
case2:	cmp al,'2'
		JNE case3
		call ws_non
		;JMP menu
		
		;-------OVERLAPPED WITHOUT STRING BLOCK TRANSFER

case3:	cmp al,'3'
		JNE case4
		call wos_o

		;-------OVERLAPPED WITH STRING BLOCK TRANSFER

case4:	cmp al,'4'
		JNE case5 
		call ws_o

		;-------if no cases matches exit-------
		
case5: 	cmp al,'5'
		JE exit
		
		;display invalmsg,invalmsglen
		
		;-------AFTER BLOCK TRANFER-------
		
		display afterblock,amsglen
		
		;-------SOURCE BLOCK CONTENT AFTER TRANSFER-------
			
		display srcmsg,smsglen
		MOV RSI,srcblk	
		MOV RCX,blkcnt
		call write 
	
		;-------DESTINATION BLOCK CONTENT AFTER TRANSFER-------
			
		display dstmsg,dglen	
		MOV RSI,dstblk	
		MOV RCX,blkcnt
		call write 
		
		JMP menu
		;-------EXIT-------

exit:

		display tymsg,tymsglen
		mov rax , 60
		mov rdi , 0
		syscall

;-------PROCEDURES AREA-------

;-------PROCEDURE NON-OVERLAPPED BLOCK TRANSFER WITHOUT STRING FUNCTIONS

wos_non:
	
		MOV RSI,srcblk
		MOV RDI,dstblk
		MOV RCX,blkcnt
		
		again3:

		MOV AL,[RSI]
		MOV [RDI],AL
		INC RSI
		INC RDI

		LOOP again3
		ret
		
;-------PROCEDURE NON-OVERLAPPED BLOCK TRANSFER WITH STRING FUNCTIONS

ws_non:

	MOV rsi,srcblk
	MOV rdi,dstblk
	MOV rcx,blkcnt
	CLD
	REP movsb
	RET		
   
;-------DISPLAY BOCK CONTENTS-------

write:

up:
	push rsi
	push rcx
	mov  bl , [rsi]
	CALL disp2
	display space,1
	POP rcx
	POP rsi
	
	INC rsi
	LOOP up
	RET

;-------PROCEDURE OVERLAPPED BLOCK TRANSFER WITHOUT STRING FUNCTIONS

wos_o:

	mov rsi , srcblk + 4
	mov rdi , dstblk + 2 
	mov rcx , blkcnt
_transfer:

	mov al , [rsi]
	mov [rdi] , al
	
	dec rsi
	dec rdi
	loop _transfer
	    
	ret
	
;-------PROCEDURE OVERLAPPED BLOCK TRANSFER WITH STRING FUNCTIONS

ws_o:

			mov rsi , srcblk + 4
            mov rdi , dstblk + 2
            mov rcx , blkcnt
            
            STD  
            REP MOVSB
            
	ret
		
;-------DISP 2 PROCEDURE-------
;Procedure to display two digit number
;Number is received trough BL (BL/BX/EBX/RBX) register

disp2:

	MOV RDI,d2buff
	MOV RCX,2

d2up:
	
	ROL BL,4
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
	
	display d2buff,2
	RET
