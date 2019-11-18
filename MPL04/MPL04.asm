global _start

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

section .data
		
	welmsg db 10,"**********WELCOME TO MULTIPLICATION OF HEX NUMBERS BY SHREYAS**********",10
	wmsglen equ $-welmsg
	
	thmsg db 10,"|_|_|_|_|_|--THANK YOU--|_|_|_|_|_|",10
	thsglen equ $-thmsg

	menumsg db 10,10,"|+|+|+|+|+|+| MENU |+|+|+|+|+|+|+|+|",10
			db 10,"1. BY SUCCESSIVE ADDITION. "
			db 10,"2. BY ADD AND SHIFT METHOD."
			db 10,"3. EXIT.",10
			db 10,10,"PLEASE ENTER YOUR CHOICE :: "
	menumsglen equ $-menumsg
	
	resmsg db 10 , 'Multiplication Result :'
    reslen equ $ - resmsg
    
	mulmsg db 10,"ENTER THE MULTIPLICAND (2-digit IN HEX) :: "
	mulmsglen equ $-mulmsg
	
	multimsg db 10,"ENTER THE MULTIPLIER :: "
	multimsglen equ $-multimsg
	
	samsg db 10,"!!!!! USING SUCCESIVE ADDITION !!!!!",10
	samsglen equ $-samsg
	
	asmsg db 10,"!!!!! USING ADD AND SHIFT METHOD !!!!!",10
	asmsglen equ $-asmsg
	
	invalmsg db 10,"INVALID CHOICE",10
	invalmsglen equ $-invalmsg
	
	saomsg db 10,"MULTIPLIED NUMBER :: ",10
	saomsglen equ $-saomsg
	bitcount equ 8
	
section .bss

		chbuff resb 2
		d4buff resb 4
		d8buff resb 8
		num resb 3
		num1 resb 1
		num2 resb 1
		;outbuff resb 5

section .text

_start:

	display welmsg,wmsglen

menu:

	display menumsg,menumsglen
	
	read chbuff,2
	MOV AL,[chbuff]
	CMP AL,'1'
	JNE case2
	CALL msa
	JMP menu
	
case2:  CMP AL,'2'
	   	JNE case3
		CALL mas
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

; ########## PROCEDURE INVOLVING SUCCESIVE ADDITION  #############	
msa:
	
	display samsg,samsglen
	CALL accept

;core logic
		
	XOR DX,DX
	XOR AX,AX
	MOV DL,[num1]
	XOR RCX,RCX
	MOV CL,[num2]
	JRCXZ done
loop1:
	ADD AX,DX
	loop loop1
done:	
	MOV BX,AX
	display saomsg,saomsglen
	call disp4

	RET
	
;##########_ADD & SHIFT_############

mas:
	
	display asmsg,asmsglen
	CALL accept
	
	xor rax , rax
    xor rbx , rbx
    xor rcx , rcx
    xor rdx , rdx
    
    mov ah ,   00h
    mov cl ,   08
    mov al , [num1]
    mov bl , [num2]
    CLC
        
    loop5 :
        
        BT  ax , 00
        jnc shift
        add ah , bl
        
    shift :
        
        rcr ax , 1
        loop loop5
        
    displayResult :
        
        mov  bx , ax
        display resmsg , reslen
        call disp4

	ret
	
accept:
	
	display multimsg,multimsglen
	read num,3
	CALL convert2
	MOV [num1],BL
	
	display mulmsg,mulmsglen
	read num,3
	CALL convert2
	MOV [num2],BL
	
	RET

convert2:
		MOV BL,0
		MOV RSI,num
		MOV RCX,2
c2up:		
		ROL BL,4
		MOV AL,[RSI]
		SUB AL,30H
		CMP AL,9
		JBE c2skip	
		SUB AL,7
		
c2skip:
		ADD BL,AL
		INC RSI
		LOOP c2up
		
	RET		


; ########## PROCEDURE TO DISPLAY 4 BIT OUTPUT  #############	
disp4:

	MOV RDI,d4buff
	MOV RCX,4

d4up:
	
	ROL BX,4
	MOV AL,BL
	AND AL,0fh	
	ADD AL,30h
	CMP AL,39h
	JBE d4skip
	ADD AL,07h
	
d4skip:

	MOV [RDI],AL
	INC RDI
	LOOP d4up
	
	display d4buff,4
	RET
	
	
	
	
disp8:

	MOV RDI,d8buff
	MOV RCX,8

d8up:
	
	ROL EBX,4
	MOV AL,BL
	AND AL,0fh	
	ADD AL,30h
	CMP AL,39h
	JBE d8skip
	ADD AL,07h
	
d8skip:

	MOV [RDI],AL
	INC RDI
	LOOP d8up
	
	display d8buff,8
	RET
