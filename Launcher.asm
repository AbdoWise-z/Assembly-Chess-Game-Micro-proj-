INCLUDE graphics.inc
INCLUDE res.inc
INCLUDE utility.inc
INCLUDE input.inc
INCLUDE network.inc

;highlights one chess block with the given marker parameters
;highlighting mean dawning the cursor-ish thing around the chess peice
; 'color'   --> the color of the marker
; 'x'       --> x position of the chess block
; 'y'       --> y position of the chess block, (0 , 0) is top left from white prespective
; 'l'       --> length of the marker
; 't'       --> thickness of the marker
HighlightBlock MACRO color , x , y , l , t
    mov8 HIGHLIGHT_COLOR , color
    mov16 HIGHLIGHT_X , x
    mov16 HIGHLIGHT_Y , y
    mov16 HIGHLIGHT_LENGTH , l
    mov16 HIGHLIGHT_THICKNESS , t
    call int_HighlightBlock
ENDM

;same as the above, but also marks the current x , y block as a block that can be accessed by the player
;see the blue preview on the right of the chess board , these are the accessible blocks
HighlightBlockAndAllow MACRO color , x , y , l , t
    mov8  HIGHLIGHT_COLOR , color
    mov16 HIGHLIGHT_X , x
    mov16 HIGHLIGHT_Y , y
    mov16 HIGHLIGHT_LENGTH , l
    mov16 HIGHLIGHT_THICKNESS , t
    call int_HighlightBlock
    call int_set_allowed_move
ENDM

TryToHighlightBlock MACRO x , y
    mov16 HIGHLIGHT_X , x
    mov16 HIGHLIGHT_Y , y
    call int_try_highlight_block
ENDM

GetPieceAt MACRO x , y
    mov16 GET_PIECE_X , x
    mov16 GET_PIECE_Y , y
    call int_get_piece
ENDM

IsAllowedMove MACRO x , y
    mov16 IS_ALLOWED_X , x
    mov16 IS_ALLOWED_Y , y
    call int_is_allowed_move
ENDM

; sets the current [HIGHLIGHT_X , HIGHLIGHT_Y] as accessible
; You shouldnt use this macro btw unless its for debugging ...
SetAllowedMove MACRO
    call int_set_allowed_move
ENDM

; marks all blocks as in-accessible (resets the accessible blocks)
ClearAllowedMoves MACRO
    call int_clear_allowed_moves
ENDM

GetPieceImageByCode MACRO p_code
    mov8 CONVERT_PIECE_CODE , p_code
    call int_get_piece_by_code
ENDM

PushMessage MACRO msg
    mov ax , OFFSET msg
    call int_push_message
ENDM

ClearStatusArea MACRO
    mov UI_MESSAGES_SIZE , 0
ENDM


DispMuliCharColored MACRO size , color
            LOCAL DispMuliChar_LOOP
    
    mov ah , 9
    mov bh , 0
    mov al , ' '
    mov cx , size
    mov bl , color
    int 10h

    mov cx, size
DispMuliChar_LOOP:
    mov ah , 2 
    mov dl, ds:[DI]
    int 21h
    inc DI
    dec cx
    jnz DispMuliChar_LOOP
ENDM



.MODEL LARGE     ; LARGE BOI  (Comment line 203 if you gonna reduce the model size , reason ? just trust me bro)
.STACK 1024
.DATA           

IMG_SIZE            EQU 20      ; this is fixed for every image (20x20) , see res.asm

CONVERT_PIECE_CODE         DB 00h         ;used by int_get_piece_image_by_code
CONVERT_PIECE_IMAGE_OFFSET DW 0000h                       

