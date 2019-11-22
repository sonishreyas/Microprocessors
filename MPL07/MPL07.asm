global _start

;------- MACRO AREA -------

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

;-------MACRO FOR OPENING FILE-------

%macro open 1

	MOV RAX , 02		;OPEN FILE
	MOV RSI , 02
	MOV RDI , %1
	SYSCALL

%endmacro

;-------MACRO FOR CLOSING FILE-------

%macro close 1

	MOV RAX , 03
	MOV RDI , %1
	SYSCALL
	
%endmacro

;-------DATA SECTION-------

section .data

	welmsg db 10,"WELCOME TO BUBBLE SORT ",10
	welmsglen equ $ - welmsg
	
	tymsg db 10,"|:|:|:|THANK YOU|:|:|:|",10
	tymsglen equ $ - tymsg
	
	fopenmsg db 10,"-->FILE OPENED SUCCESSFULLY",10
	fopenmsglen equ $ - fopenmsg
	
	fclosemsg db 10,"-->FILE CLOSED SUCCESSFULLY",10
	fclosemsglen equ $ - fclosemsg
	
	errmsg db 10,"-->ERROR OPENING A FILE",10
	errmsglen equ $ - errmsg
	
	freadmsg db 10,"-->READING THE FILE...",10
	freadmsglen equ $ - freadmsg
	
	sortmsg db 10,"-->SORTED SUCCESSFULLY...",10
			db 10,"...FILE CONTENT...",10
	sortmsglen equ $ - sortmsg
	
	fname db 'bubble.txt', 0
	
;-------BSS SECTION-------

section .bss

	filelen resq 1
	filebuff resb 500
	filedesc resq 1
	
;-------TEXT SECTION-------

section .txt

	_start:
		
		display welmsg,welmsglen
		
		;-------Calling OPEN macro to open the file -------
		 
		open fname
		
		;------- CHECKING IF FILE IS OPENED OR NOT BY CHECKING RAX ;  AS RAX IS LOADED WITH FILE DISCRIPTOR IF FILE IS OPENED ; IF NOT RAX <= 0 -------
		
		CMP RAX , 00
		JL error
		
		;------- SUCCESSFUL OPENING OF FILE -------
		
		MOV [ filedesc ] , RAX
		display fopenmsg,fopenmsglen
		 
		;------- Reading the file -------
		
		MOV RAX , 00
		MOV RDI , [ filedesc ]
		MOV RSI , filebuff  
		MOV RCX , 500
		SYSCALL
		
		;------- STORING ACTUAL LENGTH  OF FILE IN filelen buffer -------
		
		MOV [ filelen ] , RAX
		
		;------- FILE CONTENT BEFORE SORTING -------
		
		display filebuff , [filelen]
		
		;------- CALLING BUBBLE SORT PROCEDURE -------
		 
  		MOV RDX , 4
		loop1:
			
			MOV RSI , filebuff
			MOV RDI , filebuff + 2
			MOV RCX , RDX
		loop2:
			
			MOV AL , [RSI]
			CMP AL , [RDI]
			JL noswap
			
			XCHG AL , [RDI]
			MOV [RSI], AL
			
		noswap:
			
			INC RSI
			INC RSI
			INC RDI
			INC RDI
			
			loop loop2

			DEC RDX
			JNZ loop1
			
		result:
		
			display sortmsg , sortmsglen
			display filebuff,[filelen ]
			
		;------- WRITE THE RESULT BACK TO THE FILE -------
		
		MOV RAX , 01
		MOV RDI , [filedesc]
		MOV RSI , filebuff
		MOV RCX , [filelen]
		SYSCALL
					
		;------- Call CLOSE macro for Closing of file -------
		
		close filedesc
		display fclosemsg , fclosemsglen
		JMP exit
		 
	error:
	
		display errmsg,errmsglen
		
	exit:
		
		display tymsg , tymsglen
		
		MOV RAX , 60
		MOV RDI , 00
		SYSCALL 		
 
