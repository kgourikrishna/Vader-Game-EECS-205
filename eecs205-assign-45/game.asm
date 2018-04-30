; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
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
include game.inc
include keys.inc

include \masm32\include\windows.inc 
include \masm32\include\winmm.inc 
includelib \masm32\lib\winmm.lib 
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib

	
.DATA


;; If you need to, you can place global variables here

VaderSprite EECS205SPRITE <?,? ,?, ?,?,?>			;;initializing sprites
TrooperSprite EECS205SPRITE 100 DUP (<?,?,?,?,1,0>)
Lightsaber EECS205SPRITE <?,?,?,?,0,?>


VaderXPos DWORD ?				;;initializing position variables for three sprites
VaderYPos DWORD ?

TrooperX DWORD ?
TrooperY DWORD ?
TrooperMap DWORD ?

SaberX DWORD ?
SaberY DWORD ?

GameStart DWORD 0				;;game state variables
Saber_Collision DWORD 0
PauseCheck DWORD 0
GameOver DWORD 0

deathstr BYTE "YOU FAILED", 0												;;strings used in game
pause BYTE "GAME IS PAUSED", 0
StartSTR BYTE "DARTH VADER'S REVENGE",0
StartSTR1 BYTE "Destroy every stormtrooper. Leave no witnesses.",0
StartSTR2 BYTE "Move Vader with the mouse. Press space for saber throw",0
StartSTR3 BYTE "Press shift to start",0
StartSTR4 BYTE "Press P to pause",0
StartSTR5 BYTE "If 5 stormtroopers pass you lose.",0
GameOverStr BYTE "GAME OVER. YOU FAILED TO TAKE OVER THE EMPIRE",0
WIN BYTE "CONGRATULATIONS! YOU NOW LEAD THE EMPIRE",0


counter DWORD 0													;;loop counter


Troopers_Not_Killed DWORD 0										;;score variables
fmtStr2 BYTE "WITNESSES: %d",0
outStr2 BYTE 256 DUP(0)


Killed DWORD 0
fmtStr BYTE "STORMTROOPERS KILLED: %d",0
outStr BYTE 256 DUP(0)


SndPath BYTE "imperial_march.wav",0								;;sound variable
SndPath1 BYTE "fx4.wav",0
SndPath2 BYTE "vader_breathing.wav",0









Counted DWORD 0

.CODE
	

;; Note: You will need to implement CheckIntersect!!!


CheckIntersect Proc USES ebx esi edi ecx  oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
	
	LOCAL right_side1:DWORD, right_side2:DWORD, left_side1:DWORD, left_side2:DWORD, top1:DWORD, top2:DWORD, bottom1:DWORD, bottom2:DWORD

	mov esi, oneBitmap
	mov edi, twoBitmap

	mov ecx, (EECS205BITMAP PTR [esi]).dwWidth		;; finding left bound of first bitmap
	sar ecx, 1
	mov ebx, oneX
	sub ebx, eax
	mov left_side1, ebx

	add ebx, (EECS205BITMAP PTR [esi]).dwWidth		;; add width to find right bound
	mov right_side1,ebx


	mov ecx, (EECS205BITMAP PTR [edi]).dwWidth			;; finding left bound of second bitmap
	sar ecx, 1
	mov ebx, twoX
	sub ebx, eax
	mov left_side2, ebx

	add ebx, (EECS205BITMAP PTR [edi]).dwWidth		;add width to find right bound
	mov right_side2,ebx


	mov ecx, (EECS205BITMAP PTR [esi]).dwHeight		;;find bottom bound of first bitmap then sub height to find top
	sar ecx, 1
	mov ebx,oneY
	add ebx, eax
	mov bottom1, ebx

	sub ebx, (EECS205BITMAP PTR [esi]).dwHeight
	mov top1, ebx

	mov ecx, (EECS205BITMAP PTR [edi]).dwHeight
	sar ecx, 1
	mov ebx,twoY
	add ebx, eax
	mov bottom2, ebx

	sub ebx, (EECS205BITMAP PTR [edi]).dwHeight
	mov top2, ebx


	mov ebx, right_side1				;; all the proper checks to check for collision
	cmp ebx, right_side2
	jg CHECK_LEFT

	cmp ebx, left_side2
	jge CHECK_TOP_BOTTOM
	jmp NO_INTERSECTION

	CHECK_LEFT:
		mov ebx, left_side1
		cmp ebx, right_side2
		jle CHECK_TOP_BOTTOM
		jmp NO_INTERSECTION

	CHECK_TOP_BOTTOM:
		mov ebx, bottom1
		cmp ebx, bottom2
		jg CHECK_TOP

		cmp ebx, top2
		jge INTERSECT
		jmp NO_INTERSECTION

	CHECK_TOP:
		mov ebx, top1
		cmp ebx, bottom2
		jle INTERSECT

	INTERSECT:
		mov eax, 1
		jmp DONE

	NO_INTERSECTION:
		xor eax, eax

	DONE:
		ret
