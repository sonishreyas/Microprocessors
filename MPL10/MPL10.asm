global main
extern printf

section .data

	a	dq	1.000
	b	dq  0.000
	c	dq	6.000
	
	intgr	dw	4
	
	infrm	db	10 , 'a = %e '
			db	10 , 'b = %e '
			db	10 , 'c = %e '
			db	10 , 0			;NULL TERMINATED STRING
			
	ofrm	db	10 , 'Root - 1 = %e '
			db	10 , 'Root - 2 = %e '
			db	10 , 0
			
	imgmsg 	db 	10 , "--ROOTS ARE IMAGINARY--",10
	imglen equ $ - imgmsg
	
section .bss

	sqrtbuff	resq 	1			; to store value of sqrt(b*b - 4*a*c)
	negb		resq 	1			; to store (-b) value
	rootno1		resq	1			; to store root - 1
	rootno2		resq	1			; to store root - 2
	
section .txt

	main:
		
		push RBP
		finit
		
		mov rax , 3					; no. of floating point const.
		
		;------- TO DISPLAY THE COOFICIENTS-------
		
		mov rdi , infrm				; rdi stores the format of o/p
		
		movq xmm0 , [a]
		movq xmm1 , [b]
		movq xmm2 , [c]
		
		call printf
		
		;------- CALCULATING ROOTS -------
		
		;--b*b--
		
		FLD 	qword[b]			; pushes b to the TOS
		FMUL 	qword[b]			; multiply b with TOS
		
		;--4*a*c--
				
		FLD		qword[ a ]			; pushes a to TOS
		FMUL	qword[ c ]			; multiply c with TOS , i.e. , a
		FIMUL	word[ intgr ]		; multiply 4 with TOS , i.e. , a*c

		;--sqrt(b*b - 4*a*c)--
		
		FSUB	
		
		;--CHECK IF ROOTS ARE IMAGINSRY--
		 
		FTST
		FSTSW AX
		BT AX ,8
		JBE error
		
		;--IF REAL PROGRAM PROCEED--
		
		FSQRT 
		FST		qword[ sqrtbuff ]
		
		;--(-b)--
		
		FLDZ 						; loads 0 to TOS
		FSUB	qword[ b ]			; inorder to get -b
		FST		qword[ negb ]		; store -b in negb
		
		;--(-b) + sqrt(	b*b - 4*a*c)--
		
		FADD 
		
		;--((-b) + sqrt(	b*b - 4*a*c))/(2*a)--
		
		FLD		qword[a]	
		FADD	qword[a]
		FDIV
		
		;--STORE ROOT IN A BUFFER--
		
		FSTP	qword[rootno1]
		
		;--2nd root--
		 
		FLD		qword[negb]
		FSUB	qword[sqrtbuff] 						
		FLD		qword[a]
		FADD	qword[a]
		FDIV
		FSTP	qword[rootno2]
		
		;--display roots--
		
		mov rax , 2
		mov rdi , ofrm
		movq xmm0 , [rootno1]
		movq xmm1 , [rootno2]
		call printf
		JMP exit
	
	error:
		
		mov rdi , imgmsg
		mov rax , 0	
		call printf
		
	exit:
	
		mov rax ,60
		mov rdi , 0
		syscall
		

