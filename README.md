MIPS 32 BIT CPU with Assembler for DE-10 Lite Execution

To compile and utliize Assembler:
1. gcc -o main.exe main.c
2. ./main.exe name.asm name.mif (You can choose the name of your .asm and .mif file)
3. Load name.mif into RAM IP provided by Intel

Supported instructions:
- "addu", Add Unsigned, EX: addu $s1, $zero, $zero;
- "addiu", Add Unsigned Immediate, EX: addiu $s1, $s1, 4;
- "subu", Subtract Unsigned, EX: subu $s7, $s6, $s4;
- "subiu", Subtract Immediate Unsigned, EX: subiu $s7, $s6, 4;
- "mult", Multiply Signed, EX: mult $s3, $s2;
- "multu", Multiply unsigned, EX: multu $s3, $s2;

- "and", Bitwise AND, EX: and $s1, $s2, $s3;
- "andi", Bitwise AND Immediate, EX: andi $s1, $s2, 0xFF;
- "or", Bitwise OR, EX: or $s1, $s2, $s3;
- "ori", Bitwise OR Immediate, EX: ori $s1, $s2, 0x10;
- "xor", Bitwise XOR, EX: xor $s1, $s2, $s3;
- "xori", Bitwise XOR Immediate, EX: xori $s1, $s2, 0xFF;

- "sll", Shift Left Logical, EX: sll $s1, $s2, 4;
- "srl", Shift Right Logical, EX: srl $s1, $s2, 4;
- "sra", Shift Right Arithmetic, EX: sra $s1, $s2, 4;

- "slt", Set Less Than, EX: slt $s1, $s2, $s3;
- "slti", Set Less Than Immediate, EX: slti $s1, $s2, 10;
- "sltu", Set Less Than Unsigned, EX: sltu $s1, $s2, $s3;
- "sltiu", Set Less Than Immediate Unsigned, EX: sltiu $s1, $s2, 10;

- "multu", Multiply Unsigned, EX: multu $s1, $s2;
- "mfhi", Move From HI, EX: mfhi $s1;
- "mflo", Move From LO, EX: mflo $s1;

- "lw", Load Word, EX: lw $s1, 0($s2);
- "sw", Store Word, EX: sw $s1, 0($s2);

- "beq", Branch if Equal, EX: beq $s1, $s2, label;
- "bne", Branch if Not Equal, EX: bne $s1, $s2, label;
- "blez", Branch if Less Than or Equal to Zero, EX: blez $s1, label;
- "bgtz", Branch if Greater Than Zero, EX: bgtz $s1, label;
- "bltz", Branch if Less Than Zero, EX: bltz $s1, label;
- "bgez", Branch if Greater Than or Equal to Zero, EX: bgez $s1, label;

![test](2-MIPSgeneralArch.pdf)


- "j", Jump, EX: j label;
- "jal", Jump and Link, EX: jal function;
- "jr", Jump Register, EX: jr $ra;