CheckIntersect ENDP

GameInit PROC USES esi ebx edx ecx  

	invoke DrawStarField

	rdtsc																;;random number initialization
	invoke nseed, eax

	mov eax,200
	sal eax, 16															;;Set initial position of vader

	mov esi, OFFSET VaderSprite

	mov (EECS205SPRITE PTR [esi]).fxptXCenter, eax
    mov (EECS205SPRITE PTR [esi]).fxptYCenter, eax
    mov (EECS205SPRITE PTR [esi]).ptrBitmap, OFFSET Darth_Vader_Sprite_2		

    mov esi, OFFSET TrooperSprite

    COND1:																;;initialize stormtrooper array with loop
    	cmp counter, 100
    	jg FIN_INIT

    	invoke nrandom,400
    	mov ebx, eax
    	add ebx, 50
    	sal ebx,16
    	invoke nrandom, 10000
    	add eax,640
    	sal eax, 16

 
    mov (EECS205SPRITE PTR [esi]).fxptXCenter, eax
    mov (EECS205SPRITE PTR [esi]).fxptYCenter, ebx
    mov (EECS205SPRITE PTR [esi]).ptrBitmap, OFFSET Stormtrooper_Sprite

    invoke nrandom, 3													;;set random speed for each trooper
    add eax, 5
    mov (EECS205SPRITE PTR [esi]).speed,eax


    add counter,1
    add esi,TYPE TrooperSprite

    jmp COND1

    FIN_INIT:

    mov esi, OFFSET Lightsaber 													;;initialize lightsaber sprite
    mov (EECS205SPRITE PTR [esi]).ptrBitmap, OFFSET Lightsaber_Sprite



   	invoke DrawStr, OFFSET StartSTR, 200,140,0ffh								;;draw all of the initial instructions
   	invoke DrawStr, OFFSET StartSTR1, 100,170,0ffh
   	invoke DrawStr, OFFSET StartSTR2, 100, 200,0ffh
   	invoke DrawStr, OFFSET StartSTR4, 100, 230, 0ffh
   	invoke DrawStr, OFFSET StartSTR5, 100, 260, 0ffh
   	invoke DrawStr, OFFSET StartSTR3, 100, 290, 0ffh



   		invoke PlaySound, offset SndPath, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP  ;;play music

	ret         ;; Do not delete this line!!!
GameInit ENDP


