;Variables
PUBLIC  GRAPHICS_TEMP_W0, GRAPHICS_TEMP_W1, GRAPHICS_TEMP_W2, GRAPHICS_TEMP_W3, GRAPHICS_TEMP_W4, GRAPHICS_TEMP_X, GRAPHICS_TEMP_X1, GRAPHICS_TEMP_Y, GRAPHICS_TEMP_Y1, GRAPHICS_TEMP_WIDTH, GRAPHICS_TEMP_HEIGHT, GRAPHICS_TEMP_B0
;Functions
PUBLIC  int_DrawImage , int_DrawImageTented , int_DrawRect , int_ClearScreen , int_SwapBuffer , int_SwapRect

.MODEL LARGE
.STACK 64
.DATA

GRAPHICS_TEMP_W0         DW 0000h       
GRAPHICS_TEMP_W1         DW 0000h       ;temp variables I use sometimes (and by sometimes I mean never xD)
GRAPHICS_TEMP_W2         DW 0000h
GRAPHICS_TEMP_W3         DW 0000h
GRAPHICS_TEMP_W4         DW 0000h

GRAPHICS_TEMP_X          DW 0000h       ;used to denote the current X postiton in the current draw call
GRAPHICS_TEMP_X1         DW 0000h       ;currently not used but may use it in the futur
GRAPHICS_TEMP_Y          DW 0000h       ;used to denote the current Y postiton in the current draw call
GRAPHICS_TEMP_Y1         DW 0000h       ;currently not used but may use it in the futur

GRAPHICS_TEMP_WIDTH      DW 0000h       ;used to denote the current Width in the current draw call
GRAPHICS_TEMP_HEIGHT     DW 0000h       ;used to denote the current Width in the current draw call

GRAPHICS_TEMP_B0         DB 0000h       ;currently not used but may use it in the futur


SCREEN_BUFFER SEGMENT ; dual buffering baby
SCREEN                  DB 64000 DUP(00h)
SCREEN_BUFFER ENDS


.CODE 

;draws the image passed by DrawImage macro
;draws the image row by row in the SCREEN_BUFFER by coping the pixels
;I wrote this code like 20 days ago so Im not 100% sure how it works tbh xD
int_DrawImage PROC FAR
        mov ax, SCREEN_BUFFER
        mov es, ax
        
        mov AX , 0
        mov DI , 0
        add DI , GRAPHICS_TEMP_X
        mov CX , GRAPHICS_TEMP_Y
        cmp CX , 0

        jnz int_DrawImage_DI_LOP
    int_DrawImage_STEP0:
        mov CX , 320
        sub CX , GRAPHICS_TEMP_WIDTH
        mov GRAPHICS_TEMP_W0 , CX
        mov CX , 0
    int_DrawImage_img_row_loop:
        mov DH , [BX]
        cmp DH , 0ffh
        jz int_skip_pixel
        mov es:[DI] , DH
    int_skip_pixel:
        inc BX
        inc DI
        inc AX

        cmp AX , GRAPHICS_TEMP_WIDTH
        jz int_DrawImage_img_next_row
        jmp int_DrawImage_img_row_loop

    int_DrawImage_img_next_row:
        inc CX
        add DI , GRAPHICS_TEMP_W0
        mov AX , 0
        cmp CX , GRAPHICS_TEMP_HEIGHT
        jnz int_DrawImage_img_row_loop

        jmp int_DrawImage_EXIT

    int_DrawImage_DI_LOP:
        add DI,320
        dec CX
        jnz int_DrawImage_DI_LOP
        jmp int_DrawImage_STEP0

    int_DrawImage_EXIT  :
        ret
int_DrawImage ENDP

;draws the image passed by DrawImageTented macro
;draws the image row by row in the SCREEN_BUFFER by coping the pixels
int_DrawImageTented PROC FAR
        mov ax, SCREEN_BUFFER
        mov es, ax
        
        mov AX , 0
        mov DI , 0
        add DI , GRAPHICS_TEMP_X
        mov CX , GRAPHICS_TEMP_Y
        cmp CX , 0

        jnz int_DrawImageTented_DI_LOP
    int_DrawImageTented_STEP0:
        mov CX , 320
        sub CX , GRAPHICS_TEMP_WIDTH
        mov GRAPHICS_TEMP_W0 , CX
        mov CX , 0
    int_DrawImageTented_img_row_loop:
        mov DL , [BX]
        cmp DL , 0ffh
        jz int_DrawImageTented_skip_pixel
        mov es:[DI] , DH
    int_DrawImageTented_skip_pixel:
        inc BX
        inc DI
        inc AX

        cmp AX , GRAPHICS_TEMP_WIDTH
        jz int_DrawImageTented_img_next_row
        jmp int_DrawImageTented_img_row_loop

    int_DrawImageTented_img_next_row:
        inc CX
        add DI , GRAPHICS_TEMP_W0
        mov AX , 0
        cmp CX , GRAPHICS_TEMP_HEIGHT
        jnz int_DrawImageTented_img_row_loop

        jmp int_DrawImageTented_EXIT

    int_DrawImageTented_DI_LOP:
        add DI,320
        dec CX
        jnz int_DrawImageTented_DI_LOP
        jmp int_DrawImageTented_STEP0

    int_DrawImageTented_EXIT  :
        ret