HIGHLIGHT_X             DW 0000h      
HIGHLIGHT_Y             DW 0000h          ; the current to-be highlighted block (set this before calling int_HighlightBlock or int_set_allowed_move)
HIGHLIGHT_COLOR         DB 00h            ; the color of the highlighting
HIGHLIGHT_LENGTH        DW 5              ; length
HIGHLIGHT_THICKNESS     DW 1              ; thickness
HIGHLIGHT_RESULT        DB 0              ; return value from try_highlight_block 
                                          ; 0 --> normal highlight
                                          ; 1 --> enemy highlight
                                          ; 2 --> ally here (didn't highlight)
                                          ; 3 --> out of board
HIGHLIGHT_IF_ENEMY      DB 1              ; extra flags for try_highlight_block
HIGHLIGHT_IF_EMPTY      DB 1              ; the first is asking if it should highlight the enemies or just skip , the second is the same
CURRENT_PIECE_X         DW 0000h          ; the current x location of the piece we are going to highlight its moves (set berfore calling DrawMovementHighlights)
CURRENT_PIECE_Y         DW 0000h          ; the current y location of the piece we are going to highlight its moves (set berfore calling DrawMovementHighlights)
HIGHLIGHT_ENABLE_VISUAL  DB 1              ; should the Highlight function give a visual feedback ? (draw the markers on the board)
HIGHLIGHT_ENABLE_SPECIAL DB 1              ; should the Highlight function enable special moves (not impelemnted yet)
HIGHLIGHT_ALLOWANCE_BLACK_BUFFER DW 0000h ; where to store the allowed moves if the piece is black (set berfore calling DrawMovementHighlights)
HIGHLIGHT_ALLOWANCE_WHITE_BUFFER DW 0000h ; where to store the allowed moves if the piece is white (set berfore calling DrawMovementHighlights)
HIGHLIGHT_ALLOWANCE_BUFFER       DW 0000h ; temperory variable , you shouldn't edit this unless you're calling is_allowed_move (will be set by DrawMovementHighlights)
HIGHLIGHT_CURRENT_PIECE_COLOR    DB 00h   ; the current piece color (first bit , 0 white , 1 black)
HIGHLIGHT_CURRENT_PIECE          DB 00h   ; the current piece of the highlighting process


GET_PIECE_X             DW 0            ; input to get_piece func , x position on chess board
GET_PIECE_Y             DW 0            ; input to get_piece func , y position on chess board
GET_PIECE_RESULT        DB 0            ; return value of get_piece is stored here

IS_ALLOWED_X            DW 0            ; input to is_allowed_move func , x position on chess board
IS_ALLOWED_Y            DW 0            ; input to is_allowed_move func , y position on chess board
IS_ALLOWED_RESULT       DB 0            ; return value of is_allowed_move

x           DW 0000h                ; these are temperoary variables that I use in drawing the board / highlighting 
y           DW 0000h                ; same
x1          DW 0000h                ; same
y1          DW 0000h                ; same

a1          DB 00h                  ;extra registers that are will not be used by any grahpics function
b1          DB 00h                  ;so you can use them as you wish 
c1          DB 00h                  ;notice that they may be used in non-graphical related functions tho ..
d1          DB 00h                  ; b1 , c1 , d1 , e1 are all not used anywere at the moment
e1          DB 00h

a           DW 0000h                ; same as a1 , b1 , ... but in WORD size 
b           DW 0000h
c           DW 0000h
d           DW 0000h
e           DW 0000h

main_x_pos  DW 0000h                ; I use these as temp variables in Update_BL_Moves
main_y_pos  DW 0000h


p0_color      DB 2fh                ; player 0 cursor color
p0_from_color DB 2dh                ; player 0 selection color
p0_x          DW 04h                ; player 0 cursor x position
p0_y          DW 04h                ; player 0 cursor y position
p0_from_x     DW -1h                ; player 0 selection x postion (-1 means no selection)
p0_from_y     DW -1h                ; player 0 selection y postion (-1 means no selection)

p1_color      DB 29h                ; same as player 0
p1_from_color DB 2ah
p1_x          DW 03h
p1_y          DW 03h
p1_from_x     DW -1h
p1_from_y     DW -1h                ; I know the name from_x , from_y is weird , but it is what it is


board_highlighted_color          DB 0eh         ; allowed move highlighting color
board_highlighted_special_color  DB 36h         ; special color of castle move
board_highlighted_target         DB 27h         ; eatable piece highlighting color

board_color_L DB 19h        ; board light color
board_color_D DB 06h        ; board dark  color

promotion_color_L      DB 42h        ; small promotion area light color
promotion_color_D      DB 41h        ; small promotion area dark color
promotion_color_border DB 13h        ; small promotion area border color

ui_invalidate                      DB 1       ; a flag for the renderer to notify it that the ui needs to be re-rendered 
                                              ; you should set this to 1 when ever you draw in the ui area (120 , 0) --> (320 , 200)
ui_border_color                    DB 02ah
ui_background_color                DB 0a3h
ui_piece_shadow_white_color        DB 014h
ui_piece_shadow_black_color        DB 01bh
ui_cooldown_bars_colors            DB 067h

UI_MESSAGES                        DB 64 DUP(00h) ;the messages on the status bar (pointers)
UI_MESSAGES_SIZE                   DW 0000h        ;

                                    ; CHAT Settings
ui_chat_visible                     DB 0           ; is chat visiable
ui_chat_background                  DB 00h
ui_chat_borders                     DB 0eh
CHAT_MY_TXT                         DB 130 DUP('A')  ;10 * 10 (10 lines , 10 chars every line)
CHAT_OUT_TXT                        DB 130 DUP('B') 
CHAT_MY_TXT_SiZE                    DW 0
CHAT_OUT_TXT_SiZE                   DW 0

ui_batch_visiable                   DB 0
ui_batch_border_color               DB 02h
ui_batch_background                 DB 02h
BATCH_TXT                           DB 130 DUP('A')  ;10 * 10 (10 lines , 10 chars every line)
BATCH_TXT_SIZE                      DW 0

                                    ; chat temp vars
CHAT_PUSH_CHAR                      DB 0
CHAT_PUSH_CHAR_SC                   DB 0
CHAT_PUSH_BUFFER                    DW 0000h
CHAT_PUSH_BUFFER_SIZE               DW 0000h
CHAT_BUFFER_MAX_SIZE                DW 130
CHAT_LINE_SIZE                      DW 13

NETWORK_ASCII                       DB 0 ;the current received ascii
NETWORK_SCAN_CODE                   DB 0 ;the current received scan-code
NETWORK_POS                         DB 0
NETWORK_IDEL_FRAMES                 DB 2

PlayerColor   DB 01  ; 0 = WHITE  , the color of the player controled by THIS device
                     ; 1 = BLACK

PlayerName      DB 45h,?,45H DUP('$')
OtherPlayerName DB 45H,?,45H DUP('$')

ALLOWED_MOVES_PLAYER0 DB 64 DUP(00h) ;allowed player moves based on the highlithing (white prespective also)
                             ; 0 --> not allowed , otherwise --> allowed
                             ;not used right now , but will be used to limit player movement

ALLOWED_MOVES_PLAYER1 DB 64 DUP(00h) ;allowed player moves based on the highlithing (white prespective also)
                             ; 0 --> not allowed , otherwise --> allowed
                             ;not used right now , but will be used to limit player movement

WHITE_BLOCKS  DB 64 DUP(00h) ;all the blocks that white can reach
BLACK_BLOCKS  DB 64 DUP(00h) ;all the blocks that black can reach

WHITE_TAKEN_PIECES      DB 32 DUP(00h) ; the size should be 16 a max , but I made it 32 for debugging reasons
WHITE_TAKEN_PIECES_SIZE DW 0           ; the current taken pieces from white
BLACK_TAKEN_PIECES      DB 32 DUP(00h) ;
BLACK_TAKEN_PIECES_SIZE DW 0           ; the current taken pieces from black
LAST_TAKEN_PIECE        DB 00h         ; the last taken piece in the last move

LAST_MOVED_PIECE_X      dw 0000h
LAST_MOVED_PIECE_Y      dw 0000h
LAST_MOVED_PIECE        db 00h


WhiteCanCastle     DB 1           ;a flag to notify that this player(player 0) can do a king castle move
                                  ;should be changed to 0 once a king moves
                                  ;is 1 at the beginning of the game
BlackCanCastle     DB 1           ;a flag to notify that this player(player 0) can do a king castle move
                                  ;should be changed to 0 once a king moves
                                  ;is 1 at the beginning of the game

CHESS_BOARD DB 15h,14h,13h,12h,11h,13h,14h,15h ; from white prespective
            DB 16h,16h,16h,16h,16h,16h,16h,16h
            DB 00h,00h,00h,00h,00h,00h,00h,00h ; abh
            DB 00h,00h,00h,00h,00h,00h,00h,00h ; a --> piece color (1 black , 0 white)
            DB 00h,00h,00h,00h,00h,00h,00h,00h ; b --> peice type  , EX: 15h --> black rock
            DB 00h,00h,00h,00h,00h,00h,00h,00h ;                       : 04h --> white knight
            DB 06h,06h,06h,06h,06h,06h,06h,06h
            DB 05h,04h,03h,02h,01h,03h,04h,05h
            ;5 --> rock
            ;4 --> knight
            ;3 --> Bishop
            ;2 --> Queen
            ;1 --> King
            ;6 --> Pawn
            ;0 --> empty

PIECES_OFFSETS    DW 128 DUP(0) ; x,y offset to simulate animations

PIECES_COOLDOWNS  DW 64 DUP(0ffffh)  ; the cool down of the pieces (0ffffh for testing) 
MOVE_COOLDOWN     DW 2500            ; in ms (max is 2621 ms becuase of overflow errors)
PIECES_SPEED        DW 1               ; pixel / ms
PEICE_SPEED_DEVISOR DW 1
FRAME_TIME          Dw 8               ; time of each frame (this is arropximate until we find a prober way to do it)
                                       ; time values are in ms


DEBUG_MODE               db  0         ; enable debug views ?
GAME_RUNNING             db  1         ; is the game running or ended ?
BREAK_GAME_LOOP          db  0         ; should we break the game loop (exit the game)

TXT_FORCE_RESTART             db   "Game was restarted by force ..$"

TXT_CREATE_GAME_MAIN_MENU       db   "Press F1 to create game$"
TXT_CREATE_CHAT_MAIN_MENU       db   "Press F2 to create chat$"
TXT_END_GAME_MAIN_MENU          db   "Press ESC to exit$"

TXT_JOIN_GAME_MAIN_MENU         db   "Press F1 to join game$"
TXT_JOIN_CHAT_MAIN_MENU         db   "Press F2 to join chat$"

TXT_CANSEL_GAME_MAIN_MENU       db   "Press F1 to cancel game$"
TXT_CANSEL_CHAT_MAIN_MENU       db   "Press F2 to cancel chat$"


TXT_UNDER_CONSTRUCTION          db   "Chat is under construction...$"
TXT_ME                          db   "Me:$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
TXT_OTHER                       db   "Other:$$$$$$$$$$$$$$$$$$$$$$$$$$$"

TXT_WHITE_WON                   db   "White Won$"
TXT_BLACK_WON                   db   "Black Won$"
TXT_CHECK_WHITE                 db   "White Check$"
TXT_CHECK_BLACK                 db   "Black Check$"
TXT_MATE_WHITE                  db   "White Mate$"
TXT_MATE_BLACK                  db   "Black Mate$"
TXT_TO_RESTART                  db   "'F' Exit$"
TXT_EXITING                     db   "Exiting ...$"
TXT_ENTER_PLAYER_NAME           db   "Enter your name: $"
TXT_PLAYER_NAME                 db   "Player name: $"

TXT_PRESS_ENTER_TO_CONT         db   "Press Enter to continue..$"
TXT_GAME_SETTINGS               db   "Game Settings$"
TXT_PLAYER_COLOR                db   "Player Color:$"
TXT_COLOR_WHITE                 db   "<    White    >$"
TXT_COLOR_BLACK                 db   "<    Black    >$"
TXT_F4_TOGGLE                   db   "  'T' toggle $"
TXT_F5_F6_INC_DEC               db   "  '<' decrease , '>' increase $"

TXT_MOVE_COOLDOWN               db   "Moves Cooldown (ms):$"
TXT_MOVE_COOLDOWN_BUFF          db   "$$$$$$$$$$$$$$$$"
TXT_PLAY_GAME                   db   "Start Game$"

TXT_GAME_INVITATION_SENT0       db   "- Game Invitation sent , waiting for '$"
TXT_GAME_INVITATION_SENT1       db   "' to accept..$"

TXT_GAME_INVITATION_RECV0       db   "- You have game invitation from '$"
TXT_GAME_INVITATION_RECV1       db   "' ..$"

TXT_Chat_INVITATION_SENT0       db   "- Chat Invitation sent , waiting for '$"
TXT_Chat_INVITATION_SENT1       db   "' to accept..$"

TXT_CHAT_INVITATION_RECV0       db   "- You have chat invitation from '$"
TXT_CHAT_INVITATION_RECV1       db   "' ..$"

TXT_NAME_ERROR                  db  "Name length should be range [4-13].$"

settings_have_game_inv          db  0
settings_have_chat_inv          db  0
settings_invalidate             db  1
settings_info_loader_enabled    db  0
settings_disp_error             db  0

TXT_DEBUG_MSG                   dw  0
TXT_LOADING                     db  "Loading game info ...$"

TXT_DEBUG_NETWORK               db  "DEBUG Bytes: "
TXT_DEBUG_TXT                   db  320 DUP(' ') , '$'
TxT_DEBUG_TXT_SIZE              dw  0


;chat varaibles
CHAT_ONLY_MY_TEXT                  db 10 DUP(80 DUP(' ')) , '$'
CHAT_ONLY_OTHER_TEXT               db 10 DUP(80 DUP(' ')) , '$'
CHAT_ONLY_MY_TEXT_S                dw 0
CHAT_ONLY_OTHER_TEXT_S             dw 0
CHAT_ONLY_INVALIDATE               db 1
CHAT_ONLY_NETWORK_IDEL             db 5
CHAT_ONLY_NETWORK_CURRENT_BYTE     db 0
CHAT_BREAK_LOOP                    db 0

.CODE

;just a big ass switch 
int_get_piece_by_code PROC
        jmp int_get_piece_by_code_q_exit_skip
    int_get_piece_by_code_q_exit:
        ret
    int_get_piece_by_code_q_exit_skip:

        cmp CONVERT_PIECE_CODE , 11h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET black_king
        jz int_get_piece_by_code_q_exit
        cmp CONVERT_PIECE_CODE , 12h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET black_queen
        jz int_get_piece_by_code_q_exit
        cmp CONVERT_PIECE_CODE , 13h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET black_bishop
        jz int_get_piece_by_code_q_exit
        cmp CONVERT_PIECE_CODE , 14h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET black_knight
        jz int_get_piece_by_code_q_exit
        cmp CONVERT_PIECE_CODE , 15h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET black_rock
        jz int_get_piece_by_code_q_exit
        cmp CONVERT_PIECE_CODE , 16h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET black_pawn
        jz int_get_piece_by_code_q_exit
        cmp CONVERT_PIECE_CODE , 01h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET white_king
        jz int_get_piece_by_code_fin
        cmp CONVERT_PIECE_CODE , 02h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET white_queen
        jz int_get_piece_by_code_fin
        cmp CONVERT_PIECE_CODE , 03h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET white_bishop
        jz int_get_piece_by_code_fin
        cmp CONVERT_PIECE_CODE , 04h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET white_knight
        jz int_get_piece_by_code_fin
        cmp CONVERT_PIECE_CODE , 05h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET white_rock
        jz int_get_piece_by_code_fin
        cmp CONVERT_PIECE_CODE , 06h
        mov CONVERT_PIECE_IMAGE_OFFSET , OFFSET white_pawn
        jz int_get_piece_by_code_fin
        mov CONVERT_PIECE_IMAGE_OFFSET , 0000h
    int_get_piece_by_code_fin:
        ret
int_get_piece_by_code ENDP

;Highlights one block stored in (HIGHLIGHT_X , HIGHLIGHT_Y)
;draws 8 small rects that forms the marker
;nothing too complicated here ..
int_HighlightBlock PROC
        cmp HIGHLIGHT_X , 7                       ;check the board bounds
        jg int_HighlightBlock_quick_Exit
        cmp HIGHLIGHT_Y , 7
        jg int_HighlightBlock_quick_Exit
        cmp HIGHLIGHT_X , 0
        jl int_HighlightBlock_quick_Exit
        cmp HIGHLIGHT_Y , 0
        jl int_HighlightBlock_quick_Exit
        cmp HIGHLIGHT_ENABLE_VISUAL , 0
        jz int_HighlightBlock_quick_Exit

        jmp int_HighlightBlock_quick_Exit_Skip
    int_HighlightBlock_quick_Exit:
        ret
    int_HighlightBlock_quick_Exit_Skip:
        mov ax, HIGHLIGHT_Y
        mov bx, 25
        mul bx
        mov y , ax
        mov ax, HIGHLIGHT_X
        mov bx, 25
        mul bx
        mov x , ax

        cmp PlayerColor , 01h ; are we black ?
        jnz int_HighlightBlock_skip_rot ; if we are white , then no need to rotate the board
        mov ax , x
        mov dx , y
        mov x , 200
        mov y , 200
        sub x , ax
        sub y , dx
        sub x , 25
        sub y , 25
    int_HighlightBlock_skip_rot:
        
        mov16 x1 , x
        mov16 y1 , y

        DrawRect HIGHLIGHT_COLOR , x1 , y1 , HIGHLIGHT_LENGTH , HIGHLIGHT_THICKNESS ;top left
        DrawRect HIGHLIGHT_COLOR , x1 , y1 , HIGHLIGHT_THICKNESS , HIGHLIGHT_LENGTH

        mov16 x1 , x ;useless , but to keep my sanity
        mov16 y1 , y
        add x1 , 25
        sub16 x1 , HIGHLIGHT_LENGTH
        DrawRect HIGHLIGHT_COLOR , x1 , y1 , HIGHLIGHT_LENGTH , HIGHLIGHT_THICKNESS ;top right
        mov16 x1 , x ;I know it can be done without mov (using add/sub) but mov is just easier
        mov16 y1 , y
        add x1 , 25
        sub16 x1 , HIGHLIGHT_THICKNESS
        DrawRect HIGHLIGHT_COLOR , x1 , y1 , HIGHLIGHT_THICKNESS , HIGHLIGHT_LENGTH

        mov16 x1 , x
        mov16 y1 , y
        add y1 , 25
        sub16 y1 , HIGHLIGHT_LENGTH
        DrawRect HIGHLIGHT_COLOR , x1 , y1 , HIGHLIGHT_THICKNESS , HIGHLIGHT_LENGTH ;button left
        mov16 x1 , x
        mov16 y1 , y
        add y1 , 25
        sub16 y1 , HIGHLIGHT_THICKNESS
        DrawRect HIGHLIGHT_COLOR , x1 , y1 , HIGHLIGHT_LENGTH , HIGHLIGHT_THICKNESS
        mov16 x1 , x
        mov16 y1 , y
        add x1 , 25
        sub16 x1 , HIGHLIGHT_LENGTH
        add y1 , 25
        sub16 y1 , HIGHLIGHT_THICKNESS
        DrawRect HIGHLIGHT_COLOR , x1 , y1 , HIGHLIGHT_LENGTH , HIGHLIGHT_THICKNESS ;button right
        mov16 x1 , x
        mov16 y1 , y
        add x1 , 25
        sub16 x1 , HIGHLIGHT_THICKNESS
        add y1 , 25
        sub16 y1 , HIGHLIGHT_LENGTH
        DrawRect HIGHLIGHT_COLOR , x1 , y1 , HIGHLIGHT_THICKNESS , HIGHLIGHT_LENGTH
        ret
int_HighlightBlock ENDP

;clears the available moves buffer (proc cuz I dont wanna fuck up the jmp ranges)
int_clear_allowed_moves PROC
    MemSet ALLOWED_MOVES_PLAYER0 , 64 , 00h
    MemSet ALLOWED_MOVES_PLAYER1 , 64 , 00h
    ret
int_clear_allowed_moves ENDP

;addes the current HIGHLIGHT_X , HIGHLIGHT_Y to the allowed moves buffer without changing any variable (changes reg values tho)
int_set_allowed_move PROC
    mov ax , 8
    mov bx , HIGHLIGHT_Y
    mul bx
    add ax , HIGHLIGHT_X
    mov bx , ax
    add BX , HIGHLIGHT_ALLOWANCE_BUFFER
    mov ah , 1
    mov [BX] , ah
    ret
int_set_allowed_move ENDP

;description
int_try_highlight_block PROC
        cmp HIGHLIGHT_X , 7                       ;check the board bounds
        jg int_try_highlight_block_out_of_bounds
        cmp HIGHLIGHT_Y , 7
        jg int_try_highlight_block_out_of_bounds
        cmp HIGHLIGHT_X , 0
        jl int_try_highlight_block_out_of_bounds
        cmp HIGHLIGHT_Y , 0
        jl int_try_highlight_block_out_of_bounds
        
        jmp int_try_highlight_block_out_bridge
    int_try_highlight_block_out_of_bounds:
        mov HIGHLIGHT_RESULT , 3
        ret
    int_try_highlight_block_out_bridge:
        mov ax , 8
        mov bx , HIGHLIGHT_Y
        mul bx
        add ax , HIGHLIGHT_X
        mov bx , ax
        mov ah , CHESS_BOARD[BX]
        cmp ah , 00h ;empty block
        jz int_try_highlight_block_normal_block
        mov al , ah
        and al , 00010000B
        SHR al , 4
        xor al , HIGHLIGHT_CURRENT_PIECE_COLOR
        cmp al , 0
        jnz int_try_highlight_block_enemy_block
        mov HIGHLIGHT_RESULT , 2
        ret
    int_try_highlight_block_normal_block:
        mov HIGHLIGHT_RESULT , 0
        cmp HIGHLIGHT_IF_EMPTY , 0
        jz int_try_highlight_block_exit
        HighlightBlockAndAllow board_highlighted_color , HIGHLIGHT_X , HIGHLIGHT_Y , 5 , 1
        ret
    int_try_highlight_block_enemy_block:
        mov HIGHLIGHT_RESULT , 1
        cmp HIGHLIGHT_IF_ENEMY , 0
        jz int_try_highlight_block_exit
        HighlightBlockAndAllow board_highlighted_target , HIGHLIGHT_X , HIGHLIGHT_Y , 5 , 1
        ret
    int_try_highlight_block_exit:
        ret
int_try_highlight_block ENDP

;description
int_get_piece PROC
    cmp GET_PIECE_X , 7                       ;check the board bounds
    jg int_get_piece_out_of_bounds
    cmp GET_PIECE_Y , 7
    jg int_get_piece_out_of_bounds
    cmp GET_PIECE_X , 0
    jl int_get_piece_out_of_bounds
    cmp GET_PIECE_Y , 0
    jl int_get_piece_out_of_bounds
    mov ax , 8
    mov bx , GET_PIECE_Y
    mul bx
    add ax , GET_PIECE_X
    mov bx , ax
    mov ah , CHESS_BOARD[BX]
    mov GET_PIECE_RESULT , ah
    ret
    int_get_piece_out_of_bounds:
    mov GET_PIECE_RESULT , 0ffh
    ret
int_get_piece ENDP


int_is_allowed_move PROC
    cmp IS_ALLOWED_X , 7                       ;check the board bounds
    jg int_is_allowed_move_out_of_bounds
    cmp IS_ALLOWED_Y , 7
    jg int_is_allowed_move_out_of_bounds
    cmp IS_ALLOWED_X , 0
    jl int_is_allowed_move_out_of_bounds
    cmp IS_ALLOWED_Y , 0
    jl int_is_allowed_move_out_of_bounds
    mov ax , 8
    mov bx , IS_ALLOWED_Y
    mul bx
    add ax , IS_ALLOWED_X
    mov bx , ax
    add BX , HIGHLIGHT_ALLOWANCE_BUFFER 
    mov ah , [BX]
    mov IS_ALLOWED_RESULT , ah
    ret
    int_is_allowed_move_out_of_bounds:
    mov IS_ALLOWED_RESULT , 00h
    ret
int_is_allowed_move ENDP
; all the "DrawMovementHighlights_xxxx" will be called by "DrawMovementHighlights"
; you also have full control over the variables a1 , a , b1 , b , ....
DrawMovementHighlights_BISHOP PROC
        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
    DrawMovementHighlights_BISHOP_LOP_0:
        inc a
        inc b
        TryToHighlightBlock a , b
        cmp HIGHLIGHT_RESULT , 0
        jz DrawMovementHighlights_BISHOP_LOP_0
        
        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
   DrawMovementHighlights_BISHOP_LOP_1:
        dec a
        dec b
        TryToHighlightBlock a , b
        cmp HIGHLIGHT_RESULT , 0
        jz DrawMovementHighlights_BISHOP_LOP_1
    
        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
    DrawMovementHighlights_BISHOP_LOP_00:
        inc b
        dec a
        TryToHighlightBlock a , b
        cmp HIGHLIGHT_RESULT , 0
        jz DrawMovementHighlights_BISHOP_LOP_00
        
        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
    DrawMovementHighlights_BISHOP_LOP_11:
        dec b
        inc a
        TryToHighlightBlock a , b
        cmp HIGHLIGHT_RESULT , 0
        jz DrawMovementHighlights_BISHOP_LOP_11
        ret
DrawMovementHighlights_BISHOP ENDP

DrawMovementHighlights_QUEEN PROC
        call DrawMovementHighlights_BISHOP
        call DrawMovementHighlights_ROCK
        ret
DrawMovementHighlights_QUEEN ENDP

DrawMovementHighlights_KING PROC
            mov16 a , CURRENT_PIECE_X                   
            mov16 b , CURRENT_PIECE_Y
            ;first the basic moves
            inc a
            TryToHighlightBlock a , b
            inc b
            TryToHighlightBlock a , b
            dec a
            TryToHighlightBlock a , b
            dec a
            TryToHighlightBlock a , b
            dec b
            TryToHighlightBlock a , b
            dec b
            TryToHighlightBlock a , b
            inc a
            TryToHighlightBlock a , b
            inc a
            TryToHighlightBlock a , b
            
            ;now check for if the king can Castle and stuff ,
            ;ok normally you shouldn't be able to Castle if there is an enemy piece that has a move that can block the path between the rock
            ;and the king , but idk how its implemented in this type of chess
            
            mov ah , HIGHLIGHT_CURRENT_PIECE_COLOR  ; can_castle = WhiteCanCastle * !Color + BlackCanCastle * Color
            not ah
            and ah , WhiteCanCastle                 ; this should return if castling is enabled regardless of the piece color
            mov al , HIGHLIGHT_CURRENT_PIECE_COLOR
            and al , BlackCanCastle
            or  ah , al

            and ah , HIGHLIGHT_ENABLE_VISUAL
            cmp ah , 0
            jnz DrawMovementHighlights_KING_C_Left 
            ret
        DrawMovementHighlights_KING_C_Left:
            mov16 a , CURRENT_PIECE_X                   
            mov16 b , CURRENT_PIECE_Y
            inc a
            GetPieceAt a , b
            cmp GET_PIECE_RESULT , 0
            jz DrawMovementHighlights_KING_C_Left_C0
            jmp DrawMovementHighlights_KING_C_Right
        DrawMovementHighlights_KING_C_Left_C0: ;passed check 0
            inc a
            GetPieceAt a , b
            cmp GET_PIECE_RESULT , 0
            jz DrawMovementHighlights_KING_C_Left_C1
            jmp DrawMovementHighlights_KING_C_Right
        DrawMovementHighlights_KING_C_Left_C1: ;passed check 1
            inc a
            GetPieceAt a , b
            mov ah , HIGHLIGHT_CURRENT_PIECE_COLOR
            SHL ah , 4
            xor GET_PIECE_RESULT , ah
            cmp GET_PIECE_RESULT , 05h ;a rock (if the player color is the same as the piece color , then make the color flag 0)
            jz DrawMovementHighlights_KING_C_Left_C2
            jmp DrawMovementHighlights_KING_C_Right
        DrawMovementHighlights_KING_C_Left_C2:
            dec a
            HighlightBlockAndAllow board_highlighted_special_color , a  , b , 5 , 1


        DrawMovementHighlights_KING_C_Right:
            mov16 a , CURRENT_PIECE_X                   
            mov16 b , CURRENT_PIECE_Y
            dec a
            GetPieceAt a , b
            cmp GET_PIECE_RESULT , 0
            jz DrawMovementHighlights_KING_C_Right_C0
            jmp DrawMovementHighlights_KING_EXIT
        DrawMovementHighlights_KING_C_Right_C0: ;passed check 0
            dec a
            GetPieceAt a , b
            cmp GET_PIECE_RESULT , 0
            jz DrawMovementHighlights_KING_C_Right_C1
            jmp DrawMovementHighlights_KING_EXIT
        DrawMovementHighlights_KING_C_Right_C1: ;passed check 0
            dec a
            GetPieceAt a , b
            cmp GET_PIECE_RESULT , 0
            jz DrawMovementHighlights_KING_C_Right_C2
            jmp DrawMovementHighlights_KING_EXIT
        DrawMovementHighlights_KING_C_Right_C2: ;passed check 1
            dec a
            GetPieceAt a , b
            mov ah , HIGHLIGHT_CURRENT_PIECE_COLOR
            SHL ah , 4
            xor GET_PIECE_RESULT , ah
            cmp GET_PIECE_RESULT , 05h ;a rock (if the player color is the same as the piece color , then make the color flag 0)
            jz DrawMovementHighlights_KING_C_Right_C3
            jmp DrawMovementHighlights_KING_EXIT
        DrawMovementHighlights_KING_C_Right_C3:
            inc a
            inc a
            HighlightBlockAndAllow board_highlighted_special_color , a  , b , 5 , 1
        DrawMovementHighlights_KING_EXIT:
            ret
DrawMovementHighlights_KING ENDP

DrawMovementHighlights_PAWN PROC
        mov c , -1
        mov d , 6
        cmp HIGHLIGHT_CURRENT_PIECE_COLOR , 00
        jz dmhp_skip_rev_forward
        mov c , 1
        mov d , 1
    dmhp_skip_rev_forward:

        cmp HIGHLIGHT_ENABLE_VISUAL , 0
        jz dmhp_check_lr

        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
        add16 b , c
        mov HIGHLIGHT_IF_ENEMY , 0
        TryToHighlightBlock a , b
        cmp HIGHLIGHT_RESULT , 0
        jnz dmhp_check_lr
        cmp16 CURRENT_PIECE_Y , d
        jnz dmhp_check_lr
        add16 b , c
        TryToHighlightBlock a , b
    dmhp_check_lr:
        mov HIGHLIGHT_IF_ENEMY , 1
        mov HIGHLIGHT_IF_EMPTY , 0
        
        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
        add16 b , c
        inc a
        TryToHighlightBlock a , b
        
        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
        add16 b , c
        dec a
        TryToHighlightBlock a , b
        
        mov HIGHLIGHT_IF_EMPTY , 1
        
        ret
DrawMovementHighlights_PAWN ENDP
        
DrawMovementHighlights_KNIGHT PROC

        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
        dec a
        dec a
        inc b
        TryToHighlightBlock a , b
        inc b
        inc a
        TryToHighlightBlock a , b

        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
        inc a
        inc a
        inc b
        TryToHighlightBlock a , b
        inc b
        dec a
        TryToHighlightBlock a , b

        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
        dec a
        dec a
        dec b
        TryToHighlightBlock a , b
        dec b
        inc a
        TryToHighlightBlock a , b

        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
        inc a
        inc a
        dec b
        TryToHighlightBlock a , b
        dec b
        dec a
        TryToHighlightBlock a , b

        ret
DrawMovementHighlights_KNIGHT ENDP

DrawMovementHighlights_ROCK PROC
        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
    DrawMovementHighlights_ROCK_LOP_0:
        inc a
        TryToHighlightBlock a , b
        cmp HIGHLIGHT_RESULT , 0
        jz DrawMovementHighlights_ROCK_LOP_0
        
        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
    DrawMovementHighlights_ROCK_LOP_1:
        dec a
        TryToHighlightBlock a , b
        cmp HIGHLIGHT_RESULT , 0
        jz DrawMovementHighlights_ROCK_LOP_1
    
        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
    DrawMovementHighlights_ROCK_LOP_00:
        inc b
        TryToHighlightBlock a , b
        cmp HIGHLIGHT_RESULT , 0
        jz DrawMovementHighlights_ROCK_LOP_00
        
        mov16 a , CURRENT_PIECE_X                   
        mov16 b , CURRENT_PIECE_Y
    DrawMovementHighlights_ROCK_LOP_11:
        dec b
        TryToHighlightBlock a , b
        cmp HIGHLIGHT_RESULT , 0
        jz DrawMovementHighlights_ROCK_LOP_11
        ret
DrawMovementHighlights_ROCK ENDP

;Draws the selected piece available moves
DrawMovementHighlights PROC
        cmp CURRENT_PIECE_X , -1
        jz DrawMovementHighlights_q_exit
        cmp CURRENT_PIECE_Y , -1 
        jz DrawMovementHighlights_q_exit

        jmp DrawMovementHighlights_q_exit_skip
    DrawMovementHighlights_q_exit:
        ret
    DrawMovementHighlights_q_exit_skip:  

        mov ax, 8
        mov bx , CURRENT_PIECE_Y
        mul bx
        add ax , CURRENT_PIECE_X

        mov bx , ax

        mov al , CHESS_BOARD[bx]
        mov HIGHLIGHT_CURRENT_PIECE , al
        ;DrawRect HIGHLIGHT_CURRENT_PIECE , 200 , 150 , 10 , 10

        mov ah , HIGHLIGHT_CURRENT_PIECE
        SHR ah , 4
        and ah , 1
        mov HIGHLIGHT_CURRENT_PIECE_COLOR , ah

        mov16 HIGHLIGHT_ALLOWANCE_BUFFER , HIGHLIGHT_ALLOWANCE_WHITE_BUFFER
        cmp HIGHLIGHT_CURRENT_PIECE_COLOR , 00
        jz DrawMovementHighlights_skip_set_black_buffer
        mov16 HIGHLIGHT_ALLOWANCE_BUFFER , HIGHLIGHT_ALLOWANCE_BLACK_BUFFER
        
    DrawMovementHighlights_skip_set_black_buffer:

        mov al , HIGHLIGHT_CURRENT_PIECE
        and al , 00001111B ; delete the last 4 bits (contains the color of the peice)

        cmp al , 05h
        jz __dmh_rock
        cmp al , 04h
        jz __dmh_knight
        cmp al , 03h
        jz __dmh_bishop
        cmp al , 02h
        jz __dmh_queen
        cmp al , 01h
        jz __dmh_king
        cmp al , 06h
        jz __dmh_pawn
        
        jmp __dmh_r ;skip

    __dmh_rock:
        call DrawMovementHighlights_ROCK
        jmp __dmh_r
    __dmh_knight:
        call DrawMovementHighlights_KNIGHT
        jmp __dmh_r
    __dmh_bishop:
        call DrawMovementHighlights_BISHOP
        jmp __dmh_r
    __dmh_queen:
        call DrawMovementHighlights_QUEEN
        jmp __dmh_r
    __dmh_king:
        call DrawMovementHighlights_KING
        jmp __dmh_r
    __dmh_pawn:
        call DrawMovementHighlights_PAWN
        jmp __dmh_r

    
    __dmh_r:
        ret
DrawMovementHighlights ENDP

Update_BW_Moves PROC
        MemSet WHITE_BLOCKS , 64 , 0
        MemSet BLACK_BLOCKS , 64 , 0
        mov main_x_pos , 0
        mov main_y_pos , 0
        mov HIGHLIGHT_ENABLE_VISUAL , 0
        
        mov BX , offset WHITE_BLOCKS
        mov HIGHLIGHT_ALLOWANCE_WHITE_BUFFER , BX
        
        mov BX , offset BLACK_BLOCKS
        mov HIGHLIGHT_ALLOWANCE_BLACK_BUFFER , BX
        
    Update_BL_Moves_looper:
        mov16 CURRENT_PIECE_X , main_x_pos
        mov16 CURRENT_PIECE_Y , main_y_pos
        call DrawMovementHighlights
        inc main_x_pos
        cmp main_x_pos , 8
        jz Update_BL_Moves_looper_x
        jmp Update_BL_Moves_looper
    Update_BL_Moves_looper_x:
        mov main_x_pos , 0
        inc main_y_pos 
        cmp main_y_pos , 8
        jnz Update_BL_Moves_looper  
        
        mov HIGHLIGHT_ENABLE_VISUAL , 1
    ret
Update_BW_Moves ENDP

;Draws the board
Draw_Board_background PROC
        mov a , 0
        mov b , 0
    Draw_Board_background_row:
        mov ax, a
        mov bx, 25
        mul bx
        mov x , ax
        mov ax, b
        mov bx, 25
        mul bx
        mov y , ax

        cmp PlayerColor , 01h ; are we black ?
        jnz Draw_Board_background_skip_rot
        mov ax , x
        mov dx , y
        mov x , 200
        mov y , 200
        sub x , ax
        sub y , dx
        sub x , 25
        sub y , 25
    Draw_Board_background_skip_rot:
        
        mov ax , a
        mov bx , b
        xor ax , bx
        and ax , 0001h
        mov ah , board_color_L
        jz Draw_Board_background_draw_rect
        mov ah , board_color_D
    Draw_Board_background_draw_rect:
        mov a1 , ah
        DrawRect a1 , x , y , 25 , 25
        inc a
        cmp a , 8
        jz Draw_Board_background__next_row
        jmp Draw_Board_background_row
    Draw_Board_background__next_row:

        mov a , 0
        inc b
        cmp b , 8
        jz Draw_Board_background__db_r
        jmp Draw_Board_background_row

    Draw_Board_background__db_r:
        ret
Draw_Board_background ENDP

Draw_Board PROC
        
        call Draw_Board_background
        mov a , 0
        mov b , 0

    row:
        mov ax, a
        mov bx, 25
        mul bx
        mov x , ax
        mov ax, b
        mov bx, 25
        mul bx
        mov y , ax
        mov ax , b
        mov bx , 8
        mul bx
        add ax , a
        mov bx , 4
        mul bx

        mov bx , OFFSET PIECES_OFFSETS
        add bx , ax
        mov ax , [bx]
        add x , ax
        add bx , 2
        mov ax , [bx]
        add y , ax

        cmp PlayerColor , 01h ; are we black ?
        jnz skip_rot2
        mov ax , x
        mov dx , y
        mov x , 200
        mov y , 200
        sub x , ax
        sub y , dx
        sub x , 25
        sub y , 25
    skip_rot2:
    
        mov ax, b
        mov bx, 8
        mul bx

        add ax, a
        mov bx, ax

        add bx , OFFSET CHESS_BOARD
        mov al , [BX] ; current peice
        mov a1 , al
        
        GetPieceImageByCode a1
        cmp CONVERT_PIECE_IMAGE_OFFSET , 0
        jne __do_draw_piece_image
        jmp fin

    __do_draw_piece_image:
        mov ax, b
        mov bx, 16
        mul bx

        add ax, a
        add ax, a ; ax * 2
        
        mov bx, ax
        add bx , OFFSET PIECES_COOLDOWNS
        mov ax , [BX]
        cmp ax , 0
        jg __do_draw_piece_image_and_cooldown
        jmp __do_draw_piece_only_image
    __do_draw_piece_image_and_cooldown:
        mov c , ax ; the current cool down
        
        mov dx , 0
        mov ax , MOVE_COOLDOWN
        mov bx , 4
        div bx
        mov d , ax ; quarter of the cool down
        
    __do_draw_piece_image_and_cooldown_p0:
        mov ax, c
        mov bx, 25
        mul bx
        ;mov dx, 0
        mov bx, d
        div bx ;ax now contains how many pixels should we draw in the bar
        mov e , ax
        cmp e , 25
        jl __do_draw_piece_image_and_cooldown_p0_0
        mov e , 25 ; prevent bar overflow
    __do_draw_piece_image_and_cooldown_p0_0:
        DrawRect ui_cooldown_bars_colors , x , y , e , 1

    __do_draw_piece_image_and_cooldown_p1:
        sub16 c , d
        cmp c , 1
        jl __do_draw_piece_image_and_cooldown_p2
        mov ax, c
        mov bx, 25
        mul bx
        ;mov dx, 0
        mov bx, d
        div bx ;ax now contains how many pixels should we draw in the bar
        mov e , ax
        cmp e , 25
        jl __do_draw_piece_image_and_cooldown_p1_0
        mov e , 25 ; prevent bar overflow
    __do_draw_piece_image_and_cooldown_p1_0:
        add x , 24
        DrawRect ui_cooldown_bars_colors , x , y , 1 , e
        sub x , 24
    
    __do_draw_piece_image_and_cooldown_p2:
        sub16 c , d
        cmp c , 1
        jl __do_draw_piece_image_and_cooldown_p3
        mov ax, c
        mov bx, 25
        mul bx
        ;mov dx, 0
        mov bx, d
        div bx ;ax now contains how many pixels should we draw in the bar
        mov e , ax
        cmp e , 25
        jl __do_draw_piece_image_and_cooldown_p2_0
        mov e , 25 ; prevent bar overflow
    __do_draw_piece_image_and_cooldown_p2_0:
        sub16 x , e
        add x , 25
        add y , 24
        DrawRect ui_cooldown_bars_colors , x , y , e , 1
        add16 x , e
        sub x , 25
        sub y , 24

    __do_draw_piece_image_and_cooldown_p3:
        sub16 c , d
        cmp c , 1
        jl __do_draw_piece_only_image
        mov ax, c
        mov bx, 25
        mul bx
        ;mov dx, 0
        mov bx, d
        div bx ;ax now contains how many pixels should we draw in the bar
        mov e , ax
        cmp e , 25
        jl __do_draw_piece_image_and_cooldown_p3_0
        mov e , 25 ; prevent bar overflow
    __do_draw_piece_image_and_cooldown_p3_0:
        add y , 25
        sub16 y , e
        DrawRect ui_cooldown_bars_colors , x , y , 1 , e
        sub y , 25
        add16 y , e

    __do_draw_piece_only_image:
        add x , 2
        add y , 2

        DrawImageImd CONVERT_PIECE_IMAGE_OFFSET , x , y , 20 , 20

        ;DrawRect 04h , x , y , 5 , 5

        sub x , 2
        sub y , 2
    fin:
        inc a
        cmp a , 8
        jz __next_row
        jmp row
    __next_row:

        mov a , 0
        inc b
        cmp b , 8
        jz __db_r
        jmp row

    __db_r:
        ret
Draw_Board ENDP

; the blue view on the right of the board
debug_draw_avalaible_moves PROC
        cmp DEBUG_MODE , 1
        je debug_draw_avalaible_moves_do
        ret
    debug_draw_avalaible_moves_do:

        mov a , 0
        mov b , 0

        
    debug_draw_avalaible_moves_row:
        mov ax, a
        mov bx, 8
        mul bx

        mov x , ax
        
        mov ax, b
        mov bx, 8
        mul bx

        mov y , ax

        cmp PlayerColor , 01h ; are we black ?
        jnz debug_draw_avalaible_moves_draw_rect
        mov ax , x
        mov dx , y
        mov x , 64
        mov y , 64
        sub x , ax
        sub y , dx
        sub x , 8
        sub y , 8
    
    debug_draw_avalaible_moves_draw_rect:
        mov ax, b
        mov bx, 8
        mul bx

        add ax, a
        mov bx, ax

        mov al , ALLOWED_MOVES_PLAYER0[BX] ; current peice
        mov a1 , al
        add x , 200
        
        DrawRect a1 , x , y , 8 , 8
    debug_draw_avalaible_moves_fin:
        inc a
        cmp a , 8
        jz debug_draw_avalaible_moves___next_row
        jmp debug_draw_avalaible_moves_row
    debug_draw_avalaible_moves___next_row:

        mov a , 0
        inc b
        cmp b , 8
        jz debug_draw_avalaible_moves___db_r
        jmp debug_draw_avalaible_moves_row

    debug_draw_avalaible_moves___db_r:
        DrawRect 40h , 200 , 0 , 64 , 1
        DrawRect 40h , 200 , 63 , 64 , 1
        DrawRect 40h , 200 , 0 , 1 , 64
        DrawRect 40h , 263 , 0 , 1 , 64

        ret
debug_draw_avalaible_moves ENDP


debug_draw_bw_moves PROC
        cmp DEBUG_MODE , 1
        je debug_draw_bw_moves_do
        ret
    debug_draw_bw_moves_do:

        mov a , 0
        mov b , 0

        
    debug_draw_bw_moves_row:
        mov ax, a
        mov bx, 8
        mul bx

        mov x , ax
        
        mov ax, b
        mov bx, 8
        mul bx

        mov y , ax

        cmp PlayerColor , 01h ; are we black ?
        jnz debug_draw_bw_moves_draw_rect
        mov ax , x
        mov dx , y
        mov x , 64
        mov y , 64
        sub x , ax
        sub y , dx
        sub x , 8
        sub y , 8
    
    debug_draw_bw_moves_draw_rect:
        mov ax, b
        mov bx, 8
        mul bx

        add ax, a
        mov bx, ax

        mov al , WHITE_BLOCKS[BX] ; current peice
        mov a1 , al
        add x , 200

        add y , 64
        
        DrawRect a1 , x , y , 8 , 8

        mov al , BLACK_BLOCKS[BX] ; current peice
        mov a1 , al
        add y , 64
        
        DrawRect a1 , x , y , 8 , 8

    debug_draw_bw_moves_fin:
        inc a
        cmp a , 8
        jz debug_draw_bw_moves___next_row
        jmp debug_draw_bw_moves_row
    debug_draw_bw_moves___next_row:

        mov a , 0
        inc b
        cmp b , 8
        jz debug_draw_bw_moves___db_r
        jmp debug_draw_bw_moves_row

    debug_draw_bw_moves___db_r:
        DrawRect 40h , 200 , 64 , 64 , 1
        DrawRect 40h , 200 , 127 , 64 , 1
        DrawRect 40h , 200 , 64 , 1 , 64
        DrawRect 40h , 263 , 64 , 1 , 64

        DrawRect 40h , 200 , 128 , 64 , 1
        DrawRect 40h , 200 , 191 , 64 , 1
        DrawRect 40h , 200 , 128 , 1 , 64
        DrawRect 40h , 263 , 128 , 1 , 64

        ret
debug_draw_bw_moves ENDP

;Validates the player 1 position
;if it out of bounds , its brings it back to the board
ValidatePlayer1Position PROC
        cmp p1_x , 8
        jnz ValidatePlayer1Position_px_1
        mov p1_x , 0
    ValidatePlayer1Position_px_1:
        cmp p1_x , -1
        jnz ValidatePlayer1Position_py_0
        mov p1_x , 7
    ValidatePlayer1Position_py_0:
        cmp p1_y , 8
        jnz ValidatePlayer1Position_py_1
        mov p1_y , 0
    ValidatePlayer1Position_py_1:
        cmp p1_y , -1
        jnz ValidatePlayer1Position_py_2
        mov p1_y , 7
    ValidatePlayer1Position_py_2:
        ret
ValidatePlayer1Position ENDP

Player1_MoveUp PROC
        mov c , -1
        cmp PlayerColor , 0
        jz Player1_MoveUp_ss1
        mov c , 1
    Player1_MoveUp_ss1:
        add16 p1_y , c

        call ValidatePlayer1Position

        ret
Player1_MoveUp ENDP

Player1_MoveDown PROC
        mov c , 1
        cmp PlayerColor , 0
        jz Player1_MoveDown_ss1
        mov c , -1
    Player1_MoveDown_ss1:
        add16 p1_y , c
    
        call ValidatePlayer1Position
        
        ret
Player1_MoveDown ENDP

Player1_MoveLeft PROC
        mov c , -1
        cmp PlayerColor , 0
        jz Player1_MoveLeft_ss1
        mov c , 1
    Player1_MoveLeft_ss1:
        add16 p1_x , c

        call ValidatePlayer1Position
        
        ret
Player1_MoveLeft ENDP

Player1_MoveRight PROC
        mov c , 1
        cmp PlayerColor , 0
        jz Player1_MoveRight_ss1
        mov c , -1
    Player1_MoveRight_ss1:
        add16 p1_x , c

        call ValidatePlayer1Position
        
        ret
Player1_MoveRight ENDP

ValidatePlayer0Position PROC
        cmp p0_x , 8
        jnz ValidatePlayer0Position_px_1
        mov p0_x , 0
    ValidatePlayer0Position_px_1:
        cmp p0_x , -1
        jnz ValidatePlayer0Position_py_0
        mov p0_x , 7
    ValidatePlayer0Position_py_0:
        cmp p0_y , 8
        jnz ValidatePlayer0Position_py_1
        mov p0_y , 0
    ValidatePlayer0Position_py_1:
        cmp p0_y , -1
        jnz ValidatePlayer0Position_py_2
        mov p0_y , 7
    ValidatePlayer0Position_py_2:
        ret
ValidatePlayer0Position ENDP

Player0_MoveUp PROC
    SendByte CURRENT_KEY_ASCII
    SendByte CURRENT_KEY_SCAN_CODE

        mov c , -1
        cmp PlayerColor , 0
        jz Player0_MoveUp_ss1
        mov c , 1
    Player0_MoveUp_ss1:
        add16 p0_y , c
        call ValidatePlayer0Position

        ret
Player0_MoveUp ENDP

Player0_MoveDown PROC
    SendByte CURRENT_KEY_ASCII
    SendByte CURRENT_KEY_SCAN_CODE

        mov c , 1
        cmp PlayerColor , 0
        jz Player0_MoveDown_ss1
        mov c , -1
    Player0_MoveDown_ss1:
        add16 p0_y , c
    
        call ValidatePlayer0Position
        
        ret
Player0_MoveDown ENDP

Player0_MoveLeft PROC
    SendByte CURRENT_KEY_ASCII
    SendByte CURRENT_KEY_SCAN_CODE

        mov c , -1
        cmp PlayerColor , 0
        jz Player0_MoveLeft_ss1
        mov c , 1
    Player0_MoveLeft_ss1:
        add16 p0_x , c

        call ValidatePlayer0Position
        
        ret
Player0_MoveLeft ENDP

Player0_MoveRight PROC
    SendByte CURRENT_KEY_ASCII
    SendByte CURRENT_KEY_SCAN_CODE

        mov c , 1
        cmp PlayerColor , 0
        jz Player0_MoveRight_ss1
        mov c , -1
    Player0_MoveRight_ss1:
        add16 p0_x , c

        call ValidatePlayer0Position
        
        ret
Player0_MoveRight ENDP

Player0_Pickup PROC
    SendByte CURRENT_KEY_ASCII
    SendByte CURRENT_KEY_SCAN_CODE

        GetPieceAt p0_x , p0_y
        mov ah , GET_PIECE_RESULT
        cmp ah , 00h
        jz Player0_Pickup_EXIT
        SHR ah , 4
        and ah , 1
        xor ah , PlayerColor
        jnz Player0_Pickup_EXIT

        mov ax, p0_y
        mov bx, 16
        mul bx
        mov bx , ax
        add bx , p0_x
        add bx , p0_x
        add bx , OFFSET PIECES_COOLDOWNS
        mov ax , [bx]
        cmp ax , 0
        jg Player0_Pickup_EXIT
        
        mov16 p0_from_x , p0_x
        mov16 p0_from_y , p0_y
    Player0_Pickup_EXIT:
        ret
Player0_Pickup ENDP

Player0_Do_Move PROC
    SendByte CURRENT_KEY_ASCII
    SendByte CURRENT_KEY_SCAN_CODE

        mov LAST_TAKEN_PIECE   ,  0
        mov LAST_MOVED_PIECE_X , -1
        mov LAST_MOVED_PIECE_Y , -1
        mov LAST_MOVED_PIECE   ,  0
        
        cmp p0_from_x , -1
        jz Player0_Do_Move_q_exit
        cmp p0_from_y , -1
        jz Player0_Do_Move_q_exit
        mov AX , offset ALLOWED_MOVES_PLAYER0
        mov HIGHLIGHT_ALLOWANCE_BUFFER , AX
        IsAllowedMove p0_x , p0_y
        cmp IS_ALLOWED_RESULT , 0
        jz Player0_Do_Move_q_exit

        jmp Player0_Do_Move_Exit_Skip
    Player0_Do_Move_q_exit:
        ret
    Player0_Do_Move_Exit_Skip:
        GetPieceAt p0_from_x , p0_from_y
        mov ah , GET_PIECE_RESULT
        mov al , ah
        and al , 00001111B
        cmp al , 01h ;a king piece
        jnz Player0_Do_Move_Skip_Castle_left
        
        mov cx , p0_from_x
        mov ax , p0_x
        sub cx , ax

        cmp cx , -2
        jnz Player0_Do_Move_Skip_Castle_left
        mov16 a , p0_from_x ;move the rock first 
        add a , 3
        mov16 b , p0_from_x
        add b , 1
        mov ax , 8
        mov bx , p0_from_y
        mul bx
        add ax , a
        mov si , ax

        mov ax , 8
        mov bx , p0_y
        mul bx
        add ax , b
        mov di , ax
        
        mov bh , CHESS_BOARD[si]
        mov CHESS_BOARD[di] , bh
        mov CHESS_BOARD[si] , 00h
        jmp Player0_Do_Move_Skip_Castle_right
    Player0_Do_Move_Skip_Castle_left:
        mov ah , GET_PIECE_RESULT
        mov al , ah
        and al , 00001111B
        cmp al , 01h ;a king piece
        jnz Player0_Do_Move_Skip_Castle_right

        mov cx , p0_from_x
        mov ax , p0_x
        sub cx , ax

        cmp cx , 2
        jnz Player0_Do_Move_Skip_Castle_right
        mov16 a , p0_from_x ;move the rock first 
        sub a , 4
        mov16 b , p0_from_x
        sub b , 1
        mov ax , 8
        mov bx , p0_from_y
        mul bx
        add ax , a
        mov si , ax

        mov ax , 8
        mov bx , p0_y
        mul bx
        add ax , b
        mov di , ax
        
        mov bh , CHESS_BOARD[si]
        mov CHESS_BOARD[di] , bh
        mov CHESS_BOARD[si] , 00h
    Player0_Do_Move_Skip_Castle_right:

        mov16 c , p0_from_x              ;set the offset
        sub16 c , p0_x
        mov16 d , p0_from_y
        sub16 d , p0_y
        
        mov ax, c
        mov bx, 25
        imul bx
        mov c , ax

        mov ax, d
        mov bx, 25
        imul bx
        mov d , ax

        mov ax , 32
        mov bx , p0_y
        mul bx
        mov bx , ax
        add bx , OFFSET PIECES_OFFSETS
        add bx , p0_x
        add bx , p0_x
        add bx , p0_x
        add bx , p0_x

        mov ax , c
        mov [bx] , ax
        add bx , 2
        mov ax , d
        mov [bx] , ax


        mov ax , 8
        mov bx , p0_from_y
        mul bx
        add ax , p0_from_x
        mov si , ax

        mov ax , 8
        mov bx , p0_y
        mul bx
        add ax , p0_x
        mov di , ax

        mov bh , CHESS_BOARD[si]
        mov bl , CHESS_BOARD[di]
        mov CHESS_BOARD[di] , bh
        mov CHESS_BOARD[si] , 00h
        mov p0_from_x , -1
        mov p0_from_y , -1

        mov   LAST_TAKEN_PIECE   , bl   ;prepare this for CheckPromotion Function
        mov16 LAST_MOVED_PIECE_X , p0_x 
        mov16 LAST_MOVED_PIECE_Y , p0_y
        mov   LAST_MOVED_PIECE   , bh

        mov ax , 16                     ;Set the cooldown
        mov bx , LAST_MOVED_PIECE_Y
        mul bx
        add ax , LAST_MOVED_PIECE_X
        add ax , LAST_MOVED_PIECE_X ; ax * sizeof(DW) thats why I add twice
        mov bx , ax
        add bx , OFFSET PIECES_COOLDOWNS
        mov ax , MOVE_COOLDOWN
        mov [bx] , ax
        
    Player0_Do_Move_Skip_Check_End:
        
        ;remove the castling attribute 
        mov ah , GET_PIECE_RESULT
        mov al , GET_PIECE_RESULT
        and al , 00001111B
        cmp al , 1
        jnz Player0_Do_Move_Exit
        SHR ah , 4
        and ah , 1
        cmp ah , 0
        jz Player0_Do_Move_remove_white_castle
        cmp ah , 1
        jz Player0_Do_Move_remove_black_castle
        ret
    Player0_Do_Move_remove_white_castle:
        mov WhiteCanCastle , 0
        ret
    Player0_Do_Move_remove_black_castle:
        mov BlackCanCastle , 0

    Player0_Do_Move_Exit:
        ret
Player0_Do_Move ENDP

Player1_Pickup PROC
        GetPieceAt p1_x , p1_y
        mov ah , GET_PIECE_RESULT
        cmp ah , 00h
        jz Player1_Pickup_EXIT
        SHR ah , 4
        AND ah , 1
        xor ah , PlayerColor
        cmp ah , 1
        jnz Player1_Pickup_EXIT

        mov ax, p1_y
        mov bx, 16
        mul bx
        mov bx , ax
        add bx , p1_x
        add bx , p1_x
        add bx , OFFSET PIECES_COOLDOWNS
        mov ax , [bx]
        cmp ax , 0
        jg Player1_Pickup_EXIT

        mov16 p1_from_x , p1_x
        mov16 p1_from_y , p1_y
    Player1_Pickup_EXIT:
        ret
Player1_Pickup ENDP

Player1_Do_Move PROC
        mov LAST_TAKEN_PIECE   ,  0
        mov LAST_MOVED_PIECE_X , -1
        mov LAST_MOVED_PIECE_Y , -1
        mov LAST_MOVED_PIECE   ,  0

        cmp p1_from_x , -1
        jz Player1_Do_Move_q_exit
        cmp p1_from_y , -1
        jz Player1_Do_Move_q_exit
        mov AX , offset ALLOWED_MOVES_PLAYER1
        mov HIGHLIGHT_ALLOWANCE_BUFFER , AX
        IsAllowedMove p1_x , p1_y
        cmp IS_ALLOWED_RESULT , 0
        jz Player1_Do_Move_q_exit

        jmp Player1_Do_Move_Exit_Skip
    Player1_Do_Move_q_exit:
        ret
    Player1_Do_Move_Exit_Skip:
        GetPieceAt p1_from_x , p1_from_y
        mov ah , GET_PIECE_RESULT
        mov al , ah
        and al , 00001111B
        cmp al , 01h ;a king piece
        jnz Player1_Do_Move_Skip_Castle_left
        
        mov cx , p1_from_x
        mov ax , p1_x
        sub cx , ax

        cmp cx , -2
        jnz Player1_Do_Move_Skip_Castle_left
        mov16 a , p1_from_x ;move the rock first 
        add a , 3
        mov16 b , p1_from_x
        add b , 1
        mov ax , 8
        mov bx , p1_from_y
        mul bx
        add ax , a
        mov si , ax

        mov ax , 8
        mov bx , p1_y
        mul bx
        add ax , b
        mov di , ax
        
        mov bh , CHESS_BOARD[si]
        mov CHESS_BOARD[di] , bh
        mov CHESS_BOARD[si] , 00h
        jmp Player1_Do_Move_Skip_Castle_right

    Player1_Do_Move_Skip_Castle_left:
        mov ah , GET_PIECE_RESULT
        mov al , ah
        and al , 00001111B
        cmp al , 01h ;a king piece
        jnz Player1_Do_Move_Skip_Castle_right

        mov cx , p1_from_x
        mov ax , p1_x
        sub cx , ax

        cmp cx , 2
        jnz Player1_Do_Move_Skip_Castle_right
        mov16 a , p1_from_x ;move the rock first 
        sub a , 4
        mov16 b , p1_from_x
        sub b , 1
        mov ax , 8
        mov bx , p1_from_y
        mul bx
        add ax , a
        mov si , ax

        mov ax , 8
        mov bx , p1_y
        mul bx
        add ax , b
        mov di , ax
        
        mov bh , CHESS_BOARD[si]
        mov CHESS_BOARD[di] , bh
        mov CHESS_BOARD[si] , 00h
        
    Player1_Do_Move_Skip_Castle_right:
        
        mov16 c , p1_from_x              ;set the offset
        sub16 c , p1_x
        mov16 d , p1_from_y
        sub16 d , p1_y
        
        mov ax, c
        mov bx, 25
        imul bx
        mov c , ax

        mov ax, d
        mov bx, 25
        imul bx
        mov d , ax

        mov ax , 32
        mov bx , p1_y
        mul bx
        mov bx , ax
        add bx , OFFSET PIECES_OFFSETS
        add bx , p1_x
        add bx , p1_x
        add bx , p1_x
        add bx , p1_x

        mov ax , c
        mov [bx] , ax
        add bx , 2
        mov ax , d
        mov [bx] , ax

        mov ax , 8
        mov bx , p1_from_y
        mul bx
        add ax , p1_from_x
        mov si , ax

        mov ax , 8
        mov bx , p1_y
        mul bx
        add ax , p1_x
        mov di , ax
        
        mov bh , CHESS_BOARD[si]
        mov bl , CHESS_BOARD[di]
        mov CHESS_BOARD[di] , bh
        mov CHESS_BOARD[si] , 00h
        mov p1_from_x , -1
        mov p1_from_y , -1

        mov   LAST_TAKEN_PIECE   , bl
        mov16 LAST_MOVED_PIECE_X , p1_x          ;prepare this for CheckPromotion Function
        mov16 LAST_MOVED_PIECE_Y , p1_y
        mov   LAST_MOVED_PIECE   , bh

        mov ax, 16
        mov bx, LAST_MOVED_PIECE_Y
        mul bx
        add ax , LAST_MOVED_PIECE_X
        add ax , LAST_MOVED_PIECE_X
        mov bx , ax
        add bx , OFFSET PIECES_COOLDOWNS
        mov ax , MOVE_COOLDOWN
        mov [bx] , ax

    Player1_Do_Move_Skip_Check_End:
        
        ;remove the castling attribute 
        mov ah , GET_PIECE_RESULT
        mov al , GET_PIECE_RESULT
        and al , 00001111B
        cmp al , 1
        jnz Player1_Do_Move_Exit
        SHR ah , 4
        and ah , 1
        cmp ah , 0
        jz Player1_Do_Move_remove_white_castle
        cmp ah , 1
        jz Player1_Do_Move_remove_black_castle
        ret
    Player1_Do_Move_remove_white_castle:
        mov WhiteCanCastle , 0
        ret
    Player1_Do_Move_remove_black_castle:
        mov BlackCanCastle , 0
    Player1_Do_Move_Exit:
        ret
Player1_Do_Move ENDP

;adds a taken piece to WHITE_TAKEN_PIECES or BLACK_TAKEN_PIECES
PushTakenPiece PROC
        mov ah , LAST_TAKEN_PIECE
        cmp ah , 0
        je PushTakenPiece_exit
        SHR ah , 4
        and ah , 1
        cmp ah , 1
        je PushTakenPiece_black
        mov BX , OFFSET WHITE_TAKEN_PIECES
        add BX , WHITE_TAKEN_PIECES_SIZE
        inc WHITE_TAKEN_PIECES_SIZE
        mov ah , LAST_TAKEN_PIECE
        mov [BX] , ah
        jmp PushTakenPiece_exit
    PushTakenPiece_black:
        mov BX , OFFSET BLACK_TAKEN_PIECES
        add BX , BLACK_TAKEN_PIECES_SIZE
        inc BLACK_TAKEN_PIECES_SIZE
        mov ah , LAST_TAKEN_PIECE
        mov [BX] , ah
    PushTakenPiece_exit:
        ret
PushTakenPiece ENDP

;pushes a message into the UI_MESSAGE buffer
int_push_message PROC
        mov BX , OFFSET UI_MESSAGES
        add BX , UI_MESSAGES_SIZE
        mov [BX] , ah
        inc BX
        mov [BX] , al
        add UI_MESSAGES_SIZE , 2 ; sizeof DW
        ret
int_push_message ENDP

;called after the last move , checks if there's a piece that need to be permoted
;notic I save the piece data in GET_PIECE_???? variables
;this functions should only edit registers ..
CheckPromotion PROC
        cmp LAST_MOVED_PIECE_Y , 0
        je CheckPromotion_Check0
        cmp LAST_MOVED_PIECE_Y , 7
        je CheckPromotion_Check0
        ret
    CheckPromotion_Check0:
        mov ah , LAST_MOVED_PIECE
        and ah , 0fh
        cmp ah , 06h
        je CheckPromotion_q_EXIT_SKIP
        ret
    CheckPromotion_q_EXIT_SKIP:
        mov16 a , LAST_MOVED_PIECE_X
        mov16 b , LAST_MOVED_PIECE_Y
        
        mov ax , a   ; convert the board x , y to screen x , y
        mov bx , 25  ; this is block size (200/8)
        mul bx
        mov a , ax

        mov ax , b   ; convert the board x , y to screen x , y
        mov bx , 25
        mul bx
        mov b , ax

        cmp PlayerColor , 01h ; are we black ?
        jnz CheckPromotion_skip_rot ; if we are white , then no need to rotate the board
        mov ax , a
        mov dx , b
        mov a , 200
        mov b , 200
        sub a , ax
        sub b , dx
        sub a , 25
        sub b , 25
    CheckPromotion_skip_rot:

        mov16 c , a
        mov16 d , b
        
        DrawRect promotion_color_L , c , d , 25 , 25
        add c , 25
        DrawRect promotion_color_D , c , d , 25 , 25
        add c , 25
        DrawRect promotion_color_L , c , d , 25 , 25
        add c , 25
        DrawRect promotion_color_D , c , d , 25 , 25

        mov ah , LAST_MOVED_PIECE
        SHR ah , 4
        and ah , 1
        cmp ah , 0
        je CheckPromotion_Draw_Whites ;relative jump out of range and shit ..
        jmp CheckPromotion_Draw_Blacks
    CheckPromotion_Draw_Whites:
        mov16 c , a
        mov16 d , b
        
        add c , 2
        add d , 2
        DrawImage white_queen , c , d , 20 , 20

        add c , 25
        DrawImage white_bishop , c , d , 20 , 20

        add c , 25
        DrawImage white_knight , c , d , 20 , 20

        add c , 25
        DrawImage white_rock , c , d , 20 , 20

        jmp CheckPromotion_Draw_Finish
    CheckPromotion_Draw_Blacks:
        mov16 c , a
        mov16 d , b
        
        add c , 2
        add d , 2
        DrawImage black_queen , c , d , 20 , 20

        add c , 25
        DrawImage black_bishop , c , d , 20 , 20

        add c , 25
        DrawImage black_knight , c , d , 20 , 20

        add c , 25
        DrawImage black_rock , c , d , 20 , 20

    CheckPromotion_Draw_Finish:
        DrawRect promotion_color_border , a , b , 100 , 1
        DrawRect promotion_color_border , a , b , 1 , 25
        add b , 24
        DrawRect promotion_color_border , a , b , 100 , 1
        sub b , 24
        add a , 99
        DrawRect promotion_color_border , a , b , 1 , 25
        
        ;SwapBuffers

    CheckPromotion_wait_for_piece:
        ;mov ax , 0
        ;int 16h
        ;cmp ah , 01h
        ;jng CheckPromotion_wait_for_piece
        ;cmp ah , 06h
        ;jnl CheckPromotion_wait_for_piece

        ;so the peice value was somehow equal to the scan code of the number which is lucky AF tbh xD
        ;I dont even need to add or delete anything form it just or-ing it with the color of the piece
        ;we're premoting should work fine
        ;you pick a piece by choosing 1,2,3,4 from the number row (not the numberbad)
        
        mov a1 , 02 ;stroing the value of the key cuz Im going to use AX for mul operation

        mov ax , 8
        mov bx , LAST_MOVED_PIECE_Y
        mul bx
        add ax , LAST_MOVED_PIECE_X
        mov di , ax

        mov ah , a1
        mov al , LAST_MOVED_PIECE
        and al , 0f0h
        or  ah , al   ; the acual piece value

        mov CHESS_BOARD[di] , ah

    CheckPromotion_EXIT:
        ret
CheckPromotion ENDP

 ;description
ValidatePlayer0FromLocation PROC
    GetPieceAt p0_from_x , p0_from_y
    mov ah , GET_PIECE_RESULT
    cmp ah , 0ffh ; out of board
    je ValidatePlayer0FromLocation_EXIT
    mov al , PlayerColor
    SHR ah , 4
    xor ah , al
    cmp ah , 0
    je ValidatePlayer0FromLocation_EXIT
    mov p0_from_x , -1
    mov p0_from_y , -1
    ValidatePlayer0FromLocation_EXIT:
    ret
ValidatePlayer0FromLocation ENDP

ValidatePlayer1FromLocation PROC
    GetPieceAt p1_from_x , p1_from_y
    mov ah , GET_PIECE_RESULT
    cmp ah , 0ffh ; out of board
    je ValidatePlayer1FromLocation_EXIT
    mov al , PlayerColor
    ;xor al , 1
    SHR ah , 4
    xor ah , al
    cmp ah , 1
    je ValidatePlayer1FromLocation_EXIT
    mov p1_from_x , -1
    mov p1_from_y , -1
    ValidatePlayer1FromLocation_EXIT:
    ret
ValidatePlayer1FromLocation ENDP

Switch_View PROC
    xor PlayerColor , 1
    mov p0_from_x , -1
    mov p0_from_y , -1
    mov p1_from_x , -1
    mov p1_from_y , -1
    ;mov CanCastle , 1   ;just a glich to re-enable castling 
    ret
Switch_View ENDP

;debug only ... delete the piece at p0_x , p0_y
Delete_Piece PROC
        mov ax , 8
        mov bx , p0_y
        mul bx
        add ax , p0_x
        mov di , ax
        mov CHESS_BOARD[di] , 00h
        ret
Delete_Piece ENDP


Force_Restart PROC
    
    ClearScreen 00h
    SwapBuffers

    SetCursor 0 , 0

    DispString TXT_FORCE_RESTART
    
    Force_Restart_loop:
        mov AX , 0100h
        INT 16h
        cmp AH , 1Ch ;Enter (the middle enter)
    jne Force_Restart_loop

    call ResetGame

    ret
Force_Restart ENDP

ToggleDebug PROC
    xor DEBUG_MODE , 1
    ret
ToggleDebug ENDP

EndGameLoop PROC
    mov BREAK_GAME_LOOP , 1
    SendByte 03Eh ;F4
    SendByte 03Eh
    ret
EndGameLoop ENDP

setEventHandlers PROC
    ;Disabled player 1 controlles for now

    ;AddKeyHandler 11h , Player1_MoveUp    ;w
    ;AddKeyHandler 1Eh , Player1_MoveLeft  ;a
    ;AddKeyHandler 1FH , Player1_MoveDown  ;s
    ;AddKeyHandler 20h , Player1_MoveRight ;d

    AddGlobalNetworkHandler NetworkReceiver

    AddKeyHandler 48h , Player0_MoveUp      ;arrow up
    AddKeyHandler 4Bh , Player0_MoveLeft    ;arrow left
    AddKeyHandler 50H , Player0_MoveDown    ;arrow down
    AddKeyHandler 4DH , Player0_MoveRight   ;arrow right

    AddKeyHandler 52H , Player0_Pickup       ;key '0'
    AddKeyHandler 4FH , Player0_Do_Move      ;key '1'
    
    AddKeyHandler 4FH , ValidatePlayer1FromLocation      ;key '1'
    
    ;AddKeyHandler 2cH , Player1_Pickup       ;key 'z'
    ;AddKeyHandler 2dH , Player1_Do_Move      ;key 'x'
    ;AddKeyHandler 2dH , ValidatePlayer0FromLocation      ;key 'x'

    ;AddKeyHandler 2dH , CheckPromotion      ;key 'x'
    AddKeyHandler 4fH , CheckPromotion       ;key '1'
    ;AddKeyHandler 2dH , PushTakenPiece      ;key 'x'
    AddKeyHandler 4fH , PushTakenPiece       ;key '1'
    
    ;AddKeyHandler 4EH , Switch_View        ;key '+'
    ;AddKeyHandler 53H , Delete_Piece        ;key 'Del'
    ;AddKeyHandler 0EH , Force_Restart      ;key 'backspace'
    AddKeyHandler 03EH  , EndGameLoop        ;F4

    ;AddKeyHandler 4AH  , ToggleDebug      ; '-'
    AddKeyHandler 03DH  , ToggleChat       ; F3

    AddGlobalKeyHandler Player0ChatTxtHandler
    AddGlobalKeyHandler GlobalKeyEventHandler
    ret
setEventHandlers ENDP

NetworkReceiver PROC
        cmp NETWORK_POS , 1
        je NetworkReceiver_triggered
        mov8 NETWORK_ASCII , N_CURRENT_BYTE
        mov NETWORK_POS , 1
        ret
    NetworkReceiver_triggered:
        mov8 NETWORK_SCAN_CODE , N_CURRENT_BYTE
        mov8 CURRENT_KEY_ASCII , NETWORK_ASCII
        mov8 CURRENT_KEY_SCAN_CODE , NETWORK_SCAN_CODE

        cmp NETWORK_SCAN_CODE , 48h
        jz __p1_down
        cmp NETWORK_SCAN_CODE , 4Bh
        jz __p1_right
        cmp NETWORK_SCAN_CODE , 50h
        jz __p1_up
        cmp NETWORK_SCAN_CODE , 4Dh
        jz __p1_left
        cmp NETWORK_SCAN_CODE , 52h
        jz __p1_pick
        cmp NETWORK_SCAN_CODE , 4Fh
        jz __p1_move
        cmp NETWORK_SCAN_CODE , 03EH ;exit key F4
        jz __end_game
        cmp NETWORK_SCAN_CODE , 03DH ;open chat key F3
        jz NetworkReceiver__exit

        jmp __chat_key
    __p1_up:
        call Player1_MoveUp
        jmp NetworkReceiver__exit
    __p1_left:
        call Player1_MoveLeft
        jmp NetworkReceiver__exit
    __p1_down:
        call Player1_MoveDown
        jmp NetworkReceiver__exit
    __p1_right:
        call Player1_MoveRight
        jmp NetworkReceiver__exit
    __p1_pick:
        call Player1_Pickup
        jmp NetworkReceiver__exit
    __p1_move:
        call Player1_Do_Move
        call CheckPromotion
        call PushTakenPiece
        jmp NetworkReceiver__exit

    __end_game:
        mov BREAK_GAME_LOOP , 1 
        jmp NetworkReceiver__exit

    __chat_key:
        call Player1ChatTxtHandler

    NetworkReceiver__exit:
        mov NETWORK_POS , 0
        mov ui_invalidate , 1
    ret
NetworkReceiver ENDP

;just sets the ui flag to 1 when ever a key is pressed
;and send the current key to th other device
GlobalKeyEventHandler PROC
    mov ui_invalidate , 1
    ;SendByte CURRENT_KEY_ASCII
    ;SendByte CURRENT_KEY_SCAN_CODE
    ret
GlobalKeyEventHandler ENDP

;resets all game attributes
ResetGame PROC
    ClearStatusArea
    ClearAllInputHandlers
    ClearAllNetworkHandlers
    call setEventHandlers

    MemSet PIECES_OFFSETS , 256 , 00h
    
    MemSet CHESS_BOARD , 64 , 00h
    mov CHESS_BOARD[0] , 15h
    mov CHESS_BOARD[1] , 14h
    mov CHESS_BOARD[2] , 13h
    mov CHESS_BOARD[3] , 12h
    mov CHESS_BOARD[4] , 11h
    mov CHESS_BOARD[5] , 13h
    mov CHESS_BOARD[6] , 14h
    mov CHESS_BOARD[7] , 15h
    mov CHESS_BOARD[8]  , 16h
    mov CHESS_BOARD[9]  , 16h
    mov CHESS_BOARD[10] , 16h
    mov CHESS_BOARD[11] , 16h
    mov CHESS_BOARD[12] , 16h
    mov CHESS_BOARD[13] , 16h
    mov CHESS_BOARD[14] , 16h
    mov CHESS_BOARD[15] , 16h

    mov CHESS_BOARD[48] , 06h
    mov CHESS_BOARD[49] , 06h
    mov CHESS_BOARD[50] , 06h
    mov CHESS_BOARD[51] , 06h
    mov CHESS_BOARD[52] , 06h
    mov CHESS_BOARD[53] , 06h
    mov CHESS_BOARD[54] , 06h
    mov CHESS_BOARD[55] , 06h
    mov CHESS_BOARD[56] , 05h
    mov CHESS_BOARD[57] , 04h
    mov CHESS_BOARD[58] , 03h
    mov CHESS_BOARD[59] , 02h
    mov CHESS_BOARD[60] , 01h
    mov CHESS_BOARD[61] , 03h
    mov CHESS_BOARD[62] , 04h
    mov CHESS_BOARD[63] , 05h

    mov p0_from_x , -1
    mov p1_from_x , -1

    cmp PlayerColor , 0
    jne _black_settings
        mov p0_x , 4
        mov p0_y , 4
        mov p1_x , 3
        mov p1_y , 3
    jmp _white_settings
    _black_settings:
        mov p0_x , 3
        mov p0_y , 3
        mov p1_x , 4
        mov p1_y , 4
    _white_settings:

    mov WhiteCanCastle , 1
    mov BlackCanCastle , 1

    mov WHITE_TAKEN_PIECES_SIZE , 0
    mov BLACK_TAKEN_PIECES_SIZE , 0

    mov GAME_RUNNING , 1

    mov LAST_MOVED_PIECE , 0    ;must reset these values too.
    mov LAST_TAKEN_PIECE , 0
    mov LAST_MOVED_PIECE_X , -1
    mov LAST_MOVED_PIECE_Y , -1

    mov BREAK_GAME_LOOP , 0

    MemSet PIECES_COOLDOWNS , 128 , 00h ; clear the cooldowns

    mov ui_invalidate , 1
    mov NETWORK_POS , 0
    mov CHAT_MY_TXT_SiZE , 0
    mov CHAT_OUT_TXT_SiZE , 0

    ret
ResetGame ENDP

;toggles the chat view
ToggleChat PROC
    xor ui_chat_visible , 1
    ret
ToggleChat ENDP
;draws the ui before swaping the buffer
DrawUiBefore PROC
    cmp ui_invalidate , 1
    je DrawUiBefore_submit
    ret
    DrawUiBefore_submit:

    DrawRect ui_background_color , 202 , 5 , 116 , 50
    DrawRect ui_border_color , 202 , 5  , 116 , 1 
    DrawRect ui_border_color , 202 , 5  , 1 , 50
    DrawRect ui_border_color , 202 , 54 , 116 , 1 
    DrawRect ui_border_color , 317 , 5  , 1 , 50
    
        mov c , 0
        mov a , 203
        mov b , 8
    DrawUiBefore_White_pieces_loop:
        cmp16 c , WHITE_TAKEN_PIECES_SIZE
        je DrawUiBefore_White_pieces_loop_end
        mov bx , OFFSET WHITE_TAKEN_PIECES
        add bx , c
        GetPieceImageByCode [BX]
        DrawImageTentedImd CONVERT_PIECE_IMAGE_OFFSET , ui_piece_shadow_white_color , a , b , 20 , 20
        inc a
        inc a
        DrawImageImd CONVERT_PIECE_IMAGE_OFFSET , a , b , 20 , 20
        add a , 4
        inc c 
        jmp DrawUiBefore_White_pieces_loop
    DrawUiBefore_White_pieces_loop_end:

        mov c , 0
        mov a , 203
        mov b , 32


    DrawUiBefore_Black_pieces_loop:
        cmp16 c , BLACK_TAKEN_PIECES_SIZE
        je DrawUiBefore_Black_pieces_loop_end
        mov bx , OFFSET BLACK_TAKEN_PIECES
        add bx , c
        GetPieceImageByCode [BX]
        DrawImageTentedImd CONVERT_PIECE_IMAGE_OFFSET , ui_piece_shadow_black_color , a , b , 20 , 20
        inc a
        inc a
        DrawImageImd CONVERT_PIECE_IMAGE_OFFSET , a , b , 20 , 20
        add a , 4
        inc c 
        jmp DrawUiBefore_Black_pieces_loop
    DrawUiBefore_Black_pieces_loop_end:

    ; the status area frame..
    DrawRect ui_border_color , 202 , 60  , 116 , 1 
    DrawRect ui_border_color , 202 , 60  , 1 , 134
    DrawRect ui_border_color , 202 , 194 , 116 , 1 
    DrawRect ui_border_color , 317 , 60  , 1 , 134
    
    cmp ui_chat_visible , 0 ;chat is visible , draw its frame
    jne DrawUiBefore_q_exit_skip
        ret
    DrawUiBefore_q_exit_skip:

    DrawRect ui_chat_background , 202 , 5 , 116 , 190
    DrawRect ui_chat_borders , 202 , 5  , 116 , 1 
    DrawRect ui_chat_borders , 202 , 5  , 1 , 190
    DrawRect ui_chat_borders , 202 , 194 , 116 , 1 
    DrawRect ui_chat_borders , 317 , 5  , 1 , 190
    
    DrawUiBefore_EXIT:

    ret
DrawUiBefore ENDP

;calcualtes the amount of blocks for a king at block a,b
calculate_safe_blocks_for_ab PROC
        GetPieceAt a , b
        mov ah , GET_PIECE_RESULT
        SHR ah , 4
        and ah , 1
        cmp ah , 1
        je calculate_safe_blocks_for_ab_SET_BLACK_KING
        mov BX , OFFSET BLACK_BLOCKS
        jmp calculate_safe_blocks_for_ab_calc
    calculate_safe_blocks_for_ab_SET_BLACK_KING:
        mov BX , OFFSET WHITE_BLOCKS
    calculate_safe_blocks_for_ab_calc:
        mov HIGHLIGHT_ALLOWANCE_BUFFER , BX
        mov c , 0
        mov d , 0
        
        IsAllowedMove a , b
        mov ah , 0
        mov al , IS_ALLOWED_RESULT
        add c , ax ; if c == 1 this means a check on that king is happenning
        add d , ax
        
        add b , 0
        add a , 1
        IsAllowedMove a , b
        mov ah , 0
        mov al , IS_ALLOWED_RESULT
        add d , ax

        add b , 1
        add a , 0
        IsAllowedMove a , b
        mov ah , 0
        mov al , IS_ALLOWED_RESULT
        add d , ax

        add b , 0
        add a , -1
        IsAllowedMove a , b
        mov ah , 0
        mov al , IS_ALLOWED_RESULT
        add d , ax

        add b , 0
        add a , -1
        IsAllowedMove a , b
        mov ah , 0
        mov al , IS_ALLOWED_RESULT
        add d , ax

        add b , -1
        add a , 0
        IsAllowedMove a , b
        mov ah , 0
        mov al , IS_ALLOWED_RESULT
        add d , ax

        add b , -1
        add a , 0
        IsAllowedMove a , b
        mov ah , 0
        mov al , IS_ALLOWED_RESULT
        add d , ax

        add b , 0
        add a , 1
        IsAllowedMove a , b
        mov ah , 0
        mov al , IS_ALLOWED_RESULT
        add d , ax

        add b , 0
        add a , 1
        IsAllowedMove a , b
        mov ah , 0
        mov al , IS_ALLOWED_RESULT
        add d , ax

        ret
calculate_safe_blocks_for_ab ENDP

;checks for mates , kings checks , etc ...
check_game_status PROC
        cmp GAME_RUNNING , 1
        jne check_game_status_quick_exit
        jmp check_game_status_quick_exit_skip
    check_game_status_quick_exit:
        ret
    check_game_status_quick_exit_skip:
        ;check for checkmats first
        mov ah , LAST_TAKEN_PIECE
        and ah , 0fh
        cmp ah , 01h
        jne check_game_status_check_for_checks
        ;last piece was indead a king
        ClearAllInputHandlers
        AddKeyHandler 21h , EndGameLoop
        mov GAME_RUNNING , 0
        mov ui_chat_visible , 0

        mov ah , LAST_TAKEN_PIECE
        SHR ah , 4
        and ah , 1
        cmp ah , 1
        je check_game_status_black_dead
        PushMessage TXT_BLACK_WON
        PushMessage TXT_TO_RESTART
        ret
    check_game_status_black_dead:
        PushMessage TXT_WHITE_WON
        PushMessage TXT_TO_RESTART
        ret
    check_game_status_check_for_checks:
        ClearStatusArea
        ;now we need to check for chicks and checkmates
        ;my idea is that we iterate over the entier board and check how many blocks is safe for each king
        mov a1 , 0
        mov b1 , 0
    check_game_status_looper:
        mov ah , 0
        mov al , a1
        mov a , ax
        mov al , b1
        mov b , ax
        GetPieceAt a , b
        mov ah , GET_PIECE_RESULT
        mov d1 , ah
        and ah , 0fh
        cmp ah , 01h
        je check_game_status_looper_king_found
    check_game_status_looper_next:
        inc a1
        cmp a1 , 8
        jne check_game_status_looper
        inc b1
        mov a1 , 0
        cmp b1 , 8
        jne check_game_status_looper
        jmp check_game_status_looper_exit
    check_game_status_looper_king_found:
        call calculate_safe_blocks_for_ab
        mov e , 0
        add16 e , c ;c is the block of the king , 1 --> not safe , 0 --> safe
        add16 e , d ;d is the blocks around the king , 8 --> all of them are not safe
        ;cmp e , 9
        ;je check_game_status_looper_mate ; mate is treky to implement because you have to consider all the possible moves by you're own pieces
                                          ; that can protect you're king , its do-able , but Im too lazy to do it rn and I want to sleep :')
        cmp c , 1
        jne check_game_status_looper_next ;no check , go to the next piece
        mov ah , d1
        SHR ah , 4
        and ah , 1
        cmp ah , 1
        je check_game_status_looper_check_black
        PushMessage TXT_CHECK_WHITE
        jmp check_game_status_looper_next
    check_game_status_looper_check_black:
        PushMessage TXT_CHECK_BLACK
        jmp check_game_status_looper_next
    ; check_game_status_looper_mate:
    ;     mov ah , d1
    ;     SHR ah , 4
    ;     and ah , 1
    ;     cmp ah , 1
    ;     je check_game_status_looper_mate_black
    ;     PushMessage TXT_MATE_WHITE
    ;     jmp check_game_status_looper_next
    ; check_game_status_looper_mate_black:
    ;     PushMessage TXT_MATE_BLACK
    ;     jmp check_game_status_looper_next
    check_game_status_looper_exit:
        ret
