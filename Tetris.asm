%include "/usr/local/share/csc314/asm_io.inc"


; the file that stores the initial state
%define BOARD_FILE 'board.txt'

; how to represent everything
%define WALL_CHAR '#'
%define PLAYER_CHAR '#'

; the size of the game screen in characters
%define HEIGHT 20
%define WIDTH 25
%define wdth  24
; the player starting position.
; top left is considered (0,0)
%define STARTX 11
%define STARTY 1
%define STARTX1 11
%define STARTY1 2
%define STARTX2 12
%define STARTY2 1
%define STARTX3 12
%define STARTY3 2
%define STARTX4 13
%define STARTY4 1
%define STARTX5 13
%define STARTY5 2

; these keys do things
%define EXITCHAR 'x'
%define UPCHAR 'w'
%define LEFTCHAR 'a'
%define DOWNCHAR 's'
%define RIGHTCHAR 'd'


segment .data

        ; used to fopen() the board file defined above
        board_file                      db BOARD_FILE,0

        ; used to change the terminal mode
        mode_r                          db "r",0
        raw_mode_on_cmd         db "stty raw -echo",0
        raw_mode_off_cmd        db "stty -raw echo",0

        ; called by system() to clear/refresh the screen
        clear_screen_cmd        db "clear",0

        ; things the program will print
        help_str                        db 13,10,"Controls: ", \
                                                        UPCHAR,"=ROTATE / ", \
                                                        LEFTCHAR,"=LEFT / ", \
                                                        DOWNCHAR,"=DOWN / ", \
                                                        RIGHTCHAR,"=RIGHT / ", \
                                                        EXITCHAR,"=EXIT", \
                                                        13,10,10,0
        gos                                     db 32,"gameover",10,0
     col_green          db 0x1b,"[36;1m",0
     col_normal        db  0x1b,"[0m",0
     col_red           db  0x1b,"[31;1m",0
     col_yellow           db  0x1b,"[33;1m",0
segment .bss

        ; this array stores the current rendered gameboard (HxW)
        board   resb    (HEIGHT * WIDTH)

        ; these variables store the current player position
        xpos    resd    1
        ypos    resd    1
        xpos1   resd    1
        ypos1   resd    1
        xpos2   resd    1
        ypos2   resd    1
        xpos3   resd    1
        ypos3   resd    1
        xpos4   resd    1
        ypos4   resd    1
        xpos5   resd    1
        ypos5   resd    1
        t               resd    1
        r               resd    1
        hp              resd    1
segment .text

        global  asm_main
        global  raw_mode_on
        global  raw_mode_off
        global  init_board
        global  render

        extern  system
        extern  putchar
        extern  getchar
        extern  printf
        extern  fopen
        extern  fread
        extern  fgetc
        extern  fclose
        extern  fcntl
        extern  time
        extern  usleep
        extern  srand
        extern  rand
asm_main:
        enter   0,0
        pusha
        ;***************CODE STARTS HERE***************************
        ;srand(time(0));
        push    0
        call    time
        add             esp,4

        push    eax
        call    srand
        add             esp, 4
        ; put the terminal in raw mode so the game works nicely
        call    raw_mode_on

        ; read the game board file into the global variable
        call    init_board

        ; set the player at the proper start position
;       mov             DWORD [xpos], STARTX
;       mov             DWORD [ypos], STARTY
;       mov     DWORD [xpos1], STARTX1
;       mov             DWORD [ypos1], STARTY1
;       mov     DWORD [xpos2], STARTX2
;       mov     DWORD [ypos2], STARTY2
;       mov     DWORD [xpos3], STARTX3
 ;      mov     DWORD [ypos3], STARTY3
 ;      mov     DWORD [xpos4], STARTX4
 ;      mov     DWORD [ypos4], STARTY4
 ;      mov     DWORD [xpos5], STARTX5
 ;      mov     DWORD [ypos5], STARTY5
        ; the game happens in this loop
        ; the steps are...
        ;   1. render (draw) the current board
        ;   2. get a character from the user
        ;       3. store current xpos,ypos in esi,edi
        ;       4. update xpos,ypos based on character from user
        ;       5. check what's in the buffer (board) at new xpos,ypos
        ;       6. if it's a wall, reset xpos,ypos to saved esi,edi
        ;       7. otherwise, just continue! (xpos,ypos are ok)
        mov             DWORD [t], 0
