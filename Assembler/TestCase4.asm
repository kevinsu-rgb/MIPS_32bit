lw $s1, 9($zero)
lw $s2, 10($zero)
multu $s1, $s2
mfhi $s3
mflo $s4
mult $s1, $s2
mfhi $s5
mflo $s6
 
LOOP:
j LOOP