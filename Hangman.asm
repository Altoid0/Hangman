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
	strlen_loop:
		lb $t2, ($a0)   # Load byte from string
		beqz $t2, save   # End loop if byte is null
		addi $a0, $a0, 1   # Increment string pointer
		addi $t1, $t1, 1   # Increment length
		j strlen_loop

	# Store length in length variable
	save:
		subi $t1,$t1,1

.end_macro 


.macro eval_guess()
	# Load the address of secret_word into $s0 and guess_word into $s1
	la $s0, secret_word
	la $s1, guess_word
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
	# load the address of guess_word into $s1
	la $s1, guess_word
	# load the underscore char into $t8
	la $s3, underscore_char
	lb $t8, 0($s3)
	# initialize the loop counter to 0
	move $t9, $zero
	guess_word_loop:
		# store the underscore char into the guess_word buffer
		sb $t8, 0($s1)
		addi $t9, $t9, 1
		beq $t9, $t1, guess_word_loop_end
		addi $s1, $s1, 1
		j guess_word_loop
	guess_word_loop_end:
	print_user_string("\nDEBUG: Guess word initialized: ")
	li $v0, 4
	la $a0, guess_word
	syscall
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

			# Multiply integer by 1.5
			li $t3, 3           # Load 3 into $t3
			mult $t1, $t3       # Multiply by 3
			mflo $t3            # Store the lower 32 bits of the result in $t3		
			div $t3, $t3, 2	    # Divide the number by 2

			# Store result in variable
			sw $t3, guesses
			
			print_user_string("\nDEBUG: number of hard guesses: ")
			lw $a0, guesses
			li $v0, 1
			syscall

			# Initialize guess_word to underscores
			init_guess_word()
			move $t4, $zero
			move $t5, $zero
			j check_word
			
		med_guesses:

			# Multiply integer by 2
			li $t3, 2           # Load 2 into $t3
			mult $t1, $t3       # Multiply by 2
			mflo $t3            # Store the lower 32 bits of the result in $t3	
			
			# Store result in variable
			sw $t3, guesses
			
			print_user_string("\nDEBUG: number of hard medium guesses: ")
			lw $a0, guesses
			li $v0, 1

			# Initialize guess_word to underscores
			init_guess_word()
			move $t4, $zero
			move $t5, $zero
			j check_word
			
		easy_guesses:

			# Multiply integer by 2.5
			li $t3, 5           # Load 5 into $t3
			mult $t1, $t3       # Multiply by 5
			mflo $t3            # Store the lower 32 bits of the result in $t3		
			div $t3, $t3, 2	    # Divide the number by 2

			# Store result in variable
			sw $t3, guesses
			
			print_user_string("\nDEBUG: number of easy guesses: ")
			lw $a0, guesses
			li $v0, 1
			syscall

			# Initialize guess_word to underscores
			init_guess_word()
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
		
		eval_guess()
		
		addi $t4, $t4, 1

		# Check if the guess_word is the same as the secret_word
		la $s4, secret_word
    	la $s5, guess_word

		loop:
			lb $s6, ($s4)      # Load byte from str1
			lb $s7, ($s5)      # Load byte from str2
			beqz $s6, check_word_end     # If end of str1 is reached, go to check
			bne $s6, $s7, not_equal    # If characters are not equal, go to not_equal
			addiu $s4, $s4, 1   # Increment str1 pointer
			addiu $s5, $s5, 1   # Increment str2 pointer
			j loop              # Continue loop
		check_word_end:
    		beqz $s7, equal     # If end of str2 is reached, go to equal
    		j not_equal         # Strings have different lengths
		equal:
			# User guessed the word
			print_user_string("\nYou won!")
			# jump to exit
			j exit
		not_equal:
			# User did not guess the word and is out of guesses jump to lose
			beq $t4, $t3, lose
			# else jump back to check_word
			j check_word

	lose:
		print_user_string("\nSorry you lost! Hangman was hung.")

exit:
    li $v0, 10          # Exit program
    syscall