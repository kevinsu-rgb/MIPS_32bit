#include <stdio.h>
#include <string.h>
#include <stdint.h> 
#include <stdlib.h>
#include <ctype.h>
#include <stdbool.h>

// Assembler will automatially *4 the address for word alignment
// Max 256 instructions, 8-bit address space
// Outport is 0xFFFC/16383 = *4 = 65532
#define MAX_LABELS 256

#define ADDU_Code "100001"
#define SUBU_Code "100011"
#define MULT_Code "011000"
#define MULTU_Code "011001"
#define AND_Code "100100"
#define OR_Code "100101"
#define XOR_Code "100110"
#define SRL_Code "000010"
#define SLL_Code "000000"
#define SRA_Code "000011"
#define SLT_Code "101010"
#define SLTU_CODE "101010" 
#define MFHI_CODE "010000"
#define MFLO_CODE "010010"
#define BLTZ_CODE "00000"
#define BGEZ_CODE "00001"
#define JR_CODE "001000"

typedef struct {
    char name[32];
    int address;
} Label;

typedef struct {
    Label labels[MAX_LABELS];
    int count;
} LabelTable;

typedef struct {
    const char* Name;
    const char* Instruction_Type; // I, R, J
    const char* Special;
    const char* Specific_Code;
} Instruction;

typedef struct {
    const char* name;
    int code;
} Register;

// Convert to Hashmap if table gets too big
Instruction Instruction_Table[] = {
   {"addu", "R", "000000", ADDU_Code}, {"addiu", "I", "001001", NULL}, {"subu", "R", "000000", SUBU_Code},
   {"subiu", "I", "010000", NULL}, {"mult", "R", "000000", MULT_Code}, {"multu", "R", "000000", MULTU_Code},
   {"and", "R", "000000", AND_Code}, {"andi", "I", "001100", NULL}, {"or", "R", "000000", OR_Code},
   {"ori", "I", "001101", NULL}, {"xor", "R", "000000", XOR_Code}, {"xori", "I", "001110", NULL},
   {"srl", "R", "000000", SRL_Code}, {"sll", "R", "000000", SLL_Code}, {"sra", "R", "000000", SRA_Code},
   {"slt", "R", "000000", SLT_Code}, {"slti", "I" "001010", NULL}, {"sltiu", "I", "001011", NULL},
   {"sltu", "R", "000000", SLTU_CODE}, {"mfhi", "R", "000000", MFHI_CODE}, {"mflo", "R", "000000", MFLO_CODE},
   {"lw", "I", "100011", NULL}, {"sw", "I", "101011", NULL}, {"beq", "I", "000100", NULL},
   {"bne", "I", "000101", NULL}, {"blez", "I", "000110", "00000"}, {"bgtz", "I", "000111", "00000"},
   {"bltz", "I", "000001", "00000"}, {"bgez", "I", "000001", "00001"}, {"j", "J", "000010", NULL},
   {"jal", "J", "000011", NULL}, {"jr", "R", "000000", NULL} // Come back to jr
};

Label label_table[] = {};

// Convert to Hashmap if table gets too big
Register register_table[] = {
    {"$zero", 0}, {"$at", 1}, {"$v0", 2}, {"$v1", 3},
    {"$a0", 4}, {"$a1", 5}, {"$a2", 6}, {"$a3", 7},
    {"$t0", 8}, {"$t1", 9}, {"$t2", 10}, {"$t3", 11},
    {"$t4", 12}, {"$t5", 13}, {"$t6", 14}, {"$t7", 15},
    {"$s0", 16}, {"$s1", 17}, {"$s2", 18}, {"$s3", 19},
    {"$s4", 20}, {"$s5", 21}, {"$s6", 22}, {"$s7", 23},
    {"$t8", 24}, {"$t9", 25}, {"$k0", 26}, {"$k1", 27},
    {"$gp", 28}, {"$sp", 29}, {"$fp", 30}, {"$ra", 31},
    {NULL, -1} // Sentinel value
};

// Remove trailing comma from a register string
void strip_comma(char* reg) {
    size_t len = strlen(reg);
    if (len > 0 && reg[len - 1] == ',') {
        reg[len - 1] = '\0';
    }
}

int get_register_code(const char* reg) {
    char reg_clean[32];
    strncpy(reg_clean, reg, 31);
    reg_clean[31] = '\0';
    strip_comma(reg_clean);

    // // First, check for $r#
    // if (reg_clean[0] == '$' && (reg_clean[1] == 'r')) {
    //     int num = atoi(&reg_clean[2]);
    //     if (num >= 0 && num <= 31) return num;
    // }

    // Then check for aliases
    for (int i = 0; register_table[i].name != NULL; i++) {
        if (strcmp(reg_clean, register_table[i].name) == 0)
            return register_table[i].code;
    }

    // Not found
    fprintf(stderr, "Unknown register: %s\n", reg_clean);
    return -1;
}