;       mov             DWORD [r], 1
        call    create_shapes
        game_loop:

                ; draw the game board
                call    render
                cmp             DWORD[hp], 6
                jne             goon
                push    col_red
        call    printf
            add     esp,4

            push    gos
            call    printf
            add     esp, 4
                push    col_normal
        call    printf
        add     esp, 4


                        jmp     game_loop_end
                goon:
                ; get an action from the user
                call    nonblocking_getchar
        ;       call    getchar

                ; choose what to do
                cmp             eax, EXITCHAR
                je              game_loop_end
                cmp             eax, UPCHAR
                je              move_up
                cmp             eax, LEFTCHAR
                je              move_left
                cmp             eax, -1
                je              move_down
                cmp             eax, RIGHTCHAR
                je              move_right
                jmp             input_end                       ; or just do nothing

                ; move the player according to the input character
                move_up:
                        cmp             DWORD [r], 0
                        jne             u1
                                cmp             DWORD [t], 0
                                jne             rt1
                                        inc             DWORD[xpos]
                                        dec             DWORD[ypos1]
                                        inc             DWORD[ypos2]
                                        dec             DWORD[xpos3]
                                        inc             DWORD[ypos4]
                                        inc             DWORD[ypos4]
                                        dec             DWORD[xpos4]
                                        inc             DWORD[ypos5]
                                        dec             DWORD[xpos5]
                                        dec             DWORD[xpos5]
                                        mov     DWORD [t], 1
                                        jmp     input_end
                                rt1:
                                        dec     DWORD[xpos]
                        inc     DWORD[ypos1]
                        dec     DWORD[ypos2]
                        inc     DWORD[xpos3]
                        dec     DWORD[ypos4]
                        dec     DWORD[ypos4]
                        inc     DWORD[xpos4]
                        dec     DWORD[ypos5]
                        inc     DWORD[xpos5]
                        inc     DWORD[xpos5]
                                        mov     DWORD [t], 0
                                        jmp             input_end
                u1:
             cmp     DWORD [r], 1
             jne     u2
                cmp     DWORD [t], 0
                jne     rt2
                                ;       jmp             game_loop_end
                    dec     DWORD[ypos2]
                                        dec             DWORD[ypos2]
                                        dec     DWORD[xpos]
                                        dec     DWORD[xpos]
                                        dec     DWORD[xpos1]
                                        dec             DWORD[ypos1]
                                        dec             DWORD[ypos3]
                                        dec     DWORD[ypos3]
                                        dec     DWORD[ypos3]
                                        inc             DWORD[xpos3]
                                        dec             DWORD[ypos4]
                                        dec     DWORD[ypos4]
                                        dec     DWORD[ypos4]
                                        dec     DWORD[ypos4]
                                        inc             DWORD[xpos4]
                                        inc             DWORD[xpos4]
                    dec     DWORD[ypos5]
                    dec     DWORD[ypos5]
                    dec     DWORD[ypos5]
                                        dec     DWORD[ypos5]
                                        dec     DWORD[ypos5]
                                        inc             DWORD[xpos5]
                                        inc             DWORD[xpos5]
                                        inc             DWORD[xpos5]

                    mov     DWORD [t], 1
                    jmp     input_end
                rt2:
                    inc     DWORD[ypos2]
                    inc     DWORD[ypos2]
                    inc     DWORD[xpos]
                    inc     DWORD[xpos]
                    inc     DWORD[xpos1]
                    inc     DWORD[ypos1]
                    inc     DWORD[ypos3]
                    inc     DWORD[ypos3]
                    inc     DWORD[ypos3]
                    dec     DWORD[xpos3]
                    inc     DWORD[ypos4]
                    inc     DWORD[ypos4]
                    inc     DWORD[ypos4]
                    inc     DWORD[ypos4]
                    dec     DWORD[xpos4]
                    dec     DWORD[xpos4]
                    inc     DWORD[ypos5]
                    inc     DWORD[ypos5]
                    inc     DWORD[ypos5]
                    inc     DWORD[ypos5]
                    inc     DWORD[ypos5]
                    dec     DWORD[xpos5]
                    dec     DWORD[xpos5]
                    dec     DWORD[xpos5]


                    mov     DWORD [t], 0
                                        jmp             input_end
        u2:             cmp     DWORD [r], 2
             jne     u3
                cmp     DWORD [t], 0
                jne     rt3
                    add         DWORD[xpos], 4
                                        add     DWORD[xpos1], 4
                                        add     DWORD[xpos2], 4
                    mov     DWORD [t], 1
                    jmp     input_end
                rt3:
                    sub     DWORD[xpos], 4
                    sub     DWORD[xpos1], 4
                    sub     DWORD[xpos2], 4

                    mov     DWORD [t], 0
                    jmp     input_end

                u3:
                                        jmp             input_end
                move_left:
                        dec             DWORD [xpos]
                        dec             DWORD [xpos1]
            dec     DWORD [xpos2]
            dec     DWORD [xpos3]
            dec     DWORD [xpos4]
                        dec             DWORD [xpos5]
                        jmp             input_end
                move_down:
                        push    400000
                        call    usleep
                        add             esp, 4
                        inc             DWORD [ypos]
                        inc     DWORD [ypos1]
                        inc     DWORD [ypos2]
                        inc     DWORD [ypos3]
                        inc     DWORD [ypos4]
                        inc     DWORD [ypos5]
                        jmp             input_end
                move_right:
                        inc             DWORD [xpos]
                        inc     DWORD [xpos1]
                        inc     DWORD [xpos2]
                        inc     DWORD [xpos3]
                        inc     DWORD [xpos4]
                        inc     DWORD [xpos5]
                input_end:

                ; (W * y) + x = pos

                ; compare the current position to the wall character
                mov             eax, WIDTH
                mul             DWORD[ypos]
                add             eax, [xpos]
                lea             eax, [board + eax]
                cmp             BYTE [eax], WALL_CHAR
                jne             valid_move
                        ; opps, that was an invalid move, reset
                        mov             DWORD [xpos], esi
                        mov             DWORD [ypos], edi
                valid_move:
                mov     esi, 0
                ;sticking the player char
                st_start:
                cmp             esi, HEIGHT
                jge             st_end
                mov     edi, 0
                        sti_start:
                        cmp             edi, WIDTH
                        jge             sti_end

                                call    stuck

                        inc             edi
                        jmp             sti_start
                        sti_end:
                inc             esi
                jmp             st_start
                st_end:
                ;clearing
                mov             edx, 0
                mov             DWORD[hp],0
                mov             ebx, HEIGHT
                dec             ebx
                mov             ecx, WIDTH
                dec             ecx
                mov             esi, 1
                cl_start:
                cmp             esi, ebx
                jge             cl_end
                mov             edi, 1
                        cl1_start:
                        cmp             edi, ecx
                        jge             cl1_end

                                mov     eax, WIDTH
                ;;              dec             eax
                        mul     esi
                add     eax, edi
                lea     eax, [board + eax]
                cmp     BYTE [eax], WALL_CHAR
                                jne             ola
                                        inc             DWORD[hp]

                                ola:
                        inc             edi
                        jmp             cl1_start
                        cl1_end:
                        cmp     DWORD[hp], 23
            jne      ola2
                    mov         DWORD[hp], esi
                                call    clear
                ola2:
                mov             DWORD[hp], 0
                inc             esi
                jmp             cl_start
                cl_end:
                mov             DWORD[hp], 1
                mov     ebx, HEIGHT
        dec     ebx
        mov     ecx, WIDTH
        dec     ecx
        mov     esi, 1
                offs:
                cmp             esi, ebx
                jge     offs1
                mov             edi, 1
                        offs2:
                        cmp             edi, ecx
                        jge             offs3
                                mov             eax, WIDTH
                                mul             DWORD[hp]
                                add             eax, edi
                                lea             eax, [board + eax]
                                cmp             BYTE[eax], WALL_CHAR
                                jne     qsa
                                        mov             DWORD[hp], 6
                                ;       jmp             game_loop_end
                                qsa:
                        inc             edi
                        jmp             offs2
                        offs3:
                inc             esi
                jmp             offs
                offs1:

        jmp             game_loop
        game_loop_end:



        ; restore old terminal functionality
        call raw_mode_off

        ;***************CODE ENDS HERE*****************************
        popa
        mov             eax, 0
        leave
        ret

