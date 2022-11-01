.bss
/* This is a buffer that will hold the characters the user writes
   to stdin. */
str_userInput: .skip 32

/* This is an array that represents the cells of the game.
   If the value is 0, then nothing has been written yet.
   Otherwise the value is either 'X' or 'O'. */
arr_cells:
.skip 9

.data
str_welcome: .ascii "The Tic Tac Toe game\n"
str_welcome_len: .word .-str_welcome

str_grid:
.ascii "\n"
.ascii "| | | |\t\t|1|2|3|\n"
.ascii "| | | |\t\t|4|5|6|\n"
.ascii "| | | |\t\t|7|8|9|\n"
.ascii "\n"
str_grid_len: .word .-str_grid

str_prompt: .ascii "number> "
str_prompt_len: .word .-str_prompt

str_crossTurn: .ascii "Where to put the X?\n"
str_crossTurn_len: .word .-str_crossTurn

str_circleTurn: .ascii "Where to put the O?\n"
str_circleTurn_len: .word .-str_circleTurn

str_crossWin: .ascii "The X won!\n"
str_crossWin_len: .word .-str_crossWin

str_circleWin: .ascii "The O won!\n"
str_circleWin_len: .word .-str_circleWin

str_draw: .ascii "Draw!\n"
str_draw_len: .word .-str_draw

.text

/*
Test if the cells have the same value and are different than zero.

r0: The first cell.
r1: The second cell.
r2: The third cell.

return: r0: 0 if they does not have the same value,
            otherwise the value does not change.
*/
isLine:
    /* Is the first cell zero? If so, that means we don't have a line so we
       can return this 0. */
    cmp r0, #0
    bxeq lr

    /* Test if all cell have the same value */
    cmp r0, r1
    cmpeq r1, r2
    bne 1f

    bx lr /* return the value of the cell */

/* There are not the same so it returns 0 */
1:
    mov r0, #0
    bx lr

/*
Print the grid
*/
printGrid:
    mov r7, #4
    mov r0, #1
    ldr r1, =str_grid
    ldr r2, =str_grid_len
    ldr r2, [r2]
    swi 0

    bx lr

/*
r9:   The number of the current round, starting at 0.

r10:  Adress of whether str_crossTurn or str_circleTurn.
      It depends on whether it is the turn of X or O.

r11:  Length of the string in r10.

r12:  The character that corresponds whether to X or O whether it the turn
      of the cross or the circle.
*/
.global _start
_start:

/* Define default value */
    mov r9, #0
    ldr r10, =str_crossTurn
    ldr r11, =str_crossTurn_len
    ldr r11, [r11]
    mov r12, #88 /* 'X' */

/* Print welcome message */
    mov r7, #4
    mov r0, #1
    ldr r1, =str_welcome
    ldr r2, =str_welcome_len
    ldr r2, [r2]
    swi 0

gameLoop:
    bl printGrid

/* Print the message "Where to put the X/O?" */
    mov r7, #4
    mov r0, #1
    mov r1, r10
    mov r2, r11
    swi 0

print_number_prompt:
    mov r7, #4
    mov r0, #1
    ldr r1, =str_prompt
    ldr r2, =str_prompt_len
    ldr r2, [r2]
    swi 0

/* Read from stdin */
    mov r7, #3
    mov r0, #0
    ldr r1, =str_userInput
    mov r2, #32
    swi 0

/* Go back and re-ask for a number if the user write nothing but 1
   character (for example when the user has only pressed the enter key */
    cmp r0, #1
    beq print_number_prompt

/* Branch at the end, to exit if nothing at all was written (for
   example if the user has pressed ^D) */
    cmp r0, #0
    beq exit

/* Test if the first character input is in the range of 1-9 included.
   If that is not the case, it go back and re-ask to input a number. */
    ldr r0, =str_userInput
    ldrb r0, [r0]
    cmp r0, #49
    blt print_number_prompt
    cmp r0, #58
    bge print_number_prompt

/* Convert the first character from ascii to the real number, minus one.
   For example if '8' is written, it becomes 7 (in decimal). */
    sub r0, #49

/* Set the offset that will be later used to write the X or the O on
   the grid. */
    cmp r0, #0    /* number 1 */
    moveq r3, #2
    beq write_symbol
    cmp r0, #1    /* number 2 */
    moveq r3, #4
    beq write_symbol
    cmp r0, #2    /* number 3 */
    moveq r3, #6
    beq write_symbol
    cmp r0, #3    /* number 4 */
    moveq r3, #19
    beq write_symbol
    cmp r0, #4    /* number 5 */
    moveq r3, #21
    beq write_symbol
    cmp r0, #5    /* number 6 */
    moveq r3, #23
    beq write_symbol
    cmp r0, #6    /* number 7 */
    moveq r3, #36
    beq write_symbol
    cmp r0, #7    /* number 8 */
    moveq r3, #38
    beq write_symbol

                  /* number 9 */
    mov r3, #40