check_game_status ENDP

;draws the texts and other stuff after the buffer has been swaped
DrawUiAfter PROC
        cmp ui_invalidate , 1
        je DrawUiAfter_submit
        ret
    DrawUiAfter_submit:

        mov a , 0
        mov a1 , 9  ; raw
        mov b1 , 26 ; column
    DrawUiAfter_looper:
        cmp16 a , UI_MESSAGES_SIZE
        je DrawUiAfter_Status_exit
        cmp ui_chat_visible , 1
        je DrawUiAfter_Status_exit

        mov BX , OFFSET UI_MESSAGES
        add BX , a
        SetCursor a1 , b1
        mov DH , [BX]
        inc BX
        mov DL , [BX]
        mov AX , 0900h
        INT 21h
        add a , 2
        inc a1
        jmp DrawUiAfter_looper
    DrawUiAfter_Status_exit:
        ;now draw the chat
        cmp ui_chat_visible , 1
        je DrawUiAfter_chat_qexit_skip
        ret
    DrawUiAfter_chat_qexit_skip:
        SetCursor 1 , 26
        mov DI , OFFSET PlayerName
        add DI , 1
        mov al , ds:[DI]
        mov ah , 0
        mov a , ax
        add DI , 1
        DispMuliCharColored a , 02h

        SetCursor 12 , 26
        mov DI , OFFSET OtherPlayerName
        add DI , 1
        mov al , ds:[DI]
        mov ah , 0
        mov a , ax
        add DI , 1
        DispMuliCharColored a , 02h

        ;now draw the chat text
    DrawUiAfter_chat_me_txt: ; I draw char by char
        mov a1 , 2
        mov b1 , 26
        mov a , 0
        mov b , 0
        mov c , 0
    DrawUiAfter_chat_me_txt_looper:
        cmp16 a , CHAT_MY_TXT_SiZE
        je DrawUiAfter_chat_out_txt
        SetCursor a1 , b1
        mov ah , 2
        mov bx , OFFSET CHAT_MY_TXT
        add bx , c
        mov dl , [BX]
        int 21h

        inc c
        inc a
        inc b
        inc b1
        cmp b , 13 ;devide line every 13 chars
        jne DrawUiAfter_chat_me_txt_looper
        mov b , 0
        inc a1
        mov b1 , 26
        jmp DrawUiAfter_chat_me_txt_looper
    DrawUiAfter_chat_out_txt:
        cmp a1 , 12
        je DrawUiAfter_chat_out_txt_skip_cursor
        SetCursor a1 , b1
        mov ah , 2
        mov dl , '_'
        int 21h
    DrawUiAfter_chat_out_txt_skip_cursor:
        mov a1 , 13
        mov b1 , 26
        mov a , 0
        mov b , 0
        mov c , 0
    DrawUiAfter_chat_out_txt_looper:
        cmp16 a , CHAT_OUT_TXT_SiZE
        je DrawUiAfter_chat_exit
        SetCursor a1 , b1
        mov ah , 2
        mov bx , OFFSET CHAT_OUT_TXT
        add bx , c
        mov dl , [BX]
        int 21h
        
        inc c
        inc a
        inc b
        inc b1
        cmp b , 13 ;devide line every 13 chars
        jne DrawUiAfter_chat_out_txt_looper
        mov b , 0
        inc a1
        mov b1 , 26
        jmp DrawUiAfter_chat_out_txt_looper

    DrawUiAfter_chat_exit:
        ret
