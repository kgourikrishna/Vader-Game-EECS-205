; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;	Kushal Gourikrishna
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine PROC USES eax ebx ecx edx ax x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD

		LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD, error:DWORD, curr_x:DWORD, curr_y:DWORD, prev_error:DWORD
	
	;; Place your code here

	mov ebx, x0 		;moving x0 into register so can use compare
	cmp x1,ebx
	jb opt 				;if x1<x0 jump to other option
	mov eax,x1			;Otherwise, code below subtracts x0 from x1 and puts it in delta_x
	sub eax,ebx 
	mov delta_x,eax
	jmp continue

	opt:
		sub ebx,x1		;since x1<x0 we must reverse the subtraction to maintain absolute value
		mov delta_x,ebx	;delta_x equals result
	
	continue:
		mov ebx,y0		;the code below does the same as above but for delta_x
		cmp y1,ebx
		jb op1
		mov eax,y1
		sub eax,ebx
		mov delta_y,eax
		jmp con

	op1:
		sub ebx,y1
		mov delta_y,ebx

	con:
		mov ebx, x0		
		cmp ebx,x1		;compare x0,x1
		jnb else1		;if x0 is not lest than x1 jmp to else
		mov inc_x,1
		jmp con1
	
	else1:
		mov inc_x,-1	;set value of inc_x to -1

	con1:
		mov ecx, y0		;code below does same as above for y0 and y1 and inc_y
		cmp ecx,y1
		jnb else2
		mov inc_y,1
		jmp con2

	else2:
		mov inc_y,-1

	con2:
		mov ebx, delta_x	;move delta_x to register so it can be compared
		cmp ebx, delta_y	;compare delta_x and delta_y
		jng else3			; if delta_x not greater than delta_y jump to else3
		mov edx, 0
		mov eax, delta_x	;following code divides delta_x by 2 and puts result in error if delta_x>delta_y
		mov ecx,2
		div ecx
		mov error, eax
		jmp con3

	else3:
		mov eax, delta_y	;following code divides delta by -2
		mov edx, 0
		mov ecx, -2
		div ecx
		mov error, eax
	
	con3:
		mov eax,x0			; following code puts x0 and y0 in curr_x and curr_y respectively
		mov curr_x, eax
		mov ebx, y0
		mov curr_y, ebx
		invoke DrawPixel, curr_x,curr_y,color

	jmp eval								;loop code

	do:
		invoke DrawPixel, curr_x,curr_y,color	;calling the drawpixel method 
		mov eax, error
		mov prev_error,eax
		mov eax, -1
		mul delta_x
		cmp prev_error, eax   			;comparing prev_error and -delta_x
		jng continue1					;if greater do code below which increments curr_x and updates error
		mov ebx,delta_y					;otherwise go to continue1
		sub error, ebx
		mov ecx, inc_x
		add curr_x, ecx

	continue1:
		mov eax,delta_y					;compares prev_error and delta_y
		cmp prev_error,eax 				;if less than then update error and increment curr_y otherwise to eval
		jnl eval
		mov ebx, delta_x
		add error, ebx
		mov ecx, inc_y
		add curr_y, ecx

	eval:
		mov eax, x1					;if curr_x equals x1 or curr_y equals y1 end loop and code
		cmp curr_x,eax
		je done
		mov ebx, y1
		cmp curr_y,ebx
		jne do

	done:


		ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END