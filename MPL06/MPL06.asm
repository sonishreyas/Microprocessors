global _start

;######Macro Area ######

%macro read 2
	mov rax,0
	mov rdi,0
	mov rsi,%1
	mov rdx,%2
	syscall

%endmacro

%macro display 2
	mov rax,1
	mov rdi,1
	mov rsi,%1
	mov rdx,%2
	syscall

%endmacro

;#####Data Area#####

section .data
	welmsg db 10,">>>>>>>> Welcome <<<<<<<",10
	wmsglen equ $-welmsg
	
	tnkmsg db 10,10,"!!!!!!! Thank You !!!!!!!",10
	tnklen equ $-tnkmsg
	
	promsg db 10,"PROTECTED MODE",10
	promsglen equ $-promsg
		
	realmsg db 10,"REAL MODE",10
	realmsglen equ $-realmsg
	
	gdtrmsg db 10,"GDTR Contents are : "
	gdtrmsglen equ $-gdtrmsg
	
	ldtrmsg db 10,10,"LDTR Contents are : "
	ldtrmsglen equ $-ldtrmsg
	
	idtrmsg db 10,10,"IDTR Contents are : "
	idtrmsglen equ $-idtrmsg
	
	trmsg db 10,10,"TR Contents are   : "
	trmsglen equ $-trmsg
	
	mswmsg db 10,10,"MSW Contents are  : "
	mswmsglen equ $-mswmsg
	
	colon db ':'
	
;####BSS Section####

section .bss

		gdtrbuff resb 6
		ldtrbuff resb 2
		idtrbuff resb 6
		trbuff resb 2
		mswbuff resb 4
		d4buff	resb 4

;#####Code Area#####

section .txt

_start:

	display welmsg,wmsglen
	
	SMSW EAX					; instruction for MSW.

	BT	EAX,0
	JC	PROTECT
	display realmsg,realmsglen

	JMP exit
	
PROTECT:

		display promsg,promsglen
		JMP skip

skip:
	
		SGDT	[gdtrbuff]
		SLDT	[ldtrbuff]
		SIDT	[idtrbuff]
		STR		[trbuff]
		SMSW	[mswbuff]
		
		;=========================== display gdtr contents ================================
		display gdtrmsg,gdtrmsglen
		
		MOV BX,[gdtrbuff + 4]
		CALL disp4 
		
		MOV BX,[gdtrbuff + 2]
		CALL disp4
		
		display colon,1
		
		MOV BX,[gdtrbuff]
		CALL disp4

		;=========================== display LDTR contents ================================
		
		display ldtrmsg,ldtrmsglen
		
		MOV BX,[ldtrbuff]
		CALL disp4
		
		;=========================== display IDTR contents ================================
		
		display idtrmsg,idtrmsglen
		
		MOV BX,[idtrbuff + 4]
		CALL disp4 
		
		MOV BX,[idtrbuff + 2]
		CALL disp4
		
		display colon,1
		
		MOV BX,[idtrbuff]
		CALL disp4	
		
		;=========================== display TR contents ================================
		
		display trmsg,trmsglen
				
		MOV BX,[trbuff]
		CALL disp4
		
		;=========================== display MSW contents ================================
		
		display mswmsg,mswmsglen
		
	;	MOV BX,[mswbuff + 4]
	;	CALL disp4
		
		MOV BX,[mswbuff + 2]
		CALL disp4
		
		display colon,1
		
		MOV BX,[mswbuff]
		CALL disp4
exit:

	display tnkmsg,tnklen
	mov rax,60
	mov rdi,0
	syscall	 	
	
	
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