clear:
        push    ebp
        mov             ebp, esp

                mov             DWORD[ebp-4], 1
                clear1:
                cmp             DWORD[ebp-4], wdth
                jge             clear2
                        mov             eax, WIDTH
                        mul             DWORD[hp]
                        add             eax, DWORD[ebp-4]
                        mov             BYTE[board + eax], ' '
                inc             DWORD[ebp-4]
                jmp             clear1
                clear2:

                clear3:
                cmp             DWORD[hp], 1
                jl              clear4
                mov             DWORD[ebp-4], 23
                        clear5:
                        cmp             DWORD[ebp-4], 1
                        jl              clear6

                                mov             eax, WIDTH
                                mul             DWORD[hp]
                                add             eax, DWORD[ebp-4]
                                mov     DWORD[ebp-8], eax
                                lea             eax, [board + eax]
                                cmp             BYTE[eax], WALL_CHAR
                                jne             p
                                        mov             eax, DWORD[hp]
                                        mov             DWORD[ebp-12], eax
                                        inc             DWORD[ebp-12]
                                        mov             eax, WIDTH
                                        mul             DWORD[ebp-12]
                                        add             eax, DWORD[ebp-4]
                                        mov             BYTE[board + eax], WALL_CHAR
                                        mov             eax, DWORD[ebp-8]
                                        mov             BYTE[board + eax], ' '

                                p:
                        dec             DWORD[ebp-4]
                        jmp             clear5
                        clear6:
                dec             DWORD[hp]
                jmp             clear3
                clear4:



        mov             esp, ebp
        pop             ebp
        ret

