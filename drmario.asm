################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Khoa Pham, 1006260216
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    128
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
.eqv PIXEL 4
    
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
    
    
game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    # j game_loop
    
    
sleep:
    li $v0, 32
    li $a0, 1000
    syscall

main:
    li $t1, 0xff0000        # $t1 = red
    li $t2, 0x00ff00        # $t2 = green
    li $t3, 0x0000ff        # $t3 = blue
    li $t4, 0x808080        # $t4 = grey
    li $t9, 0x000000        # $t9 = black

    lw $t0, ADDR_DSPL       # $t0 = base address for display
    jal draw_bottle
    jal draw_capsule
    #jal draw_virus
        
exit:
    li $v0, 10              # terminate the program gracefully
    syscall

    # Initialize the game


draw_virus:
    # column 1-16 (pixels 4-56), row 3-30 (pixels 192-1920)
    addi $t7, $ra, 0        # store the return address to main
    jal _random_col
    addi $t5, $a0, 1        # store the random column of the virus
    jal _random_row
    addi $t6, $a0, 3        # store the random row of the virus
    jal _locate
    jal _random             # $t9 is now free to use!
    addi $t9, $a0, 0        # store the random color of the virus
    
    jal _draw_virus
    addi $ra, $t7, 0        # restore value of $ra
    jr $ra                  # return to main    
    


draw_capsule:
    addi $t7, $ra, 0        # store the return address to main
    jal _random
    addi $t5, $a0, 0        # store the random color of first capsule half
    jal _random
    addi $t6, $a0, 0        # store the random color of second capsule half
first_half:    
    bne $t5, 0, ELSEIF1     # if $t5 = 0, draw red, else branch to ELSEIF1
    sw $t1, 156($t0)        # create first half of the capsule
    j second_half
ELSEIF1:
    bne $t5, 1, ELSE        # if $t5 = 1, draw green, else branch to ELSEIF1
    sw $t2, 156($t0)        # create first half of the capsule
    j second_half
ELSE:
    sw $t3, 156($t0)        # create first half of the capsule (BLUE)
second_half:
    bne $t6, 0, ELSEIF2     # if $t6 = 0, draw red, else branch to ELSEIF2
    sw $t1, 160($t0)        # create second half of the capsule
    j RETURN
ELSEIF2:
    bne $t6, 1, ELSE2       # if $t6 = 1, draw green, else branch to ELSE2
    sw $t2, 160($t0)        # create second half of the capsule
    j RETURN
ELSE2:
    sw $t3, 160($t0)        # create second half of the capsule (BLUE)
RETURN:    
    addi $ra, $t7, 0        # restore value of $ra
    jr $ra                  # return to main    


draw_bottle:
    sw $t4, 24($t0)         # paint the 7th unit grey
    sw $t4, 36($t0)         # paint the 10th unit grey


    addi $t7, $ra, 0        # store the return address to main
    
    jal _draw_horizontals    # paint 1st - 16th units grey (top and bottom of bottle)
    sw $t9, 92($t0)        # paint 8th unit black (adjust for the opening of bottle) 
    sw $t9, 96($t0)        # paint 9th unit black (adjust for the opening of bottle)
                          
    jal _draw_verticals      # (paint 1st unit grey, paint 16th unit grey) -- repeat 14 times
    
    addi $ra, $t7, 0        # restore value of $ra
    jr $ra                  # return to main


################################## Helper Functions ################################################    
_draw_horizontals:           # helper for draw_bottle (draw the horizontal lines) -- use $t5, $t6
    addi $t6, $zero, 64     # location adjustment counter for $t5
    add $t5, $t0, $t6       # start at the first pixel of 2nd line
loop:
    beq $t6, 128, end       # break loop if (go to new line) pass the 16th horizontal pixel
    sw $t4, 0($t5)          # paint the current location grey
    sw $t4, 1920($t5)       # paint the pixel on 16th line of the same column grey (14 lines from $t5)
update:
    addi $t6, $t6, 4        # update the location adjustment counter (16X32 grid)
    addi $t5, $t5, 4        # move to the next pixel (to the right)
    j loop
end:
    jr $ra                  # return to draw_bottle

    
_draw_verticals:             # helper for draw_bottle (draw the 2 vertical lines)
    addi $t6, $zero, 128    # location adjustment for $t5
    add $t5, $t0, $t6       # start at the first pixel of 3rd line
LOOP:
    beq $t6, 1984, END      # break loop if pass the 16th vertical pixel
    sw $t4, 0($t5)          # paint the first pixel of current line grey
    sw $t4, 60($t5)         # paint the last pixel of current line grey
UPDATE:
    addi $t6, $t6, 64      # update the common counter
    addi $t5, $t5, 64      # move to the next pixel (first of next line)
    j LOOP
END:
    jr $ra                  #return to draw_bottle
    
    
_random:
    li $v0, 42
    li $a0, 0   # return value eventually stores here
    li $a1, 3   # generate random number between 0 and 2
    syscall
    jr  $ra


_random_col:
    li $v0, 42
    li $a0, 0   # return value eventually stores here
    li $a1, 16   # generate random number between 0 and 15
    syscall
    jr  $ra


_random_row:
    li $v0, 42
    li $a0, 0   # return value eventually stores here
    li $a1, 28   # generate random number between 0 and 27
    syscall
    jr  $ra
    
    
_locate:
    # $t5 col, $t6 row
    # move to the desire location ($t6, $t5)
    addi $t8, $zero, 0      # incrementer for row
    addi $t9, $zero, 0      # incrementer for column
    START_ROW: 
        beq $t8, $t6, START_COLUMN
    INCREMENT_ROW: 
        addi $t8, $t8, 64    # $t8+=64
        j START_ROW
    START_COLUMN: 
        beq $t9, $t5, EXIT
    INCREMENT_COLUMN: 
        addi $t9, $t9, 4    # $t9+=4
        j START_COLUMN
    EXIT:
        add $t8, $t8, $t9   #$t8 += $t9
        add $t8, $t0, $t8   #$t8 += $t0
        

_draw_virus:
    bne $t8, 0, ELSEIF2     # if $t6 = 0, draw red, else branch to ELSEIF2
    sw $t1,                 # create second half of the capsule
    j return_virus
elseifvirus:
    bne $t8, 1, elsevirus   # if $t6 = 1, draw green, else branch to ELSE2
    sw $t2,                 # create second half of the capsule
    j return_virus
elsevirus:
    sw $t3,         # create second half of the capsule (BLUE)
return_virus:    
    addi $ra, $t7, 0        # restore value of $ra
    jr $ra                  # return to main    

