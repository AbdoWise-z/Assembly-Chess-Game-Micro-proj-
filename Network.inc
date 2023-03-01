;[baud_rate] buad_rate cfg (word) , [3F9-3F8]
;[port_cfg]  port opitions , pit 7 should always be 0
ConfigurePort1 MACRO baud_rate , port_cfg
    mov NETWORK_IN_CFG , port_cfg
    mov NETWORK_IN_BAUD_RATE , baud_rate
    call int_configure_port
ENDM

SendByte MACRO b
    mov BX , OFFSET NETWORK_OUT_BYTE
    add BX , NETWORK_OUT_BYTE_SIZE
    mov ah , b
    mov [BX] , ah
    inc NETWORK_OUT_BYTE_SIZE
ENDM

AddNetworkHandler MACRO b , func
    mov CH , b
    mov N_CURRENT_BYTE , CH

    mov ax , OFFSET func
    mov cx , cs
    mov N_CURRENT_FUNC_A0 , AL
    mov N_CURRENT_FUNC_A1 , AH
    mov N_CURRENT_FUNC_A2 , CL
    mov N_CURRENT_FUNC_A3 , CH

    call int_add_network_handler

ENDM

AddGlobalNetworkHandler MACRO func
    mov ax , OFFSET func
    mov cx , cs
    mov N_CURRENT_FUNC_A0 , AL
    mov N_CURRENT_FUNC_A1 , AH
    mov N_CURRENT_FUNC_A2 , CL
    mov N_CURRENT_FUNC_A3 , CH

    call int_add_global_network_handler
ENDM

FireByteEvent MACRO b
    mov ah , b
    mov N_CURRENT_BYTE , ah
    call int_fire_byte_event
ENDM

FlushNetworkBuffer MACRO
    call int_flush_buffer
ENDM

FlushNetworkOneByte MACRO
    call int_flush_one_byte
ENDM

UpdateNetwork MACRO
    call int_update_network
ENDM

ClearAllNetworkHandlers MACRO
    mov NETWORK_BYTE_HANDLERS_LIST_SIZE , 0
    mov NETWORK_GLOBAL_HANDLERS_LIST_SIZE , 0
    mov NETWORK_CANCEL_EVENT , 1
ENDM

EXTRN N_CURRENT_FUNC_A0:BYTE
EXTRN N_CURRENT_FUNC_A1:BYTE
EXTRN N_CURRENT_FUNC_A2:BYTE
EXTRN N_CURRENT_FUNC_A3:BYTE
EXTRN N_CURRENT_BYTE:BYTE

EXTRN NETWORK_IN_CFG:BYTE
EXTRN NETWORK_IN_BAUD_RATE:WORD
EXTRN NETWORK_OUT_BYTE:BYTE
EXTRN NETWORK_OUT_BYTE_SIZE:WORD

EXTRN NETWORK_BYTE_HANDLERS_LIST_SIZE:WORD
EXTRN NETWORK_GLOBAL_HANDLERS_LIST_SIZE:WORD
EXTRN NETWORK_CANCEL_EVENT:BYTE

EXTRN int_configure_port:FAR
EXTRN int_add_network_handler:FAR
EXTRN int_add_global_network_handler:FAR
EXTRN int_fire_byte_event:FAR
EXTRN int_flush_buffer:FAR
EXTRN int_flush_one_byte:FAR
EXTRN int_update_network:FAR