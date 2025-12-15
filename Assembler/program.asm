jal MAIN
Infinite_LOOP:
j Infinite_LOOP

MAIN:
addu $s1, $zero, $zero

TEMP:
lw $s2, 10($s1)
beq $s2, $zero, FINISH
addiu $s1, $s1, 4
addu $s3, $s3, $s2
j TEMP

FINISH:
sw $s3, 16383($zero)
jr $ra