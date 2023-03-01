
;sleeps for the given amount of ms
Sleep MACRO time
        local LOOPER , _skip_add
        mov AH , 86h
        mov DX , 0000h
        mov CX , 0000h
        mov BX , 1000
    LOOPER:
        dec BX
        add DX , time
        jnc _skip_add
        inc CX
    _skip_add:
        cmp BX , 0
        jnz LOOPER
        int 15h
ENDM

;uses ax
;supports 8-bit values
;gets the bit number 'bit' from '_in' and stores the result in the first bit of '_out'
;ex: _in = 01001000B , bit = 3 --> _out = 1
;              ^
;    _in = 01001000B , bit = 2 --> _out = 0
;               ^
getBit8 MACRO _in , _out , bit
        LOCAL __tc
        mov cl , bit
        mov ah , _in
        mov _out , 1
        and _out , ah
        cmp cl , 0
        jz __tc
        mov _out , 1
        SHR ah , cl
        and  _out , ah
    __tc:

ENDM

;moves b to a using AX as a bridge
mov16 MACRO a , b
    mov ax , b
    mov a , ax
ENDM

mov8 MACRO a , b
    mov ah , b
    mov a , ah
ENDM

sub16 MACRO a , b
    mov ax , b
    sub a , ax
ENDM

sub8 MACRO a , b
    mov ah , b
    sub a , ah
ENDM 

add16 MACRO a , b
    mov ax , b
    add a , ax
ENDM

add8 MACRO a , b
    mov ah , b
    add a , ah
ENDM 

cmp16 MACRO a , b
    mov ax , b
    cmp a , ax
ENDM

cmp8 MACRO a , b
    mov ah , b
    cmp a , ah
ENDM


;just as the name says , 's' is the size of the buffer
MemSet MACRO buff , s , data
            LOCAL s_lop
    mov ah , data
    mov cx , s
    mov BX , OFFSET buff
    s_lop:
    mov ds:[BX] , ah
    inc BX
    dec cx
    jnz s_lop

ENDM

; 'buff'     --> output result buffer
; 'bs"       --> max buffer size
; 'out_size' --> number of char that are used in the buffer after converting
; 'out_base' --> what base do you want the output to be
; 'num'      --> input number
Int2String MACRO buff , bs , out_size , out_base , num 
    mov16 UTILITY_BASE , out_base
    mov16 UTILITY_DST_BUFFER_SIZE , bs
    mov AX , OFFSET buff
    mov UTILITY_DST_BUFFER , AX
    mov16 UTILITY_NUMBER , num
    
    call int_int_2_str

    mov16 out_size , UTILITY_SIZE
ENDM

; same as the one above it , I just dont use OFFSET before the buffer to allow direct address input
Int2StringDirect MACRO buff , bs , out_size , out_base , num 
    mov16 UTILITY_BASE , out_base
    mov16 UTILITY_DST_BUFFER_SIZE , bs
    mov AX , buff
    mov UTILITY_DST_BUFFER , AX
    mov16 UTILITY_NUMBER , num
    
    call int_int_2_str

    mov16 out_size , UTILITY_SIZE
ENDM

;OLD , use DispString instead for better performance 
Print MACRO buff
    mov bx , offset buff
    mov UTILITY_SRC_BUFFER , bx
    call int_print
ENDM

; 'buff'     --> number input buffer
; 'bs"       --> buffer size
; 'out_num'  --> result will be stored in this (word)
; 'base'     --> read for what base ?
String2Int MACRO buff , bs , out_num , base
    mov16 UTILITY_BASE , base
    mov16 UTILITY_SRC_BUFFER_SIZE , bs
    mov AX , OFFSET buff
    mov UTILITY_SRC_BUFFER , AX
    
    call int_str_2_int

    mov16 out_num , UTILITY_NUMBER

ENDM 

; same as the one above it , I just dont use OFFSET before the buffer to allow direct address input
String2IntDirect MACRO buff , bs , out_num , base
    mov16 UTILITY_BASE , base
    mov16 UTILITY_SRC_BUFFER_SIZE , bs
    mov AX , buff
    mov UTILITY_SRC_BUFFER , AX
    
    call int_str_2_int

    mov16 out_num , UTILITY_NUMBER
ENDM 

;reads string from input and stores it in str buffer
ReadString MACRO str
    MOV AH,0AH
    MOV DX,OFFSET str
    INT 21H
ENDM

;displays a string to the curret cursor location (str should end with '$')
DispString MACRO str
    MOV AH,09H
    MOV DX,OFFSET str
    INT 21H
ENDM

DispStringImd MACRO str
    MOV AH , 09H
    MOV DX , str
    INT 21H
ENDM

;set the cursor location (row , column)
SetCursor MACRO r,c
    mov dh, r          ; set cursor position
    mov dl, c         
    mov bh, 0
    mov ah, 2
    int 10h                        
ENDM

;clear screen
CLS MACRO
    mov ax,0003h ; create screen
    int 10h
ENDM


;stuff used in linking ...
EXTRN UTILITY_SRC_BUFFER:WORD
EXTRN UTILITY_SRC_BUFFER_SIZE:WORD
EXTRN UTILITY_DST_BUFFER:WORD
EXTRN UTILITY_DST_BUFFER_SIZE:WORD
EXTRN UTILITY_NUMBER:WORD
EXTRN UTILITY_BASE:WORD
EXTRN UTILITY_SIZE:WORD
EXTRN UTILITY_TEMP:WORD

EXTRN int_print:FAR
EXTRN int_str_2_int:FAR
EXTRN int_int_2_str:FAR