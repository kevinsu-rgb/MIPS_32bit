 lw $s1, 9($zero)
 lw $s2, 10($zero)
 addu $s3, $s1, $s2
 and $s4, $s2, $s3
 xor $s5, $s3, $s4
 or  $s6, $s3, $s1 
 subu $s7, $s6, $s4
 multu $s3, $s2

 LOOP:
 j LOOP