int_DrawImageTented ENDP

;just like drawing an image , the only difference is that the pixel color is fixed
int_DrawRect PROC FAR
        mov ax, SCREEN_BUFFER
        mov es, ax
        
        mov AX , 0
        mov DI , 0
        add DI , GRAPHICS_TEMP_X
        mov CX , GRAPHICS_TEMP_Y
        
        cmp GRAPHICS_TEMP_HEIGHT , 1
        jl int_DrawRect_QuickExit
        cmp GRAPHICS_TEMP_WIDTH , 1
        jl int_DrawRect_QuickExit
        
        jmp int_DrawRect_QuickExit_Skip
    int_DrawRect_QuickExit:
        ret
    int_DrawRect_QuickExit_Skip:

    ;    mov GRAPHICS_TEMP_X1 , DI ; was implementing a way to prevent overflow in the image drawing
                                   ; but its just pain and can be avoided easly ..
    ;    mov GRAPHICS_TEMP_Y1 , CX
        
        cmp CX , 0
        jnz int_DrawRect_DI_LOP

    int_DrawRect_STEP0:
        mov CX , 320
        sub CX , GRAPHICS_TEMP_WIDTH
        mov GRAPHICS_TEMP_W0 , CX
        mov CX , 0
    int_DrawRect_img_row_loop:
        
        ;cmp GRAPHICS_TEMP_X1 , 321
        ;jns int_DrawRect_skip_pixel
        ;cmp GRAPHICS_TEMP_Y1 , 201
        ;jns int_DrawRect_skip_pixel

        mov es:[DI] , DH
    ;int_DrawRect_skip_pixel:
        inc DI
        inc AX
        
    ;    inc GRAPHICS_TEMP_X1

        cmp AX , GRAPHICS_TEMP_WIDTH
        jnz int_DrawRect_img_row_loop
    ;    inc GRAPHICS_TEMP_Y1
    ;    mov AX , GRAPHICS_TEMP_X
    ;    mov GRAPHICS_TEMP_X1 , AX

        inc CX
        add DI , GRAPHICS_TEMP_W0
        mov AX , 0
        cmp CX , GRAPHICS_TEMP_HEIGHT
        jnz int_DrawRect_img_row_loop

        jmp int_DrawRect_EXIT

    int_DrawRect_DI_LOP:
        add DI,320
        dec CX
        jnz int_DrawRect_DI_LOP
        jmp int_DrawRect_STEP0

    int_DrawRect_EXIT  :
        ret
int_DrawRect ENDP

;Update the screen with the current buffer
;works as a memcopy
int_SwapBuffer PROC FAR
        mov cx, 64000 ;number of iterations
        mov DI, 0
        
        mov AX , 0A000h
        mov ds , AX
        
        mov AX , SCREEN_BUFFER
        mov es , AX
        
    int_SwapBuffer_LOOP:
        mov bl , es:[DI]
        mov ds:[DI] , bl
        inc DI
    loop int_SwapBuffer_LOOP
    
        mov AX , @Data
        mov ds , AX
        ret
int_SwapBuffer ENDP

;clears the current screen buffer
int_ClearScreen PROC FAR
    mov ax, SCREEN_BUFFER
    mov es, ax

    mov DI, 0
    mov cx, 64000 ;number of iterations
    int_ClearScreen_LOOP:
        mov ES:[DI] , DL
        inc DI
        dec cx
        jnz int_ClearScreen_LOOP
    ret
    
int_ClearScreen ENDP


int_SwapRect PROC FAR
        
        mov AX , 0
        mov DI , 0
        add DI , GRAPHICS_TEMP_X
        mov CX , GRAPHICS_TEMP_Y
        cmp CX , 0

        jnz int_SwapRect_DI_LOP
    int_SwapRect_STEP0:
        mov CX , 320
        sub CX , GRAPHICS_TEMP_WIDTH
        mov GRAPHICS_TEMP_W0 , CX
        mov CX , 0
    int_SwapRect_img_row_loop:
        mov BX , SCREEN_BUFFER
        mov es , BX
        mov DH , es:[DI]

        mov BX , 0A000h
        mov es , BX
        mov es:[DI] , DH
    
        inc DI
        inc AX

        cmp AX , GRAPHICS_TEMP_WIDTH
        jz int_SwapRect_img_next_row
        jmp int_SwapRect_img_row_loop

    int_SwapRect_img_next_row:
        inc CX
        add DI , GRAPHICS_TEMP_W0
        mov AX , 0
        cmp CX , GRAPHICS_TEMP_HEIGHT
        jnz int_SwapRect_img_row_loop

        jmp int_SwapRect_EXIT

    int_SwapRect_DI_LOP:
        add DI,320
        dec CX
        jnz int_SwapRect_DI_LOP
        jmp int_SwapRect_STEP0

    int_SwapRect_EXIT  :
        ret
int_SwapRect ENDP


END ;GRAPHICS_TEST