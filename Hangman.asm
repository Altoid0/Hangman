# Names: Tony Diaz, Xavier Felix, Tanay Shah, Clifton Williams
# Class: 2640.01
# Date: 5/7/23
# Objective
# - Create a hangman game
# - Have a user enter a word
# - Store that word and have a 2nd user try and guess it
# - For every incorrect letter guess add a body part to the hangman
# - For ever correct letter guess print the letter in the correct spot

.data
menu:			.asciiz "\nWelcome to the Byte Dynasty Hangman game\nPlease enter the difficulty at which you want to play\nThen please have a friend enter a word for you to guess"
difficulty:		.asciiz "\n\nPlease enter the difficulty 1 (hardest) to 3 (easiest) you wish to play at: "
inval_diff: 		.asciiz "\n Sorry the difficulty entered was not valid, please try again"
word_message: 		.asciiz "\nYour word?: "
clear:			.asciiz "\n\n\n\n\n\n\n\n\n"
incorrect_guess:	.asciiz "\nSorry that's not a letter in the word"
guess_mesage:		.asciiz "\nGuess a letter: "
lose_message:		.asciiz "\nSorry you lost, the word was: "
win_message: 		.asciiz "\nCongratulations, You win!"
secret_word: 		.space 20
guesses:		.word 0


.macro print_user_string(%strings)
.data
user_string: .asciiz %strings

.text
li $v0, 4
la $a0, user_string
syscall
.end_macro

.macro get_int_input(%reg)
    li $v0, 5
    syscall
    move %reg, $v0
.end_macro

.macro get_strlen(%string)
# Load address of string into $a0
la $a0, %string

# Loop through string
loop:
    lb $t0, ($a0)   # Load byte from string
    beqz $t0, save   # End loop if byte is null
    addi $a0, $a0, 1   # Increment string pointer
    addi $t1, $t1, 1   # Increment length
    j loop

# Store length in length variable
save:
subi $t1,$t1,1

.end_macro 



.text
main:
	print_user_string("\nWelcome to the Byte Dynasty Hangman game\nPlease enter the difficulty at which you want to play\nThen please have a friend enter a word for you to guess")
	select_difficulty:
		print_user_string("\n\nPlease enter the difficulty 1 (hardest) to 3 (easiest) you wish to play at: ")
		get_int_input($t0)
		beq $t0,1,diff_hard
		beq $t0,2,diff_med
		beq $t0,3,diff_easy
		print_user_string("\n Sorry the difficulty entered was not valid, please try again")
		j select_difficulty
		
		diff_hard:
			print_user_string("\nYou've selected the hard mode")
			j set_guesses
		diff_med:
			print_user_string("\nYou've selected the medium mode")
			j set_guesses
		diff_easy:
			print_user_string("\nYou've selected the easy mode")
			j set_guesses

	set_guesses:
		print_user_string("\nYour word?: ")
		li $v0, 8
		la $a0, secret_word
		li $a1, 20
		syscall
		
		get_strlen(secret_word)
		print_user_string("\nDEBUG: String Length: ")
		li $v0, 1
		la $a0, ($t1)
		syscall
		
		beq $t0,1,hard_guesses
		beq $t0,2,med_guesses
		beq $t0,3,easy_guesses
		
		hard_guesses:
			# Load length into $t2
			move $t2, $t1
			
			# Multiply integer by 1.5
			li $t3, 3           # Load 3 into $t3
			mult $t2, $t3       # Multiply by 3
			mflo $t3            # Store the lower 32 bits of the result in $t3		
			div $t3, $t3, 2	    # Divide the number by 2

			# Store result in variable
			sw $t3, guesses
			
			print_user_string("\nDEBUG: number of hard guesses: ")
			lw $a0, guesses
			li $v0, 1
			syscall
			j check_word
			
		med_guesses:
			# Load length into $t2
			move $t2, $t1
			
			# Multiply integer by 2
			li $t3, 2           # Load 2 into $t3
			mult $t2, $t3       # Multiply by 2
			mflo $t3            # Store the lower 32 bits of the result in $t3	
			
			# Store result in variable
			sw $t3, guesses
			
			print_user_string("\nDEBUG: number of hard medium guesses: ")
			lw $a0, guesses
			li $v0, 1
			syscall
			j check_word
			
		easy_guesses:
			# Load length into $t2
			move $t2, $t1
			
			# Multiply integer by 2.5
			li $t3, 5           # Load 5 into $t3
			mult $t2, $t3       # Multiply by 5
			mflo $t3            # Store the lower 32 bits of the result in $t3		
			div $t3, $t3, 2	    # Divide the number by 2

			# Store result in variable
			sw $t3, guesses
			
			print_user_string("\nDEBUG: number of easy guesses: ")
			lw $a0, guesses
			li $v0, 1
			syscall
			j check_word

	check_word:
		