/* Write 'X' or 'O' in the internal data (arr_cells) and
   in the grid (str_grid) if the position is correct. */
write_symbol:
    ldr r1, =arr_cells
    ldrb r4, [r1, r0]

    /* Go back and re-ask for a number if the selected cell has
       already been filled */
    cmp r4, #0
    bne print_number_prompt

    strb r12, [r1, r0] /* write the character in arr_cells */

    ldr r2, =str_grid
    strb r12, [r2, r3] /* write the character in str_grid */

/* Increment the round number and test if there is a draw. */
    add r9, #1

    /* If there is no draw branch to switchPlayer */
    cmp r9, #9
    bne switchPlayer

    /* Otherwise print the grid, then print the draw message and
       branch to exit */
    bl printGrid

    mov r7, #4
    mov r0, #1
    ldr r1, =str_draw
    ldr r2, =str_draw_len
    ldr r2, [r2]
    swi 0

    b exit

/* Switch the player. */
switchPlayer:
    cmp r12, #88 /* 'X' */
    beq setCircleTurn
    b setCrossTurn

setCrossTurn:
    mov r12, #88 /* 'X' */
    ldr r10, =str_crossTurn
    ldr r11, =str_crossTurn_len
    ldr r11, [r11]
    b testWin

setCircleTurn:
    mov r12, #79 /* 'O' */
    ldr r10, =str_circleTurn
    ldr r11, =str_circleTurn_len
    ldr r11, [r11]

/* Test if the X or O has won */
testWin:
    push {r9, r10, r11, r12} /* saving */

    /* Get all the cells */
    ldrb r4, [r1]
    ldrb r5, [r1, #1]
    ldrb r6, [r1, #2]
    ldrb r7, [r1, #3]
    ldrb r8, [r1, #4]
    ldrb r9, [r1, #5]
    ldrb r10, [r1, #6]
    ldrb r11, [r1, #7]
    ldrb r12, [r1, #8]

/* Branch to win if someone has won */

/* row 1 */
    mov r0, r4
    mov r1, r5
    mov r2, r6
    bl isLine
    cmp r0, #0
    bne win

/* row 2 */
    mov r0, r7
    mov r1, r8
    mov r2, r9
    bl isLine
    cmp r0, #0
    bne win

/* row 3 */
    mov r0, r10
    mov r1, r11
    mov r2, r12
    bl isLine
    cmp r0, #0
    bne win

/* column 1 */
    mov r0, r4
    mov r1, r7
    mov r2, r10
    bl isLine
    cmp r0, #0
    bne win

/* column 2 */
    mov r0, r5
    mov r1, r8
    mov r2, r11
    bl isLine
    cmp r0, #0
    bne win

/* column 3 */
    mov r0, r6
    mov r1, r9
    mov r2, r12
    bl isLine
    cmp r0, #0
    bne win

/* straight line 1 */
    mov r0, r4
    mov r1, r8
    mov r2, r12
    bl isLine
    cmp r0, #0
    bne win

/* straight line 2 */
    mov r0, r6
    mov r1, r8
    mov r2, r10
    bl isLine
    cmp r0, #0
    bne win

/* If there is no win, restore the registers and start a new iteration
   of the game loop. */
    pop {r9, r10, r11, r12}
    b gameLoop

win:
    pop {r9, r10, r11, r12} /* restoring */

    /* Move the previous result of isLine to r4. */
    mov r4, r0

    bl printGrid

    /* Prepare the system call write() to display the winner */
    mov r7, #4
    mov r0, #1

    /* Go to the code that correspond to the winner and print
       the correct message */
    cmp r4, #79 /* 'O' */
    beq 1f

/* The winner is X */
    ldr r1, =str_crossWin
    ldr r2, =str_crossWin_len
    ldr r2, [r2]
    swi 0 /* calling write() */

    b exit

/* The winner is O */
1:
    ldr r1, =str_circleWin
    ldr r2, =str_circleWin_len
    ldr r2, [r2]
    swi 0 /* calling write() */

exit:
/* Write a new line to stdout. (the first character of str_grid is a '\n') */
    mov r7, #4
    mov r0, #1
    ldr r1, =str_grid
    mov r2, #1
    swi 0

/* syscall exit(0) */
    mov r7, #1
    mov r0, #0
    swi 0