create_shapes:
        push    ebp
        mov             ebp, esp

        call    rand
    cdq
    mov     ebx, 3
    idiv    ebx
    mov     DWORD[r], edx


        cmp             DWORD[r], 0
        jne             c1
        mov     DWORD [xpos], STARTX
        mov     DWORD [ypos], STARTY
            mov     DWORD [xpos1], STARTX1
            mov     DWORD [ypos1], STARTY1
            mov     DWORD [xpos2], STARTX2
            mov     DWORD [ypos2], STARTY2
            mov     DWORD [xpos3], STARTX3
            mov     DWORD [ypos3], STARTY3
            mov     DWORD [xpos4], STARTX4
            mov     DWORD [ypos4], STARTY4
            mov     DWORD [xpos5], STARTX5
            mov     DWORD [ypos5], STARTY5
        mov     DWORD [t], 0
        c1:
        cmp DWORD[r], 1
        jne             c2
                mov     DWORD [xpos], 12
        mov     DWORD [ypos], 0
        mov     DWORD [xpos1], 12
        mov     DWORD [ypos1], 1
        mov     DWORD [xpos2], 12
        mov     DWORD [ypos2], 2
        mov     DWORD [xpos3], 12
        mov     DWORD [ypos3], 3
        mov     DWORD [xpos4], 12
        mov     DWORD [ypos4], 4
        mov     DWORD [xpos5], 12
        mov     DWORD [ypos5], 5
    mov     DWORD [t], 0
        c2:
        cmp     DWORD[r], 2
        jne             c3
        mov     DWORD [xpos], 11
        mov     DWORD [ypos], 2
        mov     DWORD [xpos1], 12
        mov     DWORD [ypos1], 2
        mov     DWORD [xpos2], 13
        mov     DWORD [ypos2], 2
        mov     DWORD [xpos3], 14
        mov     DWORD [ypos3], 2
        mov     DWORD [xpos4], 14
        mov     DWORD [ypos4], 1
        mov     DWORD [xpos5], 14
        mov     DWORD [ypos5], 0
    mov     DWORD [t], 0

        c3:

        mov             esp, ebp
        pop             ebp
        ret
