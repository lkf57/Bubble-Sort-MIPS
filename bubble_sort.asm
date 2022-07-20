Bubble Sort Algorithm
Lauren Farr
4-15-22

.data

# allocate 4 bytes * 5 for the data array
dataArray:	.space	40

title:		.asciiz "Bubble Sort Program\n\n"

amount_prompt:	.asciiz "How many numbers do you want (1-10)? "
error_message:	.asciiz "That's not a valid amount.\n"

num_prompt:	.asciiz "Enter number: "
comma_space:	.asciiz ", "

.text
.globl main

# main procedure
main:

	# set up array
	la	$s0, dataArray
	
	# print a title to the user
	li	$v0, 4
	la	$a0, title
	syscall
	
	# allocate 7 words on the stack for $t registers the functions will use
	addiu	$sp, $sp -28
	
	# preserve $t0 - $t6 on the stack
	sw	$t0, 0($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)
	sw	$t3, 12($sp)
	sw	$t4, 16($sp)
	sw	$t5, 20($sp)
	sw	$t6, 24($sp)
	
	# get user-defined amound of numbers, store in array
	jal	ReadNums
	
	# sort the array
	jal	BSort
	
	# print the sorted array
	jal	PrintNums
	
	# restore $t registers from stack
	lw	$t6, 24($sp)
	lw	$t5, 20($sp)
	lw	$t4, 16($sp)
	lw	$t3, 12($sp)
	lw	$t2, 8($sp)
	lw	$t1, 4($sp)
	lw	$t0, 0($sp)
	
	# end program
	li	$v0, 10
	syscall

############################################
	
# procedure to take in a user-specified amount of numbers
# and add those numbers to an array	
ReadNums:


	# allocate 1 word on the stack
	addiu	$sp, $sp, -4
	
	# put $s0 on the stack to preserve it
	sw	$s0, 0($sp)
	
	# set working index for array
	# $s0 should not be incremented or modified
	move	$t0, $s0
	
	# get amount of numbers from user
	li 	$v0, 4
	la 	$a0, amount_prompt
	syscall
		
	li	$v0, 5
	syscall
		
	move	$s1, $v0
	
	# check validity, if not valid, ask again
	bgt	$s1, 10, amount_error
	blt	$s1, 1, amount_error
	
	j	end_ask
	
	# loop to ask user for amount of numbers
	amount_error:
		
		# print error message
		li	$v0, 4
		la	$a0, error_message
		syscall
		
		j 	ReadNums
		
	end_ask:
	
	# get "amount" amount of numbers from the user
	
	# set loop counter
	addi	$t1, $zero, 0
	
	# loop to get a number and put it in the array ("fill the array")
	fill_loop:
	
		# branch is loop count equals amount specified by user
		beq	$t1, $s1, end_fill
		
		# prompt for a number
		li	$v0, 4
		la	$a0, num_prompt
		syscall
		
		li	$v0, 5
		syscall 
		
		# put the number in the array
		sw	$v0, ($t0)
		
		# increment cound and array index
		addi	$t1, $t1, 1
		addi	$t0, $t0, 4
		
		# loop again
		j 	fill_loop
	
	end_fill:
	
	# load $s0 stack value back into $s0
	lw	$s0, 0($sp)
	
	# deallocate 1 word on the stack
	addiu	$sp, $sp, 4
	
	# $s1 is returned
	
	# return to main procedure
	jr	$ra
	
############################################

# procedure to sort the array with bubble sort algorithm
BSort:

	# allocate 2 words on the stack
	addiu	$sp, $sp, -8
	
	# put $s0 and $s1 on the stack 
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	
	# set working index for array,
	# $s0 should not be modified
	move	$t0, $s0

	# set outer counter and n-1
	addi 	$t1, $zero, 0
	sub	$t2, $s1, 1
	
	# set inner counter
	addi	$t3, $zero, 0
	
	# set the working index to beginning of array
	move	$t0, $s0
	
	# begin sorting algorithm
	outer_sort:
	
		# loop until outer counter = n-1 
		beq	$t1, $t2, end_outer
		
		inner_sort:
		
			# loop until inner counter = n-1
			beq	$t3, $t2, end_inner
			
			# get the fisrt value of the array
			lw	$t5, ($t0)
			
			# get the following value of the array
			lw	$t6, 4($t0)
			
			# if the fisrt value is less than the second value, skip next part
			blt	$t5, $t6, skip_sort
			
			# else, switch the places of the two array values
			sw	$t6, ($t0)
			sw	$t5, 4($t0)
			
			skip_sort:
			
			# move to next array index
			addi	$t0, $t0, 4
			
			# increment inner counter
			addi	$t3, $t3, 1
			
			j inner_sort
			
		end_inner:
		
		# reset innter counter and array index
		addi	$t3, $zero, 0
		move	$t0, $s0
		
		# increment outer counter
		addi	$t1, $t1, 1
		
		j	outer_sort
	
	end_outer:
	
	# get stack values back into $s0 and $s1
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	
	# return to main procedure
	jr	$ra

############################################
	
# procedure to print the values of the array
PrintNums:

	# allocate 2 words on the stack
	addiu	$sp, $sp, -8
	
	# put $s0 and $s1 on the stack 
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	
	# set working index for array,
	# $s0 should not be modified
	move	$t0, $s0

	# set loop counter
	addi	$t1, $zero, 0
	
	# loop through array, display values
	display_loop:
	
		beq	$t1, $s1, end_disp
		
		lw	$t2, ($t0)
		move	$a0, $t2
		
		li	$v0, 1
		syscall
		
		li	$v0, 4
		la	$a0, comma_space
		syscall
		
		addi	$t1, $t1, 1
		addi	$t0, $t0, 4
		
		j 	display_loop
		
	end_disp:
	
	# get stack values back into $s0 and $s1
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	
	# return to main procedure
	jr	$ra
	
