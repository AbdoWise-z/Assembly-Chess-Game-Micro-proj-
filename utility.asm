
;Variables
PUBLIC UTILITY_SRC_BUFFER , UTILITY_SRC_BUFFER_SIZE , UTILITY_DST_BUFFER , UTILITY_DST_BUFFER_SIZE , UTILITY_NUMBER , UTILITY_BASE , UTILITY_SIZE , UTILITY_TEMP
;Functions
PUBLIC int_print , int_str_2_int , int_int_2_str


.MODEL LARGE
.STACK 1024 ;this class uses stack in some function
.DATA

;these temperory variables are used as bridges to carry input/outputs

UTILITY_SRC_BUFFER          dw 0000h    ;input source buffer
UTILITY_SRC_BUFFER_SIZE     dw 0000h    ;input source buffer size

UTILITY_DST_BUFFER          dw 0000h    ;output distination buffer
UTILITY_DST_BUFFER_SIZE     dw 0000h    ;output distination buffer size

UTILITY_NUMBER              dw 0000h    ;current input/output number
UTILITY_SIZE                dw 0000h    ;current operation/function return size

UTILITY_BASE                dw 0000h    ;current operation base parameter
UTILITY_TEMP                dw 0000h    ;temperory variable used a register


utarget                      dd 00000000h

.CODE

;truns out this function is useless, I though this will output to the console but it doesn't :')
;prints the contents of UTILITY_SRC_BUFFER to the console
int_print PROC FAR
        mov ah, 2 
        mov DI , UTILITY_SRC_BUFFER
    int_print_lop:
        mov dl, [DI]
        inc DI
        cmp dl , '$'
        jz int_print_exit
        int 21h 
        jmp int_print_lop
    int_print_exit:
        ret
int_print ENDP

;converts a string to int , considering that string haveing a base of UTILITY_BASE
int_str_2_int PROC FAR
        mov BX , UTILITY_SRC_BUFFER
        add BX , UTILITY_SRC_BUFFER_SIZE
        dec BX

        mov cx, UTILITY_SRC_BUFFER_SIZE ;number of iterations
        mov UTILITY_TEMP , 1
        mov UTILITY_NUMBER , 0
    int_str_2_int_loop:
        mov al , [BX]
        sub al , '0'
        mov ah , 0
        mul UTILITY_TEMP
        add UTILITY_NUMBER , ax
        
        mov ax , UTILITY_BASE
        mul UTILITY_TEMP
        mov UTILITY_TEMP , ax
        dec bx
    loop int_str_2_int_loop
        ret

int_str_2_int ENDP
 
;convert an int to a str with 'x' base , (used in displaying numbers on screen etc.)
int_int_2_str PROC FAR
        mov AX , UTILITY_NUMBER
        mov UTILITY_SIZE , 0

    int_int_2_str_lop:
        
        mov DX , UTILITY_SIZE               ;check if buffer cant handel this
        cmp DX , UTILITY_DST_BUFFER_SIZE
        jz int_int_2_str_lop_exit

        mov DX , 0
        DIV UTILITY_BASE
        push DX
        inc UTILITY_SIZE
        cmp AX , 0
        jnz int_int_2_str_lop
    int_int_2_str_lop_exit:
        mov bx , UTILITY_DST_BUFFER
        mov CX , UTILITY_SIZE
    int_int_2_str_lop_2:
        pop DX
        add DL , '0'
        mov [BX] , DL
        inc BX
    loop int_int_2_str_lop_2
        ret
int_int_2_str ENDP

END