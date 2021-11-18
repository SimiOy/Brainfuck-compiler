#  > 	Move the pointer to the right
#  < 	Move the pointer to the left
#  + 	Increment the memory cell at the pointer
#  - 	Decrement the memory cell at the pointer
#  . 	Output the character signified by the cell at the pointer
#  , 	Input a character and store it in the cell at the pointer
#  [ 	Jump past the matching ] if the cell at the pointer is 0
#  ] 	Jump back to the matching [ if the cell at the pointer is nonzero 

.data
list: .skip 4000000

.global brainfuck

.text
open_str: .asciz "Enter here.%d\n"
close_str: .asciz "Close here.%d\n"
outputCurrentCell: .asciz "%c\n"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	pushq %r12
	pushq %r13
	pushq %r14

	movq $0,%r13
	movq $0,%r12

	movq %rdi,%r12 
	#stores entire instruction: vector v
	# easily acces any character in the instruction: v[i]
	# r14 stores all the cells

	movq $list,%r14

	#push empty value on stack as referance
	pushq %r13

	# loop through all charcters (every instruction)
	# I want to store on my stack only "[" and "]" to move through them
	# r8 current character, used for comparison in the switch
	loop:
		movq $0,%r13
		movb (%r12),%r13b
		cmpb $0,%r13b
		je final 
		# end the code

		# >
		cmpb $62,%r13b
		je rightMethod

		# <
		cmpb $60,%r13b
		je leftMethod

		# +
		cmpb $43,%r13b
		je plusMethod

		# -
		cmpb $45,%r13b
		je minusMethod

		# .
		cmpb $46,%r13b
		je pointMethod

		# ,
		cmpb $44,%r13b
		je commaMethod

		# [
		cmpb $91,%r13b
		je openMethod

		# ]
		cmpb $93,%r13b
		je closeMethod

		incq %r12 # only if found any other charcater besides these
		endInstruction:
		jmp loop


	## end of loop
	
	## start of methods	

	plusMethod:
	movq $0,%r11 #auxiliary
	movb (%r14),%r11b

	incb %r11b
	movb %r11b,(%r14)

	incq %r12
	jmp endInstruction


	minusMethod:
	movq $0,%r11 #auxiliary
	movb (%r14),%r11b

	decb %r11b
	movb %r11b,(%r14)

	incq %r12
	jmp endInstruction


	rightMethod:
	incq %r14 # the cell pointer

	incq %r12
	jmp endInstruction


	leftMethod:
	decq %r14 # the cell pointer

	incq %r12
	jmp endInstruction


	pointMethod:
	movq $1, %rax
	movq $1, %rdi
	movq $0, %rsi
	movq %r14,%rsi
	movq $0x1,%rdx
	syscall

	incq %r12
	jmp endInstruction


	commaMethod:
	
	movq $0,%rax
	movq $0,%rdi
	leaq -8(%rsp),%rsi
	movq $10,%rdx
	syscall

	movb (%rsi),%sil
	movb %sil,(%r14)

	incq %r12
	jmp endInstruction


	openMethod:
	cmpb $0,(%r14)
	je jumpPastIt

	# check to see if on stack previous is "]"
	popq %r11
	cmpq %r12,%r11 # if r11 is bigger it means it came from "]"
	jg skipIt

	pushq %r11 # put it back

	# push the instruction pointer onto the stack
	skipIt:
	pushq %r12 # current address of "["
	incq %r12
	jmp endInstruction

		jumpPastIt:
		popq %r11 # take (possible) address of matching "]"
		cmpq %r12,%r11 # if r11 is bigger it means it came from "]"
		jg skipIt2

		pushq %r11 # put it back

		movq $1,%r8 # counter

		# manually look for matching "]"
		incq %r12
		loop2:
			cmpq $0,%r8 # found the match
			je skipIt3

			movq $0,%r13
			movb (%r12),%r13b
			cmpb $93,%r13b # match of "]", decrement counter
			je nextOne

			cmpb $91,%r13b # match of "[", increment counter
			je nextOne2

			nextOne3:
			incq %r12 
			jmp loop2


		skipIt2:
		movq %r11,%r12 # easily matched "[" to his "]"
		
		incq %r12 # and increment it
		skipIt3:
		jmp endInstruction

		nextOne:
		decq %r8
		jmp nextOne3

		nextOne2:
		incq %r8
		jmp nextOne3


	closeMethod:
		cmpb $0,(%r14)
		je moveOn

		popq %r11 # where "[" is stored

		pushq %r12 # current value of where "]" is stored
		movq %r11,%r12 # r12 stores back the "[" value

		jmp endInstruction

		moveOn:
		popq %r11 # pop previous "["
		incq %r12
		jmp endInstruction


	final:

	popq %r14
	popq %r14
	popq %r13
	popq %r12

	movq %rbp, %rsp
	popq %rbp
	ret
