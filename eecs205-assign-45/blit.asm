; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here
	
.CODE

DrawPixel PROC x:DWORD, y:DWORD, color:DWORD
	
	cmp x, 640    ;; Don't draw if out of bounds
    jge finish
    cmp x, 0
    jl finish
    cmp y, 480
    jge finish
    cmp y, 0
    jl finish
    
    ;mov esi, ScreenBitsPtr  ;; Get the index
    ;mov eax, 640
    ;imul y
    ;add eax, x
 
	mov eax, y
	mov edx, 640
	mul edx
	add eax, x
	add eax, ScreenBitsPtr

    mov ecx, color
    mov BYTE PTR [eax], cl    ;; Plot the point

finish:
    ret

	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES eax ebx ecx edx esi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
	invoke RotateBlit,ptrBitmap,xcenter,ycenter,0
	ret 			; Don't delete this line!!!	
BasicBlit ENDP


RotateBlit PROC lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	LOCAL cosa:FXPT, sina:FXPT, shiftX:DWORD, shiftY:DWORD, dstWidth:DWORD, dstHeight:DWORD, srcX:DWORD, srcY:DWORD, dstX:DWORD, dstY:DWORD
	
    invoke FixedCos, angle          ;; Calculate cos and sin of angle
    mov cosa, eax
    invoke FixedSin, angle
    mov sina, eax


    mov esi, lpBmp

    mov eax, (EECS205BITMAP PTR [esi]).dwWidth  ;; Set shiftX
    ;shl eax, 16
    imul cosa
    sal edx, 16
    sar eax, 16
    or edx, eax
    sar edx, 1         ;; FXPT to DWORD (16), also divide by 2 (1)
    mov ebx, edx

    mov eax, (EECS205BITMAP PTR [esi]).dwHeight
    ;shl eax, 16
    imul sina
    sal edx, 16
    sar eax, 16
    or edx, eax
    sar edx, 1         ;; FXPT to DWORD, (16) also divide by 2 (1)
    mov ecx, edx
    sub ebx, ecx
    mov shiftX, ebx

    mov eax, (EECS205BITMAP PTR [esi]).dwHeight ;; Set shiftY
    ;shl eax, 16
    imul cosa
    sal edx, 16
    sar eax, 16
    or edx, eax
    sar edx, 1         ;; FXPT to DWORD (16), also divide by 2 (1)
    mov ebx, edx

    mov eax, (EECS205BITMAP PTR [esi]).dwWidth
    ;shl eax, 16
    imul sina
    sal edx, 16
    sar eax, 16
    or edx, eax
    sar edx, 1         ;; FXPT to DWORD (16), also divide by 2 (1)
    mov ecx, edx

    add ebx, ecx
    mov shiftY, ebx

    mov eax, (EECS205BITMAP PTR [esi]).dwWidth      ;; Set dstWidth and dstHeight
    mov ebx, (EECS205BITMAP PTR [esi]).dwHeight
    add eax, ebx
    mov dstWidth, eax
    mov dstHeight, eax

    mov edi, (EECS205BITMAP PTR [esi]).lpBytes

    mov ebx, dstWidth       ;; 
    neg ebx
    mov dstX, ebx
 
    jmp outercond
    
outer:
    mov ecx, dstHeight      ;; 
    neg ecx
    mov dstY,ecx
    jmp innercond


inner:
	mov ebx, dstX
    mov eax, cosa       ;; srcX = dstX*cosa + dstY*sina
    ;shl ebx, 16
    imul ebx
    sal edx, 16
    sar eax, 16
    or edx, eax
    mov srcX, edx
    mov ecx, dstY
    mov eax, sina
    ;shl ecx, 16
    imul ecx
    sal edx, 16
    sar eax, 16
    or edx, eax
    add srcX, edx

    mov ecx, dstY
    mov eax, cosa       ;; srcY = dstY*cosa - dstX*sina
    ;shl ecx, 16
    imul ecx
	sal edx, 16
    sar eax, 16
    or edx, eax
    mov srcY, edx
    mov ebx, dstX
    mov eax, sina
    ;shl ebx, 16
    imul ebx
    sal edx, 16
    sar eax, 16
    or edx, eax
    sub srcY, edx

    cmp srcX, 0         ;; if (srcX >= 0 && srcY >= 0)
    jl SKIP_2
    cmp srcY, 0
    jl SKIP_2
    mov eax, (EECS205BITMAP PTR[esi]).dwWidth   ;; && if (srcX < dwWidth)
    cmp srcX, eax
    jge SKIP_2
    mov eax, (EECS205BITMAP PTR[esi]).dwHeight  ;; && if (srcY < dwHeight)
    cmp srcY, eax
    jge SKIP_2

    mov eax, (EECS205BITMAP PTR [esi]).dwWidth
    shl eax, 16          ;; Get index of color in lpBytes
    imul srcY
    sal edx,16
    sar eax, 16
    or edx,eax
    add edx, srcX
    mov dl, BYTE PTR [edi+edx]


    xor eax, eax
    mov al, (EECS205BITMAP PTR [esi]).bTransparent
    cmp dl, al                                        ;; Skip transparent color
    je SKIP_2

    mov ebx, dstX
    ;;mov ebx, 0
    add ebx, xcenter
    sub ebx, shiftX

    mov ecx, dstY                                    ;; shift values
    ;mov ecx, 0
    add ecx, ycenter
    sub ecx, shiftY
    
    invoke DrawPixel, ebx, ecx, edx                         ;; Plot it
    
SKIP_2:
	mov ecx, dstY
    inc ecx
    mov dstY,ecx

innercond:
	mov ecx, dstY
    cmp ecx, dstHeight
    jl inner
    
    mov ebx, dstX
    inc ebx
    mov dstX, ebx

outercond:
	mov ebx, dstX
    cmp ebx, dstWidth
    jl outer

done:

	ret 			; Don't delete this line!!!		
RotateBlit ENDP



END