// Initialize label table
void init_label_table(LabelTable* table) {
    table->count = 0;
}

// Add a label to the table
int add_label(LabelTable* table, const char* name, int address) {
    if (table->count >= MAX_LABELS) {
        fprintf(stderr, "Label table full!\n");
        return -1;
    }
    strncpy(table->labels[table->count].name, name, 31);
    table->labels[table->count].name[31] = '\0';
    table->labels[table->count].address = address;
    table->count++;
    return 0;
}

// Find a label's address by name
int find_label_address(LabelTable* table, const char* name) {
    for (int i = 0; i < table->count; i++) {
        if (strcmp(table->labels[i].name, name) == 0) {
            return table->labels[i].address;
        }
    }
    return -1; // Not found
}

void int_to_bin_str(int value, int bits, char *output) {
    for (int i = bits - 1; i >= 0; i--) {
        output[bits - 1 - i] = (value & (1 << i)) ? '1' : '0';
    }
    output[bits] = '\0';
}

// Helper to lowercase a copy of a string
void to_lower(const char* src, char* dest) {
    while (*src) {
        *dest++ = tolower((unsigned char)*src++);
    }
    *dest = '\0';
}

// Main Decode Function
int decode_instruction(char* instruction){
    char lowered[100];
    to_lower(instruction, lowered);
    for(int i = 0; Instruction_Table[i].Name != NULL; i++){
        if(strcmp(lowered, Instruction_Table[i].Name) == 0){
            return i;
        }
    }
    return -1;
}

// Chech for branch instruction
int is_branch_instruction(const char *type, bool *flag) {
    *flag = strcmp(type, "blez") == 0 ||
            strcmp(type, "bgtz") == 0 ||
            strcmp(type, "bltz") == 0 ||
            strcmp(type, "bgez") == 0;

    return strcmp(type, "beq") == 0 ||
           strcmp(type, "bne") == 0 ||
           *flag;
}

