PUBLIC int_fire_key_event , int_add_key_handler , int_update_inputs , int_add_global_key_handler

PUBLIC CURRENT_KEY_ASCII , CURRENT_KEY_SCAN_CODE , CURRENT_FUNC_A0 , CURRENT_FUNC_A1 , CURRENT_FUNC_A2 , CURRENT_FUNC_A3 , KEY_HANDERLS_LIST_SIZE , GLOBAL_HANDERLS_LIST_SIZE , CANCEL_EVENT

.MODEL LARGE
.STACK 1024

.DATA

Target                     dd 00000000h

KEY_HANDERLS_LIST          db 100 DUP( 00h , 00h , 00h , 00h , 00h)
KEY_HANDERLS_LIST_SIZE     dw 0
KEY_HANDERLS_COUNTER       dw 0 ;real counter
KEY_HANDERLS_OCOUNTER      dw 0 ;offset counter

GLOBAL_HANDERLS_LIST       db 20 DUP( 00h , 00h , 00h , 00h)
GLOBAL_HANDERLS_LIST_SIZE  dw 0

CANCEL_EVENT               db 0

CURRENT_KEY_ASCII         db 00h
CURRENT_KEY_SCAN_CODE     db 00h

CURRENT_FUNC_A0 db 00h
CURRENT_FUNC_A1 db 00h
CURRENT_FUNC_A2 db 00h
CURRENT_FUNC_A3 db 00h

.CODE


int_fire_key_event PROC FAR
        mov KEY_HANDERLS_COUNTER , 0
        mov KEY_HANDERLS_OCOUNTER , 0 
    int_fire_key_global_looper:
        cmp CANCEL_EVENT , 1
        je int_fire_key_event_looper_pre
        mov AX , KEY_HANDERLS_COUNTER
        cmp AX , GLOBAL_HANDERLS_LIST_SIZE
        jg int_fire_key_event_looper_pre
        je int_fire_key_event_looper_pre
        
        mov BX , OFFSET GLOBAL_HANDERLS_LIST
        add BX , KEY_HANDERLS_OCOUNTER
        inc KEY_HANDERLS_COUNTER
        add KEY_HANDERLS_OCOUNTER , 4
        
        mov DI , OFFSET Target
        mov AH , [BX]   ;copy the call address
        mov [DI] , AH

        inc BX
        inc DI
        mov AH , [BX]
        mov [DI] , AH

        inc BX
        inc DI
        mov AH , [BX]
        mov [DI] , AH

        inc BX
        inc DI
        mov AH , [BX]
        mov [DI] , AH

        call Target
        jmp int_fire_key_global_looper

    int_fire_key_event_looper_pre:
        mov KEY_HANDERLS_COUNTER , 0
        mov KEY_HANDERLS_OCOUNTER , 0 
    int_fire_key_event_looper:
        ;DrawRect CURRENT_KEY_ASCII , 200 , 140 , 12 , 12 ;debugging ..
        cmp CANCEL_EVENT , 1
        je int_fire_key_event_exit
        mov AX , KEY_HANDERLS_COUNTER
        cmp AX , KEY_HANDERLS_LIST_SIZE
        jg int_fire_key_event_exit
        je int_fire_key_event_exit
        
        mov BX , OFFSET KEY_HANDERLS_LIST
        add BX , KEY_HANDERLS_OCOUNTER
        inc KEY_HANDERLS_COUNTER
        add KEY_HANDERLS_OCOUNTER , 5

        mov CH , CURRENT_KEY_SCAN_CODE
        cmp [BX] , CH
        jne int_fire_key_event_looper
        
        mov DI , OFFSET Target
        inc BX
        mov AH , [BX]   ;copy the call address
        mov [DI] , AH

        inc BX
        inc DI
        mov AH , [BX]
        mov [DI] , AH

        inc BX
        inc DI
        mov AH , [BX]
        mov [DI] , AH

        inc BX
        inc DI
        mov AH , [BX]
        mov [DI] , AH

        call Target
        jmp int_fire_key_event_looper
    int_fire_key_event_exit:
        ret
int_fire_key_event ENDP

int_add_key_handler PROC FAR
    mov ax , 5
    mov bx , KEY_HANDERLS_LIST_SIZE
    mul bx
    mov BX , OFFSET KEY_HANDERLS_LIST
    add BX , AX
    mov CH , CURRENT_KEY_SCAN_CODE
    mov [BX] , CH
    inc BX
    mov CH , CURRENT_FUNC_A0
    mov [BX] , CH
    inc BX
    mov CH , CURRENT_FUNC_A1
    mov [BX] , CH
    inc BX
    mov CH , CURRENT_FUNC_A2
    mov [BX] , CH
    inc BX
    mov CH , CURRENT_FUNC_A3
    mov [BX] , CH
    inc KEY_HANDERLS_LIST_SIZE
    ret
int_add_key_handler ENDP

int_add_global_key_handler PROC
    mov ax , 4
    mov bx , GLOBAL_HANDERLS_LIST_SIZE
    mul bx
    mov BX , OFFSET GLOBAL_HANDERLS_LIST
    add BX , AX
    mov CH , CURRENT_FUNC_A0
    mov [BX] , CH
    inc BX
    mov CH , CURRENT_FUNC_A1
    mov [BX] , CH
    inc BX
    mov CH , CURRENT_FUNC_A2
    mov [BX] , CH
    inc BX
    mov CH , CURRENT_FUNC_A3
    mov [BX] , CH
    inc GLOBAL_HANDERLS_LIST_SIZE
    ret
int_add_global_key_handler ENDP

int_update_inputs PROC FAR
        ;DrawRect 0fh , 200 , 140 , 24 , 24 ;debugging
        mov CANCEL_EVENT , 0
        mov CURRENT_KEY_ASCII , 00h
        mov CURRENT_KEY_SCAN_CODE , 00h
    int_inputs_update_check_key_events:
        mov ah , 1
        int 16h
        jz int_inputs_update_check_key_events_finish
        mov ah , 0
        int 16h
        mov CURRENT_KEY_ASCII , AL
        mov CURRENT_KEY_SCAN_CODE , AH
        call int_fire_key_event
    int_inputs_update_check_key_events_finish:
        ret
int_update_inputs ENDP

END