PUBLIC NETWORK_IN_CFG , NETWORK_IN_BAUD_RATE , N_CURRENT_FUNC_A0 , N_CURRENT_FUNC_A1 , N_CURRENT_FUNC_A2 , N_CURRENT_FUNC_A3 , N_CURRENT_BYTE , NETWORK_OUT_BYTE , NETWORK_OUT_BYTE_SIZE
PUBLIC NETWORK_GLOBAL_HANDLERS_LIST_SIZE , NETWORK_BYTE_HANDLERS_LIST_SIZE , NETWORK_CANCEL_EVENT

PUBLIC int_configure_port , int_add_network_handler , int_add_global_network_handler , int_fire_byte_event
PUBLIC int_flush_buffer , int_flush_one_byte , int_update_network

.MODEL LARGE
.DATA

NETWORK_BYTE_HANDLERS_LIST          db 100 DUP( 00h , 00h , 00h , 00h , 00h)
NETWORK_BYTE_HANDLERS_LIST_SIZE     dw 0
NETWORK_COUNTER                     dw 0 ;real counter
NETWORK_OCOUNTER                    dw 0 ;offset counter

NETWORK_GLOBAL_HANDLERS_LIST        db 20 DUP( 00h , 00h , 00h , 00h)
NETWORK_GLOBAL_HANDLERS_LIST_SIZE   dw 0

NETWORK_CANCEL_EVENT                db 0

OUT_BYTE                            db 0
NETWORK_OUT_BYTE                    db 200 DUP(00h) ;byte send queue
NETWORK_OUT_BYTE_SIZE               dw 0
NETWORK_FUNCTION_RESULT             db 0
NETWORK_ERROR_CYCLES                dw 0 ;for how many cycles have we been getting overrun erro ?

NETWORK_IN_CFG                      db 0
NETWORK_IN_BAUD_RATE                dw 0

N_CURRENT_FUNC_A0 db 00h
N_CURRENT_FUNC_A1 db 00h
N_CURRENT_FUNC_A2 db 00h
N_CURRENT_FUNC_A3 db 00h
N_CURRENT_BYTE    db 00h


nTarget                     dd 00000000h

.CODE

int_configure_port PROC
    mov dx , 3fbh ; Line Control Register
    mov al , 10000000b ;Set Divisor Latch Access Bit
    out dx , al ;Out it

    mov ax , NETWORK_IN_BAUD_RATE
    mov dx , 3f8h
    out dx , al
    mov dx , 3f9h
    SHR ax , 8
    out dx , al

    mov dx , 3fbh
    mov al , NETWORK_IN_CFG
    out dx , al

    ret
int_configure_port ENDP


int_fire_byte_event PROC FAR
        mov NETWORK_COUNTER , 0
        mov NETWORK_OCOUNTER , 0 
    int_fire_byte_global_looper:
        cmp NETWORK_CANCEL_EVENT , 1
        je int_fire_byte_event_looper_pre
        mov AX , NETWORK_COUNTER
        cmp AX , NETWORK_GLOBAL_HANDLERS_LIST_SIZE
        jg int_fire_byte_event_looper_pre
        je int_fire_byte_event_looper_pre
        
        mov BX , OFFSET NETWORK_GLOBAL_HANDLERS_LIST
        add BX , NETWORK_OCOUNTER
        inc NETWORK_COUNTER
        add NETWORK_OCOUNTER , 4
        
        mov DI , OFFSET nTarget
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

        call nTarget
        jmp int_fire_byte_global_looper

    int_fire_byte_event_looper_pre:
        mov NETWORK_COUNTER , 0
        mov NETWORK_OCOUNTER , 0 
    int_fire_byte_event_looper:
        cmp NETWORK_CANCEL_EVENT , 1
        je int_fire_byte_event_exit
        mov AX , NETWORK_COUNTER
        cmp AX , NETWORK_BYTE_HANDLERS_LIST_SIZE
        jg int_fire_byte_event_exit
        je int_fire_byte_event_exit
        
        mov BX , OFFSET NETWORK_BYTE_HANDLERS_LIST
        add BX , NETWORK_OCOUNTER
        inc NETWORK_COUNTER
        add NETWORK_OCOUNTER , 5

        mov CH , N_CURRENT_BYTE
        cmp [BX] , CH
        jne int_fire_byte_event_looper
        
        mov DI , OFFSET nTarget
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

        call nTarget
        jmp int_fire_byte_event_looper
    int_fire_byte_event_exit:
        ret
int_fire_byte_event ENDP

int_add_network_handler PROC FAR
    mov ax , 5
    mov bx , NETWORK_BYTE_HANDLERS_LIST_SIZE
    mul bx
    mov BX , OFFSET NETWORK_BYTE_HANDLERS_LIST
    add BX , AX

    mov CH , N_CURRENT_BYTE
    mov [BX] , CH
    inc BX
    mov CH , N_CURRENT_FUNC_A0
    mov [BX] , CH
    inc BX
    mov CH , N_CURRENT_FUNC_A1
    mov [BX] , CH
    inc BX
    mov CH , N_CURRENT_FUNC_A2
    mov [BX] , CH
    inc BX
    mov CH , N_CURRENT_FUNC_A3
    mov [BX] , CH
    inc NETWORK_BYTE_HANDLERS_LIST_SIZE
    ret
