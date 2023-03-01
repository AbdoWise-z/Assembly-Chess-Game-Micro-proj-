INCLUDE utility.inc
INCLUDE input.inc
;I test shit here , most of the code here may not even work ..

.MODEL LARGE
.STACK 64
.DATA

testptr    dw  0000h
worked     db 'Worked$'

.CODE

test_proc PROC FAR
    DispString worked
    ret
test_proc ENDP

main PROC FAR
        mov ax , @Data
        mov ds , ax
        
        ;call cx:testptr
        ;call cx:testptr

        AddKeyHandler 11h , test_proc

        __t:
            UpdateInputs
            jmp __t

    EXIT:
        mov ah , 4CH
        INT 21h

        ret
main ENDP

END main