; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;	Kushal Gourikrishna 
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive



include stars.inc

.DATA

	;; If you need to, you can place global variables here


.CODE

DrawStarField proc

	;; Place your code here
	



	invoke DrawStar, 100, 100 ;; Each of these lines draws a star at the coordinate specified
	invoke DrawStar, 200, 30  ;; Examples: this line draws a star at (200,30)
	invoke DrawStar, 300, 200
	invoke DrawStar, 105, 444
	invoke DrawStar, 134, 333
	invoke DrawStar, 99, 222
	invoke DrawStar, 10, 111
	invoke DrawStar, 25, 99
	invoke DrawStar, 59, 88
	invoke DrawStar, 289, 141
	invoke DrawStar, 600, 202
	invoke DrawStar, 559, 10
	invoke DrawStar, 499, 124
	invoke DrawStar, 390, 309
	invoke DrawStar, 298, 100
	invoke DrawStar, 2, 299
	
	
	ret  			; Careful! Don't remove this line
DrawStarField endp



END
