; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	NEGATE BYTE 0    ;;set if angle is between pi and 2pi
	
.CODE

FIXED_POINT_MULTIPLY	PROC USES ecx edx a:FXPT, x:FXPT, p:FXPT

	;; Place your code here
mov eax, a  
mov ecx, x  
imul ecx    

shr eax, 16 
shl edx, 16 
or eax, edx 

add eax, p  

	ret  			; Careful! Don't remove this line	
FIXED_POINT_MULTIPLY	endp

FixedSin PROC angle:FXPT

	cmp angle, 0            ;; check 0 < angle < 2pi
    jl NEGATIVE
    cmp angle, TWO_PI
    jg OUTSIDE_RANGE
    jmp INSIDE_RANGE

OUTSIDE_RANGE:         ;; mod angle by 2pi if 0 > angle or angle > 2pi
	mov ecx, TWO_PI
    xor edx, edx
    mov eax, angle
    idiv ecx
    mov angle, edx  
    jmp INSIDE_RANGE

NEGATIVE:
	mov ecx, 0     
    sub ecx, angle
    mov angle, ecx
    xor edx, edx
    mov eax, angle
    mov ecx, TWO_PI
    idiv ecx
    mov angle, edx  
    add NEGATE, 1
    
INSIDE_RANGE:
    cmp angle, PI           ;; check pi < angle < 2pi
    jl WITHIN_PI
    add NEGATE, 1 ;; set if we need to NEGATE later
    sub angle, PI           ;; shift the angle

WITHIN_PI:
    cmp angle, PI_HALF      ;; check 0 < angle < pi/2
    jg BETWEEN_PI_PI_HALF
    jl WITHIN_PI_HALF
    mov eax, 00010000h      ;; if angle = pi/2, return 1
    jmp DONE 

BETWEEN_PI_PI_HALF:              ;; shift angle if pi/2 < angle < pi
    mov ecx, PI
    sub ecx, angle
    mov angle, ecx

WITHIN_PI_HALF:            ;; use the table if 0 < angle < pi/2
    invoke FIXED_POINT_MULTIPLY, angle, PI_INC_RECIP, 0  
    mov ecx, eax
    shr ecx, 16             ;; only take top half of index
    xor eax, eax
    movzx eax, [SINTAB + 2*ecx] ;; get value from table
    
    cmp NEGATE, 1    ;; NEGATE result if angle was between pi and 2pi
    jne DONE
    mov ecx, 0     
    sub ecx, eax
    mov eax, ecx

DONE:
    mov NEGATE, 0     ;; reset this value!

	ret 	; Don't delete this line!!!
FixedSin ENDP 
	
FixedCos PROC angle:FXPT
	add angle, PI_HALF
	invoke FixedSin, angle

	ret		; Don't delete this line!!!	
FixedCos ENDP


END