GamePlay PROC USES ebx esi ecx edx edi


	cmp GameStart,0										;;Check if game has started (press shift to start)
	jne BEGIN


	cmp KeyPress, VK_SHIFT
	jne GAMEOVER
	mov GameStart,1


	BEGIN:

	invoke BlackStarField								;;Clear scree, draw star field
	invoke DrawStarField



	mov counter, 0

	cmp PauseCheck,1 									;;Check if paused (Press p to pause)
	jne NOT_PAUSED
	cmp KeyPress, VK_P
	je UNPAUSE
	invoke DrawStr, OFFSET pause, 300,240, 0ffh
	jmp GAMEOVER

	UNPAUSE:
		mov PauseCheck, 0
		jmp CONTINUE

	NOT_PAUSED:
		cmp KeyPress, VK_P
		jne CONTINUE
		mov PauseCheck, 1
		jmp GAMEOVER

	CONTINUE:

	cmp Killed, 50 										;;Check if player has kill 50 stormtroopers, if so then draw win screen and end game
	jl CONTINUE2
	invoke DrawStr, OFFSET WIN, 100,210, 0ffh
	jmp GAMEOVER

	CONTINUE2:

	cmp GameOver,0																	;; check if gameover flag is set, draw loss screen if so
	je NEXT_CHECK
	invoke DrawStr, OFFSET GameOverStr, 100,210,0ffh
	;invoke PlaySound, offset SndPath2, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP

	jmp GAMEOVER

	NEXT_CHECK:

	cmp Troopers_Not_Killed, 5														;;check if troopers escaped >5, if so then lose
	jl START
	invoke DrawStr, OFFSET GameOverStr, 100,210,0ffh
	;invoke PlaySound, offset SndPath2, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP

	jmp GAMEOVER



	
	START:												;;push #killed and #escaped scores as strings on to screen
	push Killed
	push OFFSET fmtStr
	push OFFSET outStr
	invoke wsprintf
	add esp,12
	invoke DrawStr, OFFSET outStr, 50,50,0ffh

	push Troopers_Not_Killed
	push OFFSET fmtStr2
	push OFFSET outStr2
	invoke wsprintf
	add esp,12
	invoke DrawStr, OFFSET outStr2, 50,80,0ffh


	mov esi, OFFSET VaderSprite                	
    invoke PlayerPositionUpdate, esi 					;;vader moves with the mouse position
    mov ebx, (EECS205SPRITE PTR [esi]).fxptXCenter
    mov ecx, (EECS205SPRITE PTR [esi]).fxptYCenter
    sar ebx, 16
    sar ecx, 16
    mov VaderXPos, ebx
    mov VaderYPos, ecx
    mov edx, (EECS205SPRITE PTR [esi]).ptrBitmap
    invoke BasicBlit, edx, ebx, ecx

    mov edi, OFFSET Lightsaber

    invoke ThrowLightsaber, edi, OFFSET VaderSprite 	;;press and space and lightsaber will appear on darth vader

   	cmp (EECS205SPRITE PTR [edi]).active, 1				;;if saber is active (space pressed) update position
   	jne TROOPER

   	invoke UpdateSaberPos, edi
   	mov ebx, (EECS205SPRITE PTR[edi]).fxptXCenter
   	mov ecx, (EECS205SPRITE PTR[edi]).fxptYCenter
   	sar ebx, 16
   	sar ecx, 16
   	mov SaberX, ebx
   	mov SaberY, ecx
   	cmp SaberX, 640										;;deactivate saber if it crosses end of screen
   	jle PROCEED
   	mov (EECS205SPRITE PTR [edi]).active,0

   	PROCEED:
   	
   	mov edx, (EECS205SPRITE PTR[edi]).ptrBitmap 
   	invoke BasicBlit,OFFSET Lightsaber_Sprite,ebx,ecx

   	TROOPER:											;;loop through troopers and draw if active

    mov esi, OFFSET TrooperSprite

    COND2:
    	cmp counter,55
    	jg LIGHTSABER


    invoke TrooperPositionUpdate, esi

    cmp (EECS205SPRITE PTR [esi]).active,1				
    jne INCREMENT

   	mov ebx, (EECS205SPRITE PTR [esi]).fxptXCenter
  	mov ecx, (EECS205SPRITE PTR [esi]).fxptYCenter
   	sar ebx, 16
   	sar ecx, 16
   	mov TrooperX, ebx
   	mov TrooperY, ecx
   	mov eax, (EECS205SPRITE PTR [esi]).ptrBitmap
    mov TrooperMap,eax

    cmp TrooperX, 0									;;if trooper crosses left half of screen, increment not killed, set count flag
    jg CONTINUE1

    cmp (EECS205SPRITE PTR[esi]).count, 0
	jne CONTINUE1

    inc Troopers_Not_Killed
    mov (EECS205SPRITE PTR[esi]).count, 1
    mov (EECS205SPRITE PTR [esi]).active,0


    CONTINUE1:

   	invoke BasicBlit, TrooperMap,TrooperX,TrooperY

   	mov edi, OFFSET Lightsaber

   	cmp (EECS205SPRITE PTR [edi]).active,1
   	jne INCREMENT

   	invoke CheckIntersect,SaberX, SaberY, (EECS205SPRITE PTR[edi]).ptrBitmap,TrooperX, TrooperY,eax    ;;check intersect between saber and each trooper

   	cmp eax,1
   	jne INCREMENT

    mov Saber_Collision,1																				;;set collision flag, reset saber
    mov (EECS205SPRITE PTR [esi]).active, 0
    mov (EECS205SPRITE PTR [edi]).active, 0
    inc Killed

   	INCREMENT: 	
   		add counter,1
   		add esi,TYPE TrooperSprite


   	jmp COND2


  LIGHTSABER:

  GAMEOVER:

	
	ret         ;; Do not delete this line!!!
