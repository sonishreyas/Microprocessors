;  Q-1) Write X86/64 ALP to count number of positive and negative numbers from the array.

global _start

;-------MACRO AREA-------;

%macro display 2
	
	mov rax , 01	;write() function code
	mov rdi , 01	;File Descriptor 
	mov rsi , %1	;Buffer Address
	mov rdx , %2	;Length/Count
	syscall			;LINUX KERNEL call
	
%endmacro

;-------DATA SECTION-------;

section .data

	wcmsg db 10,"WELCOME TO THE CODE",10
	wcmsglen equ $-wcmsg
	
	array dw -23h,3DFEh,23DFh,-45FDh,2345h
	arrcnt equ 5
	
	pmsg db 10,"POSITIVE NUMBER COUNT :: "
	pmsglen equ $-pmsg
	
	nmsg db 10,"NEGATIVE NUMBER COUNT :: "
	nmsglen equ $-nmsg
	
	tymsg db 10,10,"THANK YOU",10
	tymsglen equ $-tymsg
	
;-------BSS SECTION-------;

section .bss

	;UNDEFINED VARIABLES
	
	pcnt resb 1
	ncnt resb 1
	
;-------TEXT SECTION-------;

section .text

	_start:
	
		display wcmsg,wcmsglen
		
		mov rsi , array 	; address of array
		mov rcx , arrcnt	; count loaded in RCX
		mov BL  , 0			; Positive Count
		mov BH	, 0			; Negative Count

	up:
	
		mov AX , [RSI]			; Read element from array
		
		BT AX , 15				; Test MSB Bit
		JC negnxt				; if BT returns 1 ,i.e, number is negative so it jumps to negnxt and inc neg number count
		inc BL					; increment positive number count
		JMP skip				; JUMP to skip after incrementing  positive num. count so that negnum count does not get incremented 
		
	negnxt:
		
		inc BH					; Increment negative number count

	skip:
		inc rsi					; next array element address (2 times increment as dw is data type)
		inc rsi
		
		LOOP up
		
		add BL , 30h			; ASCII equivalent	
		add BH , 30h			; ASCII equivalent
		
		mov [pcnt] , BL			; MOVE positive num count from bl to pcnt buffer
		mov [ncnt] , BH			; MOVE negative num count from bh to ncnt buffer
		
		display pmsg,pmsglen
		display pcnt,1
		
		display nmsg,nmsglen
		display ncnt,1
					
		display tymsg,tymsglen
		
			
		mov rax , 60
		mov rdi , 0
		syscall