DrawUiAfter ENDP

;pushes one letter to the chat buffer
;set CHAT_PUSH_BUFFER , CHAT_PUSH_BUFFER_SIZE , CHAT_PUSH_CHAR before calling
push_chat_letter PROC
        mov DI , CHAT_PUSH_BUFFER
        mov SI , CHAT_PUSH_BUFFER_SIZE

        cmp CHAT_PUSH_CHAR_SC , 1CH ;new line
        je push_chat_letter_n_line
        cmp CHAT_PUSH_CHAR_SC , 0EH ;back space
        jne push_chat_normal_normal
        mov AX , 0
        cmp [SI] , AX
        je push_chat_letter_q_exit
        mov AX , 1
        sub [SI] , AX
    push_chat_letter_q_exit:
        ret
    push_chat_normal_normal:
        ;normal push here.
        mov AX , CHAT_BUFFER_MAX_SIZE
        cmp [SI] , AX
        jne push_chat_normal_skip_scroll
        mov AX , CHAT_LINE_SIZE
        sub [SI] , AX ;remove the first line
        mov BX , DI
        mov a , 0
        mov16 b , CHAT_BUFFER_MAX_SIZE
        sub16 b , CHAT_LINE_SIZE ;limiter
    push_chat_normal_scroll_next:
        cmp16 a , b
        je push_chat_normal_skip_scroll
        add BX , CHAT_LINE_SIZE
        mov AH , [BX]
        sub BX , CHAT_LINE_SIZE
        mov [BX] , AH
        inc BX
        inc a
        jmp push_chat_normal_scroll_next
    push_chat_normal_skip_scroll:
        mov ah , CHAT_PUSH_CHAR
        mov BX , DI
        add BX , [SI]
        mov [BX] , ah
        mov AX , 1
        add [SI] , AX
        ret
    push_chat_letter_n_line:
        mov AX , CHAT_BUFFER_MAX_SIZE
        sub AX , CHAT_LINE_SIZE
        sub AX , 1 ;#it_works_dont_touch_it
        cmp [SI] , AX
        jng push_chat_letter_n_line_fill_white_looper
        
        mov AX , CHAT_LINE_SIZE
        sub [SI] , AX ;remove the first line
        mov BX , DI
        mov a , 0
        mov16 b , CHAT_BUFFER_MAX_SIZE
        sub16 b , CHAT_LINE_SIZE ;limiter
    push_chat_letter_n_line_filled_buffer:
        cmp16 a , b
        je push_chat_letter_n_line_fill_white_looper
        add BX , CHAT_LINE_SIZE
        mov AH , [BX]
        sub BX , CHAT_LINE_SIZE
        mov [BX] , AH
        inc BX
        inc a
        jmp push_chat_letter_n_line_filled_buffer
    push_chat_letter_n_line_fill_white_looper:
        mov dx, 0
        mov ax, [SI]
        mov bx, CHAT_LINE_SIZE
        div bx
        mov bx , CHAT_LINE_SIZE
        sub bx , dx 
        mov dx , bx ;dx now contains the number of white spaces to add

        mov ah , ' '
        mov bx , DI
        add bx , [SI]
        mov [bx] , ah
        mov ax , 1
        add [SI] , ax
        dec dx
        cmp dx , 0
        jne push_chat_letter_n_line_fill_white_looper

        ret
