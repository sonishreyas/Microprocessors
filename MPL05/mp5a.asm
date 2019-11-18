global _start							; entry point of program

extern _blank							; procedure of another file

global filebuff , filelen				; global so that different file could use it

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

	welmsg db 10,"|--| WELCOME TO FILE HANDLING |--|",10
	wellen equ $-welmsg
	
	tymsg db 10,"|-|-|-| THANK YOU |-|-|-|",10
	tylen equ $-tymsg
	
	succmsg db 10,"-> FILE OPENED SUCCESSFULL !! ",10
	succlen equ $-succmsg
	
	errmsg db 10,"-> ERROR !! OPENING FILE ... ",10
	errmsglen equ $-errmsg
	
	clomsg db 10,"->FILE CLOSED SUCCESSFULLY !!",10
	clolen equ $-clomsg
	
	fname db 'sample.txt', 0 			;NULL TERMINATED string mandatory
	
;-------BSS SECTION-------

section .bss

	filebuff resb 500		; file data is stored here
	filelen resq 1			; file length
	filedesc resq 1			; to store the descriptor returned by rax
	
;-------TEXT SECTION-------

section .txt

	_start:
	
		display welmsg,wellen
		
	
		MOV RAX , 02			; CAll open() function
		MOV RSI , 00			; To Access in READ mode
		MOV RDI , fname			; file name 
		SYSCALL					; CAll to kernel and define rax accordingly	
	
		; CHECK if file is opened
		
		CMP RAX , 00					; check if rax contains file desc
		JL _error						; if rax <= 0 then descriptor is not loaded
		
		MOV [filedesc],RAX				; MOVE file descriptor in RAX to filedesc buffer 
		display succmsg,succlen			; SUCCESS msg
		
		; READ conents of file
		
		MOV RAX , 00					; Kernel cmd to read		
		MOV RDI , [filedesc]			; LOAD filedescriptor to RDI
		MOV RSI , filebuff				; Stores The Content Of File in buffer
		MOV RCX , 500					; Character to read
		SYSCALL
		
		MOV [filelen] , RAX				; After Above Operation Actual Number Of Characters Read will be returned in RAX which we store in filelen buffer
    
		CALL _blank						; CALL procedure of other file
			
		MOV RAX , 03					; CAll close() function
		MOV RDI , [filedesc]			; file descriptor
		SYSCALL							; CAll to kernel 
		display tymsg, tylen
		
		JMP exit
	
	_error:
		
		display errmsg , errmsglen
		
	exit:
		
		MOV RAX , 60		; KERNEl code for exit
		MOV RDI , 00		; OPTIONAL
		SYSCALL
		
		
		
		
		