stuck:

        push    ebp
        mov             ebp, esp

                mov     ebx, DWORD [ypos]
        inc     ebx
        mov     eax, WIDTH
        mul     ebx
        add     eax, [xpos]
        lea     eax, [board + eax]
        cmp     BYTE [eax], WALL_CHAR
        je     tb
        mov     ebx, DWORD [ypos1]
        inc     ebx
        mov     eax, WIDTH
        mul     ebx
        add     eax, [xpos1]
        lea     eax, [board + eax]
        cmp     BYTE [eax], WALL_CHAR
        je     tb
        mov     ebx, DWORD [ypos2]
        inc     ebx
        mov     eax, WIDTH
        mul     ebx
        add     eax, [xpos2]
        lea     eax, [board + eax]
        cmp     BYTE [eax], WALL_CHAR
        je     tb
        mov     ebx, DWORD [ypos3]
        inc     ebx
        mov     eax, WIDTH
        mul     ebx
        add     eax, [xpos3]
        lea     eax, [board + eax]
        cmp     BYTE [eax], WALL_CHAR
        je     tb
        mov     ebx, DWORD [ypos4]
        inc     ebx
        mov     eax, WIDTH
        mul     ebx
        add     eax, [xpos4]
        lea     eax, [board + eax]
        cmp     BYTE [eax], WALL_CHAR
        je     tb
        mov     ebx, DWORD [ypos5]
        inc     ebx
        mov     eax, WIDTH
        mul     ebx
        add     eax, [xpos5]
        lea     eax, [board + eax]
        cmp     BYTE [eax], WALL_CHAR
        je     tb
                jmp             ts




                        tb:
            mov     eax, WIDTH                                          ;0
            mul     DWORD[ypos]
            add     eax, [xpos]
            mov     BYTE[board + eax], WALL_CHAR
                        mov     eax, WIDTH                                     ;1
            mul     DWORD[ypos1]
            add     eax, [xpos1]
            mov     BYTE[board + eax], WALL_CHAR
                        mov     eax, WIDTH                                     ;2
            mul     DWORD[ypos2]
            add     eax, [xpos2]
            mov     BYTE[board + eax], WALL_CHAR
                        mov     eax, WIDTH                                     ;3
            mul     DWORD[ypos3]
            add     eax, [xpos3]
            mov     BYTE[board + eax], WALL_CHAR
                        mov     eax, WIDTH                                     ;4
            mul     DWORD[ypos4]
            add     eax, [xpos4]
            mov     BYTE[board + eax], WALL_CHAR
                        mov     eax, WIDTH                                     ;5
            mul     DWORD[ypos5]
            add     eax, [xpos5]
            mov     BYTE[board + eax], WALL_CHAR
                 mov     DWORD [xpos], STARTX

                call    create_shapes
                ts:


        mov             esp, ebp
        pop             ebp
        ret

; === FUNCTION ===
raw_mode_on:

        push    ebp
        mov             ebp, esp

        push    raw_mode_on_cmd
        call    system
        add             esp, 4

        mov             esp, ebp
        pop             ebp
        ret

; === FUNCTION ===
raw_mode_off:

        push    ebp
        mov             ebp, esp

        push    raw_mode_off_cmd
        call    system
        add             esp, 4

        mov             esp, ebp
        pop             ebp
        ret

; === FUNCTION ===
init_board:

        push    ebp
        mov             ebp, esp

        ; FILE* and loop counter
        ; ebp-4, ebp-8
        sub             esp, 8

        ; open the file
        push    mode_r
        push    board_file
        call    fopen
        add             esp, 8
        mov             DWORD [ebp-4], eax

        ; read the file data into the global buffer
        ; line-by-line so we can ignore the newline characters
        mov             DWORD [ebp-8], 0
        read_loop:
        cmp             DWORD [ebp-8], HEIGHT
        je              read_loop_end

                ; find the offset (WIDTH * counter)
                mov             eax, WIDTH
                mul             DWORD [ebp-8]
                lea             ebx, [board + eax]

                ; read the bytes into the buffer
                push    DWORD [ebp-4]
                push    WIDTH
                push    1
                push    ebx
                call    fread
                add             esp, 16

                ; slurp up the newline
                push    DWORD [ebp-4]
                call    fgetc
                add             esp, 4

        inc             DWORD [ebp-8]
        jmp             read_loop
        read_loop_end:

        ; close the open file handle
        push    DWORD [ebp-4]
        call    fclose
        add             esp, 4

        mov             esp, ebp
        pop             ebp
        ret

