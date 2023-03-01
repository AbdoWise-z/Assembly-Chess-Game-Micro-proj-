;useless .. but keep it for now

ShowMouse MACRO
    mov ax , 1
    int 33h
ENDM

HideMouse MACRO
    mov ax , 2
    int 33h
ENDM


AddKeyHandler MACRO key_scan , func
    mov CH , key_scan
    mov CURRENT_KEY_SCAN_CODE , CH

    mov ax , OFFSET func
    mov cx , cs
    mov CURRENT_FUNC_A0 , AL
    mov CURRENT_FUNC_A1 , AH
    mov CURRENT_FUNC_A2 , CL
    mov CURRENT_FUNC_A3 , CH

    call int_add_key_handler

ENDM

AddGlobalKeyHandler MACRO func
    mov ax , OFFSET func
    mov cx , cs
    mov CURRENT_FUNC_A0 , AL
    mov CURRENT_FUNC_A1 , AH
    mov CURRENT_FUNC_A2 , CL
    mov CURRENT_FUNC_A3 , CH

    call int_add_global_key_handler
ENDM

UpdateInputs MACRO
    call int_update_inputs
ENDM

ClearAllInputHandlers MACRO
    mov KEY_HANDERLS_LIST_SIZE , 0
    mov GLOBAL_HANDERLS_LIST_SIZE , 0
    mov CANCEL_EVENT , 1 ; if we cleared then this event is canseled to prevent any errors 
ENDM

EXTRN int_fire_key_event:FAR
EXTRN int_add_key_handler:FAR
EXTRN int_add_global_key_handler:FAR
EXTRN int_update_inputs:FAR

EXTRN CURRENT_KEY_ASCII:BYTE
EXTRN CANCEL_EVENT:BYTE
EXTRN CURRENT_KEY_SCAN_CODE:BYTE 
EXTRN CURRENT_FUNC_A0:BYTE 
EXTRN CURRENT_FUNC_A1:BYTE 
EXTRN CURRENT_FUNC_A2:BYTE 
EXTRN CURRENT_FUNC_A3:BYTE 
EXTRN KEY_HANDERLS_LIST_SIZE:WORD 
EXTRN GLOBAL_HANDERLS_LIST_SIZE:WORD 