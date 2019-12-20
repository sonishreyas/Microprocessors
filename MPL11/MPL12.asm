global main		;	entry control point
extern printf

section .data

	welmsg db 10,"WELCOME TO MEAN, VARIANCE AND STANDARD DEVIATION " , 10
	
	infrm 	db	10, ' %e '
			db	10, ' %e '
			db	10, ' %e '
			db	10,	' %e '
			db	10, ' %e '
			db	10 , 0
			
	ofrm	db 10,' %s %e'
			db 10,' %s %e'
			db 10,' %s %e'
			db 10, 0
			
    thkmsg db 10 , ' -- Thank You -- ' , 10 , 0
    
    arrmsg db 10 , ' Array Content  : ' , 0
    
    menmsg db 10 , ' Mean           : ' , 0
    
    varmsg db 10 , ' Variance       : ' , 0
    
    stdmsg db 10 , ' Std. Deviation : ' , 0
    
    msgfmt db 10 , ' %s ' , 0
    
    arrnum dq 109.03 , 102.5 , 120.36 , 222.22 ,107.89
    arrcnt dw 5
     
section .bss

	meanbuff resq 1
	stdbuff	resq 1
	varbuff	resq 1
	
section .txt

	main:
					
		push RBP
		mov rdi , msgfmt
		mov rsi , welmsg
		call printf
		
		mov rdi , msgfmt
		mov rsi , arrmsg
		call printf
		
		mov rax , 5
		mov rdi , infrm
		mov rsi , 00
		mov rbx , arrnum
		
		
		movq xmm0 , [ rbx + rsi * 8 ]
		inc rsi
		
		movq xmm1 , [ rbx + rsi * 8 ]
		inc rsi
		
		movq xmm2 , [ rbx + rsi * 8 ]
		inc rsi
		
		movq xmm3 , [ rbx + rsi * 8 ]
		inc rsi	 
		
		movq xmm4 , [ rbx + rsi * 8 ]
		call printf
		
		finit
		
		FLDZ
		xor rcx , rcx
		mov rbx , arrnum
		mov rsi , 00
		mov cx , [arrcnt]
		
		mean:
		
			FADD qword[rbx + rsi * 8]
			inc rsi
			loop mean
		
		FIDIV 	word[arrcnt]
		FST		qword[meanbuff]
		
		
		;-------VARIANCE-------
		
		xor rcx , rcx
		mov cx , [arrcnt]
		mov rdx , arrnum
		mov rsi , 00
		
		FLDZ
		var:
		
			FLDZ
			FLD		qword[rdx + rsi * 8]
			FSUB 	qword[meanbuff]
			FST 	ST1
			FMUL	
			FADD
			inc rsi
			loop var
			
			FIDIV  word[arrcnt]
			FST		qword[varbuff]
			FSQRT
			FST		qword[stdbuff]
			
			mov rax , 3
			mov rsi , menmsg
			mov rdi , ofrm
			
			mov rcx , stdmsg
			mov rdx , varmsg
			movq xmm0 , qword[meanbuff]
			movq xmm1 , qword[stdbuff]
			movq xmm2 , qword[varbuff]
			call printf
			
			pop RBP
			
		exit:
		
			mov rax , 60
			mov rdi , 00
			syscall	
		
		