int parse_line(char* line, char* machine_code, LabelTable* label_table, int address) {
    int rs = 0, rt = 0, rd = 0;
    char *firstWord = strtok(line, " \t\n\r");
    if (!firstWord) return -1;

    int instruction_index = decode_instruction(firstWord);
    if (instruction_index == -1) return -1;

    char *type = Instruction_Table[instruction_index].Name;
    bool branch_no2_reg = false;
    if (is_branch_instruction(type, &branch_no2_reg)) {
        char *reg = strtok(NULL, " \t\n\r");
        if(!branch_no2_reg){
            char *rt_str = strtok(NULL, " \t\n\r");
            rt = get_register_code(rt_str);
            if (rt == -1) return -1;
        }
        rs = get_register_code(reg);
        if (rs == -1) return -1;
        char *label = strtok(NULL, " \t\n\r");
        int label_addr = find_label_address(label_table, label) - (address + 1);
        printf("Label '%s' found at address %d\n", label, label_addr);
        if (label_addr == -1) {
            fprintf(stderr, "Label not found: %s\n", label);
            return -1;
        }
        char rs_bin[6], rt_bin[6], imm_bin[17];
        int_to_bin_str(rs, 5, rs_bin);
        int_to_bin_str(label_addr, 16, imm_bin);
        // TODO: Encode branch instruction with rs and offset
        if(!branch_no2_reg){
            int_to_bin_str(rt, 5, rt_bin);
            printf("Label '%s' found at address %d\n", label, label_addr);
            snprintf(machine_code, 33, "%s%s%s%s", Instruction_Table[instruction_index].Special, rs_bin, rt_bin, imm_bin);
        }
        else{
            snprintf(machine_code, 33, "%s%s%s%s", Instruction_Table[instruction_index].Special, rs_bin, Instruction_Table[instruction_index].Specific_Code, imm_bin);
        }
    }
    else if(strcmp(Instruction_Table[instruction_index].Name, "jr") == 0){
        char *rs_str = strtok(NULL, " \t\n\r");
        rs = get_register_code(rs_str);
        printf("JR rs: %s code: %d\n", rs_str, rs);
        if (rs == -1) return -1;
        char rs_bin[6];
        int_to_bin_str(rs, 5, rs_bin);
        snprintf(machine_code, 33, "%s%s%s%s%s", Instruction_Table[instruction_index].Special, rs_bin, "0000000000", "00000", JR_CODE);
    }
    else if (strcmp(Instruction_Table[instruction_index].Name, "lw") == 0 ||
        strcmp(Instruction_Table[instruction_index].Name, "sw") == 0) {
        // lw rt, offset(base)
        char *rt_str = strtok(NULL, " \t\n\r");
        char *mem_str = strtok(NULL, " \t\n\r");
        int rt = get_register_code(rt_str);

        // Parse offset(base)
        int offset = 0, base = 0;
        char *paren = strchr(mem_str, '(');
        if (paren) {
            *paren = '\0'; // Split offset and base
            offset = atoi(mem_str);
            char *base_str = paren + 1;
            char *end_paren = strchr(base_str, ')');
            if (end_paren) *end_paren = '\0';
            base = get_register_code(base_str);
        } else {
            // Error: invalid format
            fprintf(stderr, "Invalid lw/sw format: %s\n", mem_str);
            return -1;
        }
        offset *= 4; // Word address to byte address
        char base_bin[6], rt_bin[6], offset_bin[17];
        int_to_bin_str(base, 5, base_bin);
        int_to_bin_str(rt, 5, rt_bin);
        int_to_bin_str(offset, 16, offset_bin);
        snprintf(machine_code, 33, "%s%s%s%s", Instruction_Table[instruction_index].Special, base_bin, rt_bin, offset_bin);
    }
    else if(strcmp(Instruction_Table[instruction_index].Name, "mfhi") == 0 || 
            strcmp(Instruction_Table[instruction_index].Name, "mflo") == 0){
        char *rd_str = strtok(NULL, " \t\n\r");
        rd = get_register_code(rd_str);
        if (rd == -1) return -1;
        char rd_bin[6];
        int_to_bin_str(rd, 5, rd_bin);
        snprintf(machine_code, 33, "%s%s%s%s%s", Instruction_Table[instruction_index].Special, "0000000000", rd_bin, "00000", Instruction_Table[instruction_index].Specific_Code);
    }
    else if(strcmp(Instruction_Table[instruction_index].Name, "srl") == 0 || 
            strcmp(Instruction_Table[instruction_index].Name, "sll") == 0 ||
            strcmp(Instruction_Table[instruction_index].Name, "sra") == 0){
        char *rd_str = strtok(NULL, " \t\n\r");
        char *rt_str = strtok(NULL, " \t\n\r");
        char *shamt_str = strtok(NULL, " \t\n\r");
        int shamt = shamt_str ? atoi(shamt_str) : 0;
        rd = get_register_code(rd_str);
        rt = get_register_code(rt_str);
        if (rd == -1 || rt == -1) return -1;
        char rd_bin[6], rt_bin[6], sa[6];
        int_to_bin_str(rd, 5, rd_bin);
        int_to_bin_str(rt, 5, rt_bin);
        int_to_bin_str(shamt, 5, sa);
        snprintf(machine_code, 33, "%s%s%s%s%s%s", Instruction_Table[instruction_index].Special, "00000", rt_bin, rd_bin, sa, Instruction_Table[instruction_index].Specific_Code);
    }
    else if(strcmp(Instruction_Table[instruction_index].Name, "multu") == 0 || 
            strcmp(Instruction_Table[instruction_index].Name, "mult") == 0 ){
            char *rs_str = strtok(NULL, " \t\n\r");
            char *rt_str = strtok(NULL, " \t\n\r");
            rs = get_register_code(rs_str);
            rt = get_register_code(rt_str);
            if (rd == -1 || rs == -1 || rt == -1) return -1;
            char rs_bin[6], rt_bin[6];
            int_to_bin_str(rs, 5, rs_bin);
            int_to_bin_str(rt, 5, rt_bin);
            snprintf(machine_code, 33, "%s%s%s%s%s%s", Instruction_Table[instruction_index].Special, rs_bin, rt_bin, "0000000000", Instruction_Table[instruction_index].Specific_Code);
    }
    else if (strcmp(Instruction_Table[instruction_index].Instruction_Type, "R") == 0) {
        char *rd_str = strtok(NULL, " \t\n\r");
        char *rs_str = strtok(NULL, " \t\n\r");
        char *rt_str = strtok(NULL, " \t\n\r");
        printf("R-type operands: rd=%s, rs=%s, rt=%s\n", rd_str, rs_str, rt_str);
        rd = get_register_code(rd_str);
        rs = get_register_code(rs_str);
        rt = get_register_code(rt_str);
        printf("R-type codes: rd=%d, rs=%d, rt=%d\n", rd, rs, rt);
        if (rd == -1 || rs == -1 || rt == -1) return -1;
        // TODO: Encode R-type instruction
        char rs_bin[6], rt_bin[6], rd_bin[6];
        int_to_bin_str(rs, 5, rs_bin);
        int_to_bin_str(rt, 5, rt_bin);
        int_to_bin_str(rd, 5, rd_bin);
        snprintf(machine_code, 33, "%s%s%s%s%s%s", Instruction_Table[instruction_index].Special, rs_bin, rt_bin, rd_bin, "00000", Instruction_Table[instruction_index].Specific_Code);
    }
    else if (strcmp(Instruction_Table[instruction_index].Instruction_Type, "I") == 0) {
        char *rt_str = strtok(NULL, " \t\n\r");
        char *rs_str = strtok(NULL, " \t\n\r");
        char *imm_str = strtok(NULL, " \t\n\r");
        rt = get_register_code(rt_str);
        rs = get_register_code(rs_str);
        int imm = imm_str ? atoi(imm_str) : 0;
        if (rt == -1 || rs == -1) return -1;
        char rs_bin[6], rt_bin[6], imm_bin[17];
        int_to_bin_str(rs, 5, rs_bin);
        int_to_bin_str(rt, 5, rt_bin);
        int_to_bin_str(imm, 16, imm_bin);
        // TODO: Encode I-type instruction
        snprintf(machine_code, 33, "%s%s%s%s%s%s", Instruction_Table[instruction_index].Special, rs_bin, rt_bin, imm_bin);
    }
    else if (strcmp(Instruction_Table[instruction_index].Instruction_Type, "J") == 0) {
        char *label = strtok(NULL, " \t\n\r");
        int label_addr = find_label_address(label_table, label);
        printf("Label '%s' found at address %d\n", label, label_addr);
        if (label_addr == -1) {
            fprintf(stderr, "Label not found: %s\n", label);
            return -1;
        }
        char rs_bin[6], rt_bin[6], instr_index[17];
        int_to_bin_str(label_addr, 26, instr_index);
        // TODO: Encode J-type instruction
        snprintf(machine_code, 33, "%s%s", Instruction_Table[instruction_index].Special, instr_index);
    }
    else {
        // Unknown instruction type
        return -1;
    }
    return 0;
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        printf("Usage: %s <input.asm> <output.mif>\n", argv[0]);
        return 1;
    }
    if (strstr(argv[1], ".asm") == NULL || strstr(argv[2], ".mif") == NULL) {
        printf("Input or output file extension error.\n");
        return 1;
    }

    const char* input_filename = argv[1];
    const char* output_filename = argv[2];

    FILE *fin = fopen(input_filename, "r");
    FILE *fout = fopen(output_filename, "w");
    if (!fin || !fout) {
        printf("Error: could not open input or output file.\n");
        return 1;
    }

    // Write MIF header
    fprintf(fout, "WIDTH=32;\nDEPTH=256;\n\nADDRESS_RADIX=HEX;\nDATA_RADIX=BIN;\n\nCONTENT BEGIN\n");

    LabelTable label_table;
    init_label_table(&label_table);

    // First pass: collect labels
    char line[256];
    int address = 0;
    rewind(fin);
    while (fgets(line, sizeof(line), fin)) {
        char *trimmed = line;
        while (isspace(*trimmed)) trimmed++;
        char *colon = strchr(trimmed, ':');
        if (colon) {
            *colon = '\0';
            add_label(&label_table, trimmed, address);
            trimmed = colon + 1;
            while (isspace(*trimmed)) trimmed++;
            if (*trimmed == '\0') continue;
        }
        if (*trimmed != '\0' && *trimmed != '#') {
            address++;
        }
    }

    for (int i = 0; i < label_table.count; i++) {
    printf("Label %d: %s at address %d\n", i, label_table.labels[i].name, label_table.labels[i].address);
    }
    // Second pass: assemble instructions
    rewind(fin);
    address = 0;
    while (fgets(line, sizeof(line), fin)) {
        char *trimmed = line;
        while (isspace(*trimmed)) trimmed++;
        char *colon = strchr(trimmed, ':');
        if (colon) {
            trimmed = colon + 1;
            while (isspace(*trimmed)) trimmed++;
            if (*trimmed == '\0') continue;
        }
        if (*trimmed != '\0' && *trimmed != '#') {
            char machine_code[33];
            char line_copy[256];
            strncpy(line_copy, trimmed, sizeof(line_copy));
            line_copy[sizeof(line_copy)-1] = '\0';
            if (parse_line(line_copy, machine_code, &label_table, address) == -1) {
                fprintf(stderr, "Error parsing line: %s\n", trimmed);
                continue;
            }
            fprintf(fout, "%02X : %s;\n", address, machine_code);
            address++;
        }
    }

    fprintf(fout, "END;\n");
    fclose(fin);
    fclose(fout);

    printf("Assembled %s to %s\n", input_filename, output_filename);
    return 0;
}