push_chat_letter ENDP

Player0ChatTxtHandler PROC
    ;now we just need to fliter the chars
    cmp ui_chat_visible , 1        ;if the chat is not open , then ignore this key
    jne Player0ChatTxtHandler_exit

    cmp CURRENT_KEY_ASCII , 20h
    jl Player0ChatTxtHandler_check_symbols
    cmp CURRENT_KEY_ASCII , 7Dh
    jg Player0ChatTxtHandler_check_symbols
    
    cmp CURRENT_KEY_SCAN_CODE , 48h ;input keys shouldn't be added to the buffer ..
    je Player0ChatTxtHandler_exit
    cmp CURRENT_KEY_SCAN_CODE , 4Bh
    je Player0ChatTxtHandler_exit
    cmp CURRENT_KEY_SCAN_CODE , 50H
    je Player0ChatTxtHandler_exit
    cmp CURRENT_KEY_SCAN_CODE , 4DH
    je Player0ChatTxtHandler_exit
    cmp CURRENT_KEY_SCAN_CODE , 52H
    je Player0ChatTxtHandler_exit
    cmp CURRENT_KEY_SCAN_CODE , 4FH
    je Player0ChatTxtHandler_exit
    
    jmp Player0ChatTxtHandler_submit
Player0ChatTxtHandler_check_symbols:
    cmp CURRENT_KEY_SCAN_CODE , 1CH ; Enter & Backspace .. special keys
    je Player0ChatTxtHandler_submit
    cmp CURRENT_KEY_SCAN_CODE , 0EH ;
    je Player0ChatTxtHandler_submit

