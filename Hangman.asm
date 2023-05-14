# Names: Tony Diaz, Xavier Felix, Tanay Shah, Clifton Williams
# Class: 2640.01
# Date: 5/7/23
# Objective
# - Create a hangman game
# - Have a user enter a word
# - Store that word and have a 2nd user try and guess it
# - For every incorrect letter guess add a body part to the hangman
# - For ever correct letter guess print the letter in the correct spot
# List of registers
# $s0: secret_word
# $s1: guess_word
# $s2: guess_char
# $t0: difficulty
# $t1: length
# $t2: length (diplicate)
# $t3: guesses
# $t4: loop counter for guesses
# $t5: loop counter for secret_word
# $t6: secret_word char
# $t7: guess_char
# $t8: guess



.data
menu:				.asciiz "\nWelcome to the Byte Dynasty Hangman game\nPlease enter the difficulty at which you want to play\nThen please have a friend enter a word for you to guess"
difficulty:			.asciiz "\n\nPlease enter the difficulty 1 (hardest) to 3 (easiest) you wish to play at: "
inval_diff: 		.asciiz "\n Sorry the difficulty entered was not valid, please try again"
word_message: 		.asciiz "\nYour word?: "
clear:				.asciiz "\n\n\n\n\n\n\n\n\n"
incorrect_guess:	.asciiz "\nSorry that's not a letter in the word"
guess_mesage:		.asciiz "\nGuess a letter: "
lose_message:		.asciiz "\nSorry you lost, the word was: "
win_message: 		.asciiz "\nCongratulations, You win!"
underscore_char: 	.asciiz "_"
secret_word: 		.space 20
guess_word:			.space 20
guess_char: 		.space 1
guesses:			.word 0

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


.macro eval_guess()
	# Load the user's guessed char into $t7
	la $s2, guess_char 
	lb $t7, 0($s2)
	# S0: secret_word
	# s1: guess_word
	secret_word_loop:
		# Load char from secret_word
		lb $t6, ($s0)
		
		# if guess_char equals secret_word char jump to store_char
		beq $t6, $t7, store_char
		
		# continue with loop after either storing char or not
		eval_guess_continue:
		addi $s0, $s0, 1	# increment secret_word pointer
		addi $s1, $s1, 1	# increment guess_word pointer in parallel
		addi $t5, $t5, 1	# increment loop counter
		
		beq $t5, $t1, secret_word_loop_end
		j secret_word_loop
	
	store_char:
		# Store the byte from $t8 (guess_char) into the buffer for guess_word
		sb $t7, 0($s1)
		j eval_guess_continue
		
	secret_word_loop_end:
	# Do nothing, just here to skip past store_char
.end_macro


.macro init_guess_word()
	la $s3, underscore_char
	lb $t8, 0($s3)
	move $t9, $zero
	guess_word_loop:
		sb $t8, 0($s3)
		addi $t9, $t9, 1
		beq $t9, $t1, guess_word_loop_end
		addi $s3, $s3, 1
		j guess_word_loop
	guess_word_loop_end:
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

		# Initialize guess_word to underscores
		init_guess_word()
		
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
			# Initialize loop counter
			la $s0, secret_word
			la $s1, guess_word
			move $t4, $zero
			move $t5, $zero
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
			# Initialize loop counter
			la $s0, secret_word
			la $s1, guess_word
			move $t4, $zero
			move $t5, $zero
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
			# Initialize loop counter and secret word array
			la $s0, secret_word
			la $s1, guess_word
			move $t4, $zero
			move $t5, $zero
			j check_word

		# loop through $t3 number of times (only issue is printing out limbs, how does that work with dynamic tries)
		#	get user letter input
		#	loop through secret_word streing_len number of times
		# 	if equal set the corresponding letter in the guess_word to the user entered one
		# check the enture words to see if they re equal
	check_word:
	
		print_user_string("\nGuess a letter: ")
		li $v0, 8
		la $a0, guess_char
		li $a1, 1
		syscall
		
		evaluate_guess()
			
		beq # if the two strings are equal then branch to win
		addi $t4, $t4, 1
		beq $t4, $t3, lose
		j check_word
	lose:
		print_user_string("\nSorry you lost! Hangman was hung.")
		
		
		
		