GamePlay ENDP

PlayerPositionUpdate PROC USES esi edi edx ebx ptrSprite:PTR EECS205SPRITE


	mov esi, OFFSET MouseStatus
	mov edi, ptrSprite

	cmp (MouseInfo PTR [esi]).horiz, 200
	jg OVER

	mov ebx, (MouseInfo PTR [esi]).horiz		;;inputs mouse x and y position as vaders position each cycle
	mov edx, (MouseInfo PTR [esi]).vert

	sal ebx, 16
	sal edx, 16

	mov (EECS205SPRITE PTR [edi]).fxptYCenter,	edx
	mov (EECS205SPRITE PTR [edi]).fxptXCenter, ebx
	
	OVER:
	ret

PlayerPositionUpdate ENDP


TrooperPositionUpdate PROC USES esi ebx ecx ptrSprite:PTR EECS205SPRITE
	
	mov esi, ptrSprite

	mov ebx, (EECS205SPRITE PTR [esi]).speed									;;add speed of trooper and update position accordingly
	sal ebx, 16

	mov ecx, (EECS205SPRITE PTR[esi]).fxptXCenter
	sub ecx, ebx

	mov (EECS205SPRITE PTR[esi]).fxptXCenter, ecx

	sar ecx, 16

	;cmp ecx,0
	;jg TrooperUpdated
	;mov (EECS205SPRITE PTR[esi]).active,0

	TrooperUpdated:

	ret
TrooperPositionUpdate ENDP

ResetSaberPos PROC USES esi ebx ecx ptrSprite:PTR EECS205SPRITE 	;;reset saber position to wherever vader sprite is
	mov esi, ptrSprite

	mov ebx, VaderXPos
	mov ecx, VaderYPos

	sar ebx, 16
	sar ecx, 16

	add ebx, 5
	sub ecx, 26

	mov SaberX, ebx
	mov SaberY, ecx

	sal ebx, 16
	sal ecx, 16

	mov (EECS205SPRITE PTR [esi]).fxptXCenter, ebx
	mov (EECS205SPRITE PTR [esi]).fxptYCenter, ecx

	mov (EECS205SPRITE PTR [esi]).active, 0

	ret

ResetSaberPos ENDP

UpdateSaberPos PROC ptrSprite:PTR EECS205SPRITE					;;update saber position if active at current velocity, check for collision and then reset

	mov esi, ptrSprite

	mov ebx, 20			
	sal ebx, 16

	mov ecx, (EECS205SPRITE PTR[esi]).fxptXCenter
	add ecx, ebx

	mov (EECS205SPRITE PTR[esi]).fxptXCenter, ecx

	cmp Saber_Collision,1
	jne SaberUpdate
	invoke ResetSaberPos,ptrSprite
	mov Saber_Collision,0

	mov ebx, 640
	sal ebx, 16

	SaberUpdate:

	ret
UpdateSaberPos ENDP


ThrowLightsaber PROC USES esi ebx ecx edx edi ptrSprite:PTR EECS205SPRITE, ptrVader: PTR EECS205SPRITE		;;throw lightsaber if space pressed, make saber active
	
	mov esi, ptrSprite
	mov edi, ptrVader

	mov ebx, KeyPress

	cmp ebx, VK_SPACE
	jne FINISHED

	mov ebx, (EECS205SPRITE PTR [edi]).fxptXCenter
	mov ecx, (EECS205SPRITE PTR [edi]).fxptYCenter

	sar ebx, 16
	sar ecx, 16

	add ebx, 5
	sub ecx, 26

	sal ebx, 16
	sal ecx, 16

	mov (EECS205SPRITE PTR [esi]).fxptXCenter, ebx
	mov (EECS205SPRITE PTR [esi]).fxptYCenter, ecx

	sar ebx, 16
	sar ecx, 16

	mov edx,(EECS205SPRITE PTR[esi]).ptrBitmap

	mov (EECS205SPRITE PTR[esi]).active, 1


	FINISHED:
	ret
ThrowLightsaber ENDP


END