Player0ChatTxtHandler_exit:
    ret
Player0ChatTxtHandler_submit:
    SendByte CURRENT_KEY_ASCII
    SendByte CURRENT_KEY_SCAN_CODE

    mov bx , OFFSET CHAT_MY_TXT
    mov CHAT_PUSH_BUFFER , bx
    mov bx , OFFSET CHAT_MY_TXT_SiZE
    mov CHAT_PUSH_BUFFER_SIZE , bx
    mov8 CHAT_PUSH_CHAR , CURRENT_KEY_ASCII
    mov8 CHAT_PUSH_CHAR_SC , CURRENT_KEY_SCAN_CODE
    mov CHAT_BUFFER_MAX_SIZE , 130
    mov CHAT_LINE_SIZE       , 13
    call push_chat_letter
    ret
Player0ChatTxtHandler ENDP

Player1ChatTxtHandler PROC
    ;now we just need to fliter the chars
    cmp CURRENT_KEY_ASCII , 20h
    jl Player1ChatTxtHandler_check_symbols
    cmp CURRENT_KEY_ASCII , 7Dh
    jg Player1ChatTxtHandler_check_symbols
    jmp Player1ChatTxtHandler_submit
Player1ChatTxtHandler_check_symbols:
    cmp CURRENT_KEY_SCAN_CODE , 1CH ; Enter & Backspace .. special keys
    je Player1ChatTxtHandler_submit
    cmp CURRENT_KEY_SCAN_CODE , 0EH ;
    je Player1ChatTxtHandler_submit
    