; === FUNCTION ===
render:

        push    ebp
        mov             ebp, esp

        ; two ints, for two loop counters
        ; ebp-4, ebp-8
        sub             esp, 8

        ; clear the screen
        push    clear_screen_cmd
        call    system
        add             esp, 4

        ; print the help information
        push    help_str
        call    printf
        add             esp, 4

        ; outside loop by height

        ; i.e. for(c=0; c<height; c++)
        mov             DWORD [ebp-4], 0
        y_loop_start:
        cmp             DWORD [ebp-4], HEIGHT
        je              y_loop_end

                ; inside loop by width
                ; i.e. for(c=0; c<width; c++)
                mov             DWORD [ebp-8], 0
                x_loop_start:
                cmp             DWORD [ebp-8], WIDTH
                je              x_loop_end

                        push    col_red
                        call    printf
                        add             esp, 4

                        ; check if (xpos,ypos)=(x,y)
                        mov             eax, [xpos]
                        cmp             eax, DWORD [ebp-8]
                        jne             n1
                        mov             eax, [ypos]
                        cmp             eax, DWORD [ebp-4]
                        jne             n1
                                ; if both were equal, print the player
                                push    PLAYER_CHAR
                                jmp             print_end
                        n1:
                        mov             eax, [xpos1]
                        cmp             eax, DWORD [ebp-8]
                        jne             n2
                        mov             eax, [ypos1]
                        cmp             eax, DWORD [ebp-4]
                        jne             n2
                                push    PLAYER_CHAR
                                jmp             print_end
                        n2:
                        mov             eax, [xpos2]
                        cmp             eax, DWORD [ebp-8]
                        jne             n3
                        mov             eax, [ypos2]
                        cmp             eax, DWORD [ebp-4]
                        jne             n3
                                push    PLAYER_CHAR
                                jmp     print_end
                        n3:
                        mov             eax, [xpos3]
                        cmp             eax, DWORD [ebp-8]
                        jne             n4
                        mov             eax, [ypos3]
                        cmp             eax, DWORD [ebp-4]
                        jne             n4
                                push    PLAYER_CHAR
                jmp     print_end
                        n4:
             mov     eax, [xpos4]
             cmp     eax, DWORD [ebp-8]
             jne     n5
             mov     eax, [ypos4]
             cmp     eax, DWORD [ebp-4]
             jne     n5
                 push    PLAYER_CHAR
                 jmp     print_end
                        n5:
             mov     eax, [xpos5]
             cmp     eax, DWORD [ebp-8]
             jne     print_board
             mov     eax, [ypos5]
             cmp     eax, DWORD [ebp-4]
             jne     print_board
                 push    PLAYER_CHAR
                 jmp     print_end


                        print_board:
                        push    col_green
                        call    printf
                        add             esp, 4
                                ; otherwise print whatever's in the buffer
                                mov             eax, [ebp-4]
                                mov             ebx, WIDTH
                                mul             ebx
                                add             eax, [ebp-8]
                                mov             ebx, 0
                                mov             bl, BYTE [board + eax]
                                push    ebx
                        print_end:
                        call    putchar
                        add             esp, 4

                        push    col_normal
                        call    printf
                        add             esp, 4

                inc             DWORD [ebp-8]
                jmp             x_loop_start
                x_loop_end:

                ; write a carriage return (necessary when in raw mode)
                push    0x0d
                call    putchar
                add             esp, 4

                ; write a newline
                push    0x0a
                call    putchar
                add             esp, 4

        inc             DWORD [ebp-4]
        jmp             y_loop_start
        y_loop_end:

        mov             esp, ebp
        pop             ebp
        ret
nonblocking_getchar:

; returns -1 on no-data
; returns char on succes

; magic values
%define F_GETFL 3
%define F_SETFL 4
%define O_NONBLOCK 2048
%define STDIN 0

        push    ebp
        mov             ebp, esp

        ; single int used to hold flags
        ; single character (aligned to 4 bytes) return
        sub             esp, 8

        ; get current stdin flags
        ; flags = fcntl(stdin, F_GETFL, 0)
        push    0
        push    F_GETFL
        push    STDIN
        call    fcntl
        add             esp, 12
        mov             DWORD [ebp-4], eax

        ; set non-blocking mode on stdin
        ; fcntl(stdin, F_SETFL, flags | O_NONBLOCK)
        or              DWORD [ebp-4], O_NONBLOCK
        push    DWORD [ebp-4]
        push    F_SETFL
        push    STDIN
        call    fcntl
        add             esp, 12

        call    getchar
        mov             DWORD [ebp-8], eax

        ; restore blocking mode
        ; fcntl(stdin, F_SETFL, flags ^ O_NONBLOCK
        xor             DWORD [ebp-4], O_NONBLOCK
        push    DWORD [ebp-4]
        push    F_SETFL
        push    STDIN
        call    fcntl
        add             esp, 12

        mov             eax, DWORD [ebp-8]

        mov             esp, ebp
        pop             ebp
        ret