int_add_network_handler ENDP

int_add_global_network_handler PROC FAR
    mov ax , 4
    mov bx , NETWORK_GLOBAL_HANDLERS_LIST_SIZE
    mul bx
    mov BX , OFFSET NETWORK_GLOBAL_HANDLERS_LIST
    add BX , AX

    mov CH , N_CURRENT_FUNC_A0
    mov [BX] , CH
    inc BX
    mov CH , N_CURRENT_FUNC_A1
    mov [BX] , CH
    inc BX
    mov CH , N_CURRENT_FUNC_A2
    mov [BX] , CH
    inc BX
    mov CH , N_CURRENT_FUNC_A3
    mov [BX] , CH
    inc NETWORK_GLOBAL_HANDLERS_LIST_SIZE
    ret
int_add_global_network_handler ENDP


int_send_byte PROC
        mov dx , 3FDH ; Line Status Register
    int_send_byte_wait:
        In al , dx ;Read Line Status
        AND al , 00100000b
        JZ int_send_byte_wait
        mov dx , 3F8H ; Transmit data register
        mov al , OUT_BYTE
        out dx , al

        mov dx , 3FDH ; Line Status Register
        In al , dx ;Read Line Status
        AND al , 00000010b
        SHR al , 1
        xor al , 1
        mov NETWORK_FUNCTION_RESULT , al
        ret
int_send_byte ENDP

int_flush_buffer PROC
        mov NETWORK_COUNTER , -1
    int_flush_buffer_next:
        inc NETWORK_COUNTER
        mov ax , NETWORK_COUNTER
        cmp ax , NETWORK_OUT_BYTE_SIZE
        je int_flush_buffer_exit
        mov bx , OFFSET NETWORK_OUT_BYTE
        add bx , NETWORK_COUNTER
        mov ah , [BX]
        mov OUT_BYTE , ah
        call int_send_byte
        cmp NETWORK_FUNCTION_RESULT , 1
        je int_flush_buffer_next
        inc NETWORK_ERROR_CYCLES
    int_flush_buffer_exit:
        ;shift the data in the NETWORK_OUT_BYTE
        mov ax , NETWORK_OUT_BYTE_SIZE
        sub ax , NETWORK_COUNTER
        mov NETWORK_OUT_BYTE_SIZE , ax
        mov dx , ax
        mov ax , 0
    int_flush_buffer_shfit_next:
        cmp ax , dx
        je int_flush_buffer_final
        mov bx , OFFSET NETWORK_OUT_BYTE
        add bx , ax
        add bx , NETWORK_COUNTER
        mov ch , [bx]
        sub bx , NETWORK_COUNTER 
        mov [bx] , ch
        inc ax
        jmp int_flush_buffer_shfit_next
    int_flush_buffer_final:
        ret
int_flush_buffer ENDP


int_flush_one_byte PROC
        mov NETWORK_COUNTER , -1
    int_flush_one_byte_next:
        inc NETWORK_COUNTER
        mov ax , NETWORK_COUNTER
        cmp ax , NETWORK_OUT_BYTE_SIZE
        je int_flush_one_byte_exit
        cmp ax , 1
        je int_flush_one_byte_exit
        mov bx , OFFSET NETWORK_OUT_BYTE
        add bx , NETWORK_COUNTER
        mov ah , [BX]
        mov OUT_BYTE , ah
        call int_send_byte
        cmp NETWORK_FUNCTION_RESULT , 1
        je int_flush_one_byte_next
        inc NETWORK_ERROR_CYCLES
    int_flush_one_byte_exit:
        ;shift the data in the NETWORK_OUT_BYTE
        mov ax , NETWORK_OUT_BYTE_SIZE
        sub ax , NETWORK_COUNTER
        mov NETWORK_OUT_BYTE_SIZE , ax
        mov dx , ax
        mov ax , 0
    int_flush_one_byte_shfit_next:
        cmp ax , dx
        je int_flush_one_byte_final
        mov bx , OFFSET NETWORK_OUT_BYTE
        add bx , ax
        add bx , NETWORK_COUNTER
        mov ch , [bx]
        sub bx , NETWORK_COUNTER 
        mov [bx] , ch
        inc ax
        jmp int_flush_one_byte_shfit_next
    int_flush_one_byte_final:
        ret
int_flush_one_byte ENDP


int_read_byte PROC    
        mov dx , 3FDH ; Line Status Register
        in al , dx
        AND al , 1
        JZ int_read_byte_SET_ERROR
        mov dx , 03F8H
        in al , dx
        mov N_CURRENT_BYTE , AL
        mov NETWORK_FUNCTION_RESULT , 1
        ret
    int_read_byte_SET_ERROR:
        mov NETWORK_FUNCTION_RESULT , 0
        ret
int_read_byte ENDP

int_update_network PROC
    int_update_network_loop:
        call int_read_byte
        cmp NETWORK_FUNCTION_RESULT , 1
        jne int_update_network_loop_exit
        mov NETWORK_CANCEL_EVENT , 0
        call int_fire_byte_event
        jmp int_update_network_loop
    int_update_network_loop_exit:
        ret
int_update_network ENDP

END