Player1ChatTxtHandler_exit:
    ret
Player1ChatTxtHandler_submit:
    mov bx , OFFSET CHAT_OUT_TXT
    mov CHAT_PUSH_BUFFER , bx
    mov bx , OFFSET CHAT_OUT_TXT_SiZE
    mov CHAT_PUSH_BUFFER_SIZE , bx
    mov8 CHAT_PUSH_CHAR , CURRENT_KEY_ASCII
    mov8 CHAT_PUSH_CHAR_SC , CURRENT_KEY_SCAN_CODE
    call push_chat_letter
    ret
Player1ChatTxtHandler ENDP

;updates the pieces times.
UpdatePiecesTime PROC
        mov a , 0
        mov b , 0
    UpdateTime_looper:
        mov ax , 16
        mov bx , b
        mul bx
        add ax , a
        add ax , a
        ; ax * 2
        mov bx , OFFSET PIECES_COOLDOWNS
        add bx , ax
        mov ax , [bx]
        cmp ax , 1 
        jl UpdateTime_looper_next
        sub ax , FRAME_TIME
        mov [BX] , ax
    UpdateTime_looper_next:
        inc a
        cmp a , 8
        jne UpdateTime_looper
        mov a , 0
        inc b
        cmp b , 8
        jne UpdateTime_looper
        
        mov ax , 0f0fh

        ret
UpdatePiecesTime ENDP

;moves ax to zero based on the delta time
;uses c , d , e
InterpolateForOffset PROC
    mov c , ax
    cmp ax , 0
    jg InterpolateForOffset_positive
    jl InterpolateForOffset_negative
    ret
InterpolateForOffset_positive:
    mov ax, PIECES_SPEED
    mov bx, FRAME_TIME
    mul bx
    mov bx, PEICE_SPEED_DEVISOR
    div bx
    sub c , ax
    mov ax , c
    cmp ax , 0
    jg InterpolateForOffset_positive_cs
    mov ax , 0
InterpolateForOffset_positive_cs:
    ret
InterpolateForOffset_negative:
    mov ax, PIECES_SPEED
    mov bx, FRAME_TIME
    mul bx
    mov bx, PEICE_SPEED_DEVISOR
    div bx
    add c , ax
    mov ax , c
    cmp ax , 0
    jl InterpolateForOffset_negative_cs
    mov ax , 0
InterpolateForOffset_negative_cs:
    ret
InterpolateForOffset ENDP

UpdatePiecesOffset PROC
        mov a , 0
        mov b , 0
    UpdatePiecesOffset_Row:
        mov ax, b
        mov bx, 32
        mul bx
        mov bx , ax
        add bx , a
        add bx , a
        add bx , a
        add bx , a
        add bx , OFFSET PIECES_OFFSETS
        mov SI , bx ;safe it for later ..
        mov ax , [BX]
        cmp ax , 0
        je UpdatePiecesOffset_item_y
        call InterpolateForOffset
        mov BX , SI
        mov [BX] , ax
    UpdatePiecesOffset_item_y:
        add BX , 2
        mov ax , [BX]
        cmp ax , 0
        je UpdatePiecesOffset_Next
        call InterpolateForOffset
        mov BX , SI
        add BX , 2
        mov [BX] , ax
    UpdatePiecesOffset_Next:
        inc a
        cmp a , 8
        je UpdatePiecesOffset_Next_Row
        jmp UpdatePiecesOffset_Row
    UpdatePiecesOffset_Next_Row:
        mov a , 0
        inc b
        cmp b , 8
        je UpdatePiecesOffset_Exit
        jmp UpdatePiecesOffset_Row

    UpdatePiecesOffset_Exit:
        ret
UpdatePiecesOffset ENDP

;Main function
ChessGame PROC 
        mov ah,0
        mov al,13h
        int 10h			;switch to 320x200 mode
        
        
        call ResetGame

    __t: ; game-loop

        UpdateInputs        ; not that this function must be called before ClearScreen or after the Screen drawing becuase if promotion happened
                            ; we call SwapBuffers

        UpdateNetwork       ; check for network updates
        
        dec NETWORK_IDEL_FRAMES
        cmp NETWORK_IDEL_FRAMES , 0
        jne __t__skip_sending
        mov NETWORK_IDEL_FRAMES , 2 ;only send one byte every 3 frames
        FlushNetworkOneByte 
        __t__skip_sending:

        ClearScreen 00h ; clear the screen and fill it with black color
        
        call Draw_Board

        HighlightBlock p1_from_color , p1_from_x , p1_from_y , 7 , 2 ;draw player 1 cursors
        HighlightBlock p1_color , p1_x , p1_y , 7 , 3
        HighlightBlock p0_from_color , p0_from_x , p0_from_y , 7 , 2 ;draw player 0 cursors 
        HighlightBlock p0_color , p0_x , p0_y , 7 , 2

        
        cmp GAME_RUNNING , 0
        je ChessGame_SKip_Game_Logic ;if the game is not running then skip updateing the game logic ..
        
        ;game logic
        ClearAllowedMoves ;reset the state of the moves buffers
        mov16 CURRENT_PIECE_X , p0_from_x                       ;Draw the allowed moves for player 0
        mov16 CURRENT_PIECE_Y , p0_from_y
        mov BX , offset ALLOWED_MOVES_PLAYER0
        mov HIGHLIGHT_ALLOWANCE_WHITE_BUFFER , BX
        mov HIGHLIGHT_ALLOWANCE_BLACK_BUFFER , BX
        call DrawMovementHighlights

        mov16 CURRENT_PIECE_X , p1_from_x                       ;Draw the allowed moves for player 1
        mov16 CURRENT_PIECE_Y , p1_from_y
        mov BX , offset ALLOWED_MOVES_PLAYER1
        mov HIGHLIGHT_ALLOWANCE_WHITE_BUFFER , BX
        mov HIGHLIGHT_ALLOWANCE_BLACK_BUFFER , BX
        call DrawMovementHighlights

        call Update_BW_Moves
        call check_game_status
        
    ChessGame_SKip_Game_Logic:
        
        call UpdatePiecesTime
        call UpdatePiecesOffset

        ;Ui
        call DrawUiBefore
        call debug_draw_avalaible_moves
        call debug_draw_bw_moves
        
        SwapRect 0 , 0 , 200 , 200 ;board rect
        cmp ui_invalidate , 1
        jne ChessGame_SKip_UI_Rendering
        
        SwapRect 200 , 0 , 120 , 200 ;board rect
        call DrawUiAfter

        mov ui_invalidate , 0
        
    ChessGame_SKip_UI_Rendering:
        cmp BREAK_GAME_LOOP , 1
        je __t_end
        jmp __t

    __t_end:
        FlushNetworkOneByte ;extra fluhes wouldn't do any harm..
        UpdateNetwork
        Sleep 10
        cmp NETWORK_OUT_BYTE_SIZE , 0
        jne __t_end

        ClearAllInputHandlers ;cansel any key events ...
        ClearAllNetworkHandlers
        ret
ChessGame ENDP


ChatGameNetworkLoader PROC
    cmp CHAT_ONLY_NETWORK_CURRENT_BYTE , 0
    jne ChatGameNetworkLoader_nd_byte
    mov8 e1 , N_CURRENT_BYTE
    mov CHAT_ONLY_NETWORK_CURRENT_BYTE , 1
    ret
ChatGameNetworkLoader_nd_byte:
    mov CHAT_ONLY_NETWORK_CURRENT_BYTE , 0

    mov bx , OFFSET CHAT_ONLY_OTHER_TEXT
    mov CHAT_PUSH_BUFFER , bx
    mov bx , OFFSET CHAT_ONLY_OTHER_TEXT_S
    mov CHAT_PUSH_BUFFER_SIZE , bx
    mov8 CHAT_PUSH_CHAR , e1
    mov8 CHAT_PUSH_CHAR_SC , N_CURRENT_BYTE
    mov CHAT_BUFFER_MAX_SIZE , 800
    mov CHAT_LINE_SIZE       , 80
    call push_chat_letter
    mov CHAT_ONLY_INVALIDATE , 1

    cmp N_CURRENT_BYTE , 01h
    jne ChatGameNetworkLoader_exit
    mov CHAT_BREAK_LOOP , 1
ChatGameNetworkLoader_exit:
    ret
ChatGameNetworkLoader ENDP

ChatGameInputLoader PROC
    mov bx , OFFSET CHAT_ONLY_MY_TEXT
    mov CHAT_PUSH_BUFFER , bx
    mov bx , OFFSET CHAT_ONLY_MY_TEXT_S
    mov CHAT_PUSH_BUFFER_SIZE , bx
    mov8 CHAT_PUSH_CHAR , CURRENT_KEY_ASCII
    mov8 CHAT_PUSH_CHAR_SC , CURRENT_KEY_SCAN_CODE
    mov CHAT_BUFFER_MAX_SIZE , 800
    mov CHAT_LINE_SIZE       , 80
    call push_chat_letter
    mov CHAT_ONLY_INVALIDATE , 1
    
    SendByte CURRENT_KEY_ASCII
    SendByte CURRENT_KEY_SCAN_CODE

    cmp CURRENT_KEY_SCAN_CODE , 01h
    jne ChatGameInputLoader_exit
    FlushNetworkOneByte
    Sleep 20
    FlushNetworkOneByte

    mov CHAT_BREAK_LOOP , 1
ChatGameInputLoader_exit:
    ret
ChatGameInputLoader ENDP


ChatGameRenderer PROC
    mov ax,0600h ;clear screen
    mov bh,07
    mov cx,0
    mov dx,184FH
    int 10h

    SetCursor 0 , 0
    mov DI , OFFSET PlayerName
    add DI , 1
    mov al , ds:[DI]
    mov ah , 0
    mov a , ax
    add DI , 1
    DispMuliCharColored a , 02h

    SetCursor 12 , 0
    mov DI , OFFSET OtherPlayerName
    add DI , 1
    mov al , ds:[DI]
    mov ah , 0
    mov a , ax
    add DI , 1
    DispMuliCharColored a , 02h

    mov c , 0
    SetCursor 13 , 0
    ChatGameRenderer_out_loop:
        cmp16 c , CHAT_ONLY_OTHER_TEXT_S
        je ChatGameRenderer_out_loop_exit
        mov BX , OFFSET CHAT_ONLY_OTHER_TEXT
        add BX , c
        mov ah , 2
        mov dl , [BX]
        int 21h
        inc c
        jmp ChatGameRenderer_out_loop
    ChatGameRenderer_out_loop_exit:

    SetCursor 11 , 0
    mov cx, 80 ;number of iterations
    ChatGameRenderer_line:
        mov ah , 2
        mov dl , '-'
        int 21h
    loop ChatGameRenderer_line

    SetCursor 23 , 0
    mov cx, 80 ;number of iterations
    ChatGameRenderer_line1:
        mov ah , 2
        mov dl , '-'
        int 21h
    loop ChatGameRenderer_line1

    SetCursor 24 , 0
    DispString TXT_END_GAME_MAIN_MENU

    mov c , 0
    SetCursor 1 , 0
    ChatGameRenderer_me_loop:
        cmp16 c , CHAT_ONLY_MY_TEXT_S
        je ChatGameRenderer_me_loop_exit
        mov BX , OFFSET CHAT_ONLY_MY_TEXT
        add BX , c
        mov ah , 2
        mov dl , [BX]
        int 21h
        inc c
        jmp ChatGameRenderer_me_loop
    ChatGameRenderer_me_loop_exit:


    ret
ChatGameRenderer ENDP

ChatGame PROC
    CLS
    ClearAllInputHandlers
    ClearAllNetworkHandlers

    AddGlobalKeyHandler ChatGameInputLoader
    AddGlobalNetworkHandler ChatGameNetworkLoader

    _chat_loop:
        cmp CHAT_ONLY_INVALIDATE , 1
        jne _chat_loop_logic
        mov CHAT_ONLY_INVALIDATE , 0
        call ChatGameRenderer
    _chat_loop_logic:
        UpdateInputs
        UpdateNetwork
        
        dec CHAT_ONLY_NETWORK_IDEL
        cmp CHAT_ONLY_NETWORK_IDEL , 0
        jne _chat_loop_logic_skip_n
        FlushNetworkOneByte
        mov CHAT_ONLY_NETWORK_IDEL , 2 ;send a packet every 3 loops
    _chat_loop_logic_skip_n:
        cmp CHAT_BREAK_LOOP , 1
        je _chat_loop_exit
        jmp _chat_loop
    _chat_loop_exit:
    
    ClearAllInputHandlers
    ClearAllNetworkHandlers
    ret
