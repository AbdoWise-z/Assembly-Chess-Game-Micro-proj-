;an interface for graphics.asm , I dont really think I should explain any of the code here , it just copies variables
; 'image' --> buffer of the image
; 'x'     --> x postition on screen
; 'y'     --> y postition on screen
; 'w'     --> the width of the image
; 'h'     --> the height of the image
DrawImage MACRO image, x , y , w , h
    mov BX , OFFSET image
    
    mov AX , x
    mov GRAPHICS_TEMP_X , AX
    
    mov AX , y
    mov GRAPHICS_TEMP_Y , AX
    
    mov AX  , w
    mov GRAPHICS_TEMP_WIDTH , AX
    
    mov AX  , h
    mov GRAPHICS_TEMP_HEIGHT , AX
    
    call int_DrawImage
ENDM

;draw an image but replaces every visable pixel with the color 'c'
; 'image' --> buffer of the image
; 'c'     --> tent color
; 'x'     --> x postition on screen
; 'y'     --> y postition on screen
; 'w'     --> the width of the image
; 'h'     --> the height of the image
DrawImageTented MACRO image , c , x , y , w , h
    mov BX , OFFSET image
    
    mov AX , x
    mov GRAPHICS_TEMP_X , AX
    
    mov AX , y
    mov GRAPHICS_TEMP_Y , AX
    
    mov AX  , w
    mov GRAPHICS_TEMP_WIDTH , AX
    
    mov AX  , h
    mov GRAPHICS_TEMP_HEIGHT , AX

    mov DH , c
    
    call int_DrawImageTented
ENDM


;draw an image but replaces every visable pixel with the color 'c'
; 'image' --> buffer of the image
; 'c'     --> tent color
; 'x'     --> x postition on screen
; 'y'     --> y postition on screen
; 'w'     --> the width of the image
; 'h'     --> the height of the image
DrawImageTentedImd MACRO image , c , x , y , w , h
    mov BX , image
    
    mov AX , x
    mov GRAPHICS_TEMP_X , AX
    
    mov AX , y
    mov GRAPHICS_TEMP_Y , AX
    
    mov AX  , w
    mov GRAPHICS_TEMP_WIDTH , AX
    
    mov AX  , h
    mov GRAPHICS_TEMP_HEIGHT , AX

    mov DH , c
    
    call int_DrawImageTented
ENDM

;draws image with direct address
; 'image' --> direct address to the image
; 'x'     --> x postition on screen
; 'y'     --> y postition on screen
; 'w'     --> the width of the image
; 'h'     --> the height of the image
DrawImageImd MACRO image, x , y , w , h
    mov BX , image
    
    mov AX , x
    mov GRAPHICS_TEMP_X , AX
    
    mov AX , y
    mov GRAPHICS_TEMP_Y , AX
    
    mov AX  , w
    mov GRAPHICS_TEMP_WIDTH , AX
    
    mov AX  , h
    mov GRAPHICS_TEMP_HEIGHT , AX
    
    call int_DrawImage
ENDM

; 'color' --> color of the rect (1 byte , see palette.png) 
; 'x'     --> x postition on screen
; 'y'     --> y postition on screen
; 'w'     --> the width of the image
; 'h'     --> the height of the image
DrawRect MACRO color , x , y , w , h
    
    mov AX , x
    mov GRAPHICS_TEMP_X , AX
    
    mov AX , y
    mov GRAPHICS_TEMP_Y , AX

    mov DH , color
    
    mov AX  , w
    mov GRAPHICS_TEMP_WIDTH , AX
    
    mov AX  , h
    mov GRAPHICS_TEMP_HEIGHT , AX
    
    call int_DrawRect
ENDM

; updates the current screen buffer
SwapBuffers MACRO
    call int_SwapBuffer
ENDM

SwapRect MACRO x , y , w , h
    
    mov AX , x
    mov GRAPHICS_TEMP_X , AX
    
    mov AX , y
    mov GRAPHICS_TEMP_Y , AX
    
    mov AX  , w
    mov GRAPHICS_TEMP_WIDTH , AX
    
    mov AX  , h
    mov GRAPHICS_TEMP_HEIGHT , AX
    
    call int_SwapRect
ENDM


; clears the screen buffer filling it with 'Clear_color'
; 'Clear_Color' --> the clear color (1 byte , see palette.png) 
ClearScreen MACRO Clear_Color
    mov DL , Clear_Color
    call int_ClearScreen
ENDM

EXTRN GRAPHICS_TEMP_W0:WORD
EXTRN GRAPHICS_TEMP_W1:WORD
EXTRN GRAPHICS_TEMP_W2:WORD
EXTRN GRAPHICS_TEMP_W3:WORD
EXTRN GRAPHICS_TEMP_W4:WORD
EXTRN GRAPHICS_TEMP_X:WORD
EXTRN GRAPHICS_TEMP_Y:WORD
EXTRN GRAPHICS_TEMP_X1:WORD
EXTRN GRAPHICS_TEMP_Y1:WORD
EXTRN GRAPHICS_TEMP_WIDTH:WORD
EXTRN GRAPHICS_TEMP_HEIGHT:WORD
EXTRN GRAPHICS_TEMP_B0:BYTE

EXTRN int_DrawImage:FAR
EXTRN int_DrawImageTented:FAR
EXTRN int_DrawRect:FAR
EXTRN int_SwapBuffer:FAR
EXTRN int_SwapRect:FAR
EXTRN int_ClearScreen:FAR