ChatGame ENDP

END_MAIN_MENU PROC
    mov ax,0003h ;clear the screen
    int 10h
    SetCursor 0 , 0
    mov ah,4ch
    int 21h
    ret
END_MAIN_MENU ENDP

WritePlayerInfo PROC
    mov BX , OFFSET PlayerName
    add BX , 1
    mov ah , [BX]
    mov a1 , ah
    SendByte a1
    FlushNetworkOneByte
    Sleep 4
    mov a , 0 
    send_name_looper:
        cmp a1 , 0
        je send_name_looper_exit
        mov bx , OFFSET PlayerName
        add bx , 2
        add bx , a
        inc a
        mov ah , [BX]
        mov b1 , ah
        dec a1
        SendByte b1
        FlushNetworkOneByte
        Sleep 4
        jmp send_name_looper
    send_name_looper_exit:

    SendByte PlayerColor
    FlushNetworkOneByte
    Sleep 4

    mov bx , MOVE_COOLDOWN
    mov a1 , bh
    mov b1 , bl
    SendByte a1
    FlushNetworkOneByte
    Sleep 4

    SendByte b1
    FlushNetworkOneByte
    Sleep 4

    ret
WritePlayerInfo ENDP

InfoLoader PROC
        cmp settings_info_loader_enabled , 1
        je InfoLoader_q_exit_skip
        ret
    InfoLoader_q_exit_skip:
        mov BX , OFFSET OtherPlayerName
        mov ah , [BX]
        cmp ah , 0
        je InfoLoader_load_name_size
        cmp ah , 1
        je InfoLoader_load_name
        cmp ah , 2
        je InfoLoader_load_color
        cmp ah , 3
        je InfoLoader_load_cd1
        cmp ah , 4
        je InfoLoader_load_cd2
        ret ; should never happen ..
    InfoLoader_load_name_size:
        
        mov BX , OFFSET OtherPlayerName
        inc BX
        mov ah , N_CURRENT_BYTE
        mov [BX] , ah
        dec BX
        mov ah , 1
        mov [BX] , ah
        mov e , 0
        ret
    InfoLoader_load_name:
        mov BX , OFFSET OtherPlayerName
        inc BX
        mov ah , [BX]
        inc BX
        add BX , e
        mov al , N_CURRENT_BYTE
        mov [BX] , al
        inc e
        mov al , ah
        mov ah , 0
        cmp ax , e
        je InfoLoader_load_name_done
        ret
    InfoLoader_load_name_done:
        mov BX , OFFSET OtherPlayerName
        mov ah , 2
        mov [BX] , ah
        ret
    InfoLoader_load_color:
        mov BX , OFFSET OtherPlayerName
        mov ah , 3
        mov [BX] , ah
        mov ah , N_CURRENT_BYTE
        xor ah , 1
        mov PlayerColor , ah
        ret
    InfoLoader_load_cd1:
        mov BX , OFFSET OtherPlayerName
        mov ah , 4
        mov [BX] , ah
        
        mov MOVE_COOLDOWN , 0
        mov ax , 0
        mov ah , N_CURRENT_BYTE
        or MOVE_COOLDOWN , ax
        ret
    InfoLoader_load_cd2:
        mov ax ,  0
        mov al , N_CURRENT_BYTE
        or MOVE_COOLDOWN , ax

        mov settings_info_loader_enabled , 0
        mov settings_invalidate , 1
        mov TXT_DEBUG_MSG , 0
        ret

InfoLoader ENDP

NetworkInspector PROC
    mov al , N_CURRENT_BYTE
    mov ah , 0
    mov b , ax
    mov c , OFFSET TXT_DEBUG_TXT
    add16 c , TxT_DEBUG_TXT_SIZE
    Int2StringDirect c , 200 , a , 16 , b
    add16 TxT_DEBUG_TXT_SIZE , 2
    mov settings_invalidate , 1
    ret
NetworkInspector ENDP

SendGameInvitation PROC
    cmp settings_have_game_inv , -1
    je SendGameInvitation_Cansel
    cmp settings_have_game_inv , 0
    je SendGameInvitation_Create
    cmp settings_have_game_inv , 1 
    je SendGameInvitation_Join
    ret
SendGameInvitation_Join:
    SendByte 252        ; join game byte
    FlushNetworkOneByte
    call ChessGame
    mov settings_invalidate , 1
    mov settings_have_game_inv , 0
    ret
SendGameInvitation_Cansel:
    SendByte 253        ; cansel game byte
    FlushNetworkOneByte
    mov settings_have_game_inv , 0
    mov settings_invalidate , 1
    ret
SendGameInvitation_Create:
    SendByte 255        ; you there ?
    FlushNetworkOneByte
    Sleep 4 ;sleep 4 ms (this is too long btw)
    call WritePlayerInfo

    SendByte 254        ; give me your info
    FlushNetworkOneByte
    Sleep 4

    mov settings_invalidate , 1
    mov settings_have_game_inv , -1 ;sent a game invitation
    mov settings_info_loader_enabled , 1

    mov BX , OFFSET OtherPlayerName
    mov ah , 0
    mov [BX] , ah ;Ill use the first byte as a stator
    ret
SendGameInvitation ENDP

;byte 255
ReceiveGameInv PROC
    mov settings_info_loader_enabled , 1
    mov settings_have_game_inv , 1
    mov settings_invalidate , 1
    mov BX , OFFSET OtherPlayerName
    mov ah , 0
    mov [BX] , ah ;Ill use the first byte as a stator
    mov TXT_DEBUG_MSG , OFFSET TXT_LOADING
    ret
ReceiveGameInv ENDP

;byte 252
JoinGame PROC
    call ChessGame
    mov settings_invalidate , 1
    mov settings_have_game_inv , 0
    ret
JoinGame ENDP

;byte 253
CanselGame PROC
    mov settings_have_game_inv , 0
    mov settings_invalidate , 1
    ret
CanselGame ENDP

;byte 251
ReceiveChatInv PROC
    mov settings_info_loader_enabled , 1
    mov settings_have_chat_inv , 1
    mov settings_invalidate , 1
    mov BX , OFFSET OtherPlayerName
    mov ah , 0
    mov [BX] , ah ;Ill use the first byte as a stator
    mov TXT_DEBUG_MSG , OFFSET TXT_LOADING
    ret
ReceiveChatInv ENDP

;byte 249
JoinChat PROC
    call ChatGame
    mov settings_invalidate , 1
    mov settings_have_chat_inv , 0
    ret
JoinChat ENDP

;byte 250
CanselChat PROC
    mov settings_have_chat_inv , 0
    mov settings_invalidate , 1
    ret
CanselChat ENDP

SendChatInviation PROC
    cmp settings_have_chat_inv , -1
    je SendChatInviation_Cansel
    cmp settings_have_chat_inv , 0
    je SendChatInviation_Create
    cmp settings_have_chat_inv , 1 
    je SendChatInviation_Join
    ret
SendChatInviation_Join:
    SendByte 249        ; join chat byte
    FlushNetworkOneByte
    call ChatGame
    mov settings_invalidate , 1
    mov settings_have_chat_inv , 0
    ret
SendChatInviation_Cansel:
    SendByte 250        ; cansel chat byte
    FlushNetworkOneByte
    mov settings_have_chat_inv , 0
    mov settings_invalidate , 1
    ret
SendChatInviation_Create:
    SendByte 251        ;
    FlushNetworkOneByte
    Sleep 4 ;sleep 4 ms (this is too long btw)
    call WritePlayerInfo

    SendByte 254        ; give me your info
    FlushNetworkOneByte
    Sleep 4

    mov settings_invalidate , 1
    mov settings_have_chat_inv , -1 ;sent a chat invitation
    mov settings_info_loader_enabled , 1

    mov BX , OFFSET OtherPlayerName
    mov ah , 0
    mov [BX] , ah ;Ill use the first byte as a stator
    ret
SendChatInviation ENDP

inc_cooldown PROC
    mov settings_invalidate , 1
    add MOVE_COOLDOWN , 50
    ret
inc_cooldown ENDP

dec_cooldown PROC
    mov settings_invalidate , 1
    sub MOVE_COOLDOWN , 50
    cmp MOVE_COOLDOWN , 250
    jnl dec_cooldown_exit
    mov MOVE_COOLDOWN , 250
dec_cooldown_exit:
    ret
dec_cooldown ENDP

toggle_color PROC
    mov settings_invalidate , 1
    xor PlayerColor , 1
    ret
toggle_color ENDP


; Game network protocol:
;   SendGame Request (255) --> Send Player info (next x-bytes) --> Send Get info request (254) --> Enable info loader --> Load Info
;   Receive Game Request (255) --> Enable info loader --> Load info
;   Receive Info Request (254) --> (252) then Send Player info (next x-bytes) [name length byte , then name , then color , then cooldown]
;   Game Start Request (252) --> Start Game
;   Game Cansel Request (253) --> Casel Game
;
;
; Chat network protocol:
;   Just like Game , but I change the launcher ..
;

main_menu proc 
        mov ax , @Data
        mov ds , ax

        ;call ChessGame
        
    main_menu_restart:
        CLS
        
        cmp settings_disp_error , 0
        je main_menu_restart_skip_error
        SetCursor 23 , 0
        DispString TXT_NAME_ERROR
    main_menu_restart_skip_error:
        mov settings_disp_error , 1
        SetCursor 4 , 15
        DispString TXT_ENTER_PLAYER_NAME
        SetCursor 10 , 15
        DispString TXT_PRESS_ENTER_TO_CONT
        SetCursor 5 , 20
        ReadString PlayerName

        mov BX , OFFSET PlayerName
        add BX , 1 
        mov ah , [BX]
        cmp ah , 4            ;name range between [4-13]
        jl main_menu_restart
        cmp ah , 13
        jg main_menu_restart
        inc bx
        mov al , ah
        mov ah , 0
        add bx , ax
        mov ch , '$'
        mov [BX] , ch
        
        
        ConfigurePort1 0001h , 00011011B

    main_menu_draw:
        cmp settings_invalidate , 1
        je main_menu_draw_do
        jmp main_menu_loop
            main_menu_draw_do:
        mov settings_invalidate , 0
        
        CLS

        ;call START_THE_Game
        SetCursor 0 , 33
        DispString TXT_GAME_SETTINGS
        SetCursor 1 , 5
        DispString TXT_PLAYER_COLOR
        cmp PlayerColor , 0
        jne main_menu_loop_player_black
            SetCursor 1 , 30
            DispString TXT_COLOR_WHITE
            jmp main_menu_loop_player_white
        main_menu_loop_player_black:
            SetCursor 1 , 30
            DispString TXT_COLOR_BLACK
        main_menu_loop_player_white:
        
        MemSet TXT_MOVE_COOLDOWN_BUFF , 15 , '$'
        Int2String TXT_MOVE_COOLDOWN_BUFF , 15 , a , 10 , MOVE_COOLDOWN
        SetCursor 2 , 5
        DispString TXT_MOVE_COOLDOWN
        SetCursor 2 , 30
        DispString TXT_MOVE_COOLDOWN_BUFF

        cmp settings_have_game_inv , 0
        jne main_menu_skip_edit_settings_v
        SetCursor 1 , 45
        DispString TXT_F4_TOGGLE
        SetCursor 2 , 45
        DispString TXT_F5_F6_INC_DEC
    main_menu_skip_edit_settings_v:

        mov bx , offset PlayerName
        mov a , bx
        add a , 2

        SetCursor 3 , 5
        DispString TXT_PLAYER_NAME
        
        SetCursor 3 , 30
        DispStringImd a

        SetCursor 4 , 0
        mov cx, 80
        line_0:
            mov ah , 2
            mov dl , '-'
            int 21h
        loop line_0


        SetCursor 0Ah,64h
        cmp settings_have_game_inv , 1 ;external game
        je main_menu_external_game
        cmp settings_have_game_inv , -1 ;interal game
        je main_menu_cansel_game
        DispString TXT_CREATE_GAME_MAIN_MENU
        jmp main_menu_create_game
    main_menu_external_game:
        DispString TXT_JOIN_GAME_MAIN_MENU
        SetCursor 23,0
        DispString TXT_GAME_INVITATION_RECV0
        mov BX , OFFSET OtherPlayerName
        add BX , 2
        mov a , BX
        DispStringImd a
        DispString TXT_GAME_INVITATION_RECV1
        jmp main_menu_create_game
    main_menu_cansel_game:
        DispString TXT_CANSEL_GAME_MAIN_MENU
        SetCursor 23,0
        DispString TXT_GAME_INVITATION_SENT0
        mov BX , OFFSET OtherPlayerName
        add BX , 2
        mov a , BX
        DispStringImd a
        DispString TXT_GAME_INVITATION_SENT1
        jmp main_menu_create_game    
    main_menu_create_game:

        SetCursor 0Bh, 64h
        cmp settings_have_chat_inv , 1 ;external game
        je main_menu_external_chat
        cmp settings_have_chat_inv , -1 ;external game
        je main_menu_cansel_chat
        DispString TXT_CREATE_CHAT_MAIN_MENU
        jmp main_menu_create_chat
    main_menu_external_chat:
        DispString TXT_JOIN_CHAT_MAIN_MENU
        
        SetCursor 24,0
        DispString TXT_CHAT_INVITATION_RECV0
        mov BX , OFFSET OtherPlayerName
        add BX , 2
        mov a , BX
        DispStringImd a
        DispString TXT_CHAT_INVITATION_RECV1
        
        jmp main_menu_create_chat
    main_menu_cansel_chat:
        DispString TXT_CANSEL_CHAT_MAIN_MENU

        SetCursor 24,0
        DispString TXT_CHAT_INVITATION_SENT0
        mov BX , OFFSET OtherPlayerName
        add BX , 2
        mov a , BX
        DispStringImd a
        DispString TXT_CHAT_INVITATION_SENT1

        jmp main_menu_create_chat    
    main_menu_create_chat:
        
        SetCursor 0ch, 64h
        DispString TXT_END_GAME_MAIN_MENU

        SetCursor 22 , 0
        mov cx, 80
        line_1:
            mov ah , 2
            mov dl , '-'
            int 21h
        loop line_1


        ;SetCursor 14 , 0
        ;DispString TXT_DEBUG_NETWORK
        ;SetCursor 15 , 0
        ;DispString TXT_DEBUG_TXT

        ;mov ax , TXT_DEBUG_MSG
        ;cmp ax , 0
        ;je main_menu_loop
        ;SetCursor 21 , 5
        ;DispStringImd TXT_DEBUG_MSG

    main_menu_loop:
        SetCursor 24 , 0
        
        ClearAllInputHandlers
        AddKeyHandler 01 , END_MAIN_MENU
        AddKeyHandler 3bh , SendGameInvitation
        AddKeyHandler 3ch , SendChatInviation

        ClearAllNetworkHandlers
        AddGlobalNetworkHandler NetworkInspector
        AddGlobalNetworkHandler InfoLoader

        AddNetworkHandler 255 , ReceiveGameInv
        AddNetworkHandler 254 , WritePlayerInfo
        AddNetworkHandler 253 , CanselGame
        AddNetworkHandler 252 , JoinGame

        AddNetworkHandler 251 , ReceiveChatInv
        AddNetworkHandler 250 , CanselChat
        AddNetworkHandler 249 , JoinChat
        
        cmp settings_have_game_inv , 0
        jne main_menu_skip_edit_settings    
        AddKeyHandler 34H , inc_cooldown
        AddKeyHandler 33h , dec_cooldown
        AddKeyHandler 14H , toggle_color
    main_menu_skip_edit_settings:

        UpdateInputs 
        UpdateNetwork
        
        jmp main_menu_draw
        ret
main_menu endp 


END main_menu ; you're done !