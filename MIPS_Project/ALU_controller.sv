module ALU_controller (
    input  logic [5:0] ALUOp,
    input  logic [5:0] IR5_0,
    input  logic [4:0] IR20_16,
    output logic       HI_en,
    output logic       LO_en,
    output logic [1:0] ALU_LO_HI,
    output logic [4:0] OPSelect
);

    // Operation Select Constants
    localparam [4:0] ALU_ADD = 5'b00000,
                     ALU_SUB = 5'b00001,
                     ALU_UML = 5'b00011,
                     ALU_SML = 5'b00010,
                     ALU_AND = 5'b00100,
                     ALU_ORR = 5'b00101,
                     ALU_XOR = 5'b00110,
                     ALU_SLL = 5'b01000,
                     ALU_SRL = 5'b00111,
                     ALU_SRA = 5'b01001,
                     ALU_LTS = 5'b01010,
                     ALU_LTU = 5'b01011,
                     ALU_BEQ = 5'b01100,
                     ALU_BNE = 5'b01101,
                     ALU_BLQ = 5'b01110,
                     ALU_BGT = 5'b01111,
                     ALU_BLT = 5'b10000,
                     ALU_BGQ = 5'b10001,
                     ALU_OIN = 5'b10010,
                     ALU_NOP = 5'b10011,
                     ALU_RTP = 5'b10100;

    always_comb begin
        HI_en       = 1'b0;
        LO_en       = 1'b0;
        ALU_LO_HI   = 2'b00;
        OPSelect    = ALU_NOP;

        case (ALUOp)
            6'b000000: begin  // R-type
                case (IR5_0)
                    6'b100001: OPSelect = ALU_ADD;
                    6'b100011: OPSelect = ALU_SUB;
                    6'b011000: begin
                        OPSelect = ALU_SML;
                        HI_en    = 1'b1;
                        LO_en    = 1'b1;
                    end
                    6'b011001: begin
                        OPSelect = ALU_UML;
                        HI_en    = 1'b1;
                        LO_en    = 1'b1;
                    end
                    6'b100100: OPSelect = ALU_AND;
                    6'b100101: OPSelect = ALU_ORR;
                    6'b100110: OPSelect = ALU_XOR;
                    6'b000010: OPSelect = ALU_SRL;
                    6'b000000: OPSelect = ALU_SLL;
                    6'b000011: OPSelect = ALU_SRA;
                    6'b101010: OPSelect = ALU_LTS;
                    6'b101011: OPSelect = ALU_LTU;
                    6'b010000: begin
                        OPSelect    = ALU_NOP;
                        ALU_LO_HI   = 2'b10;
                    end
                    6'b010010: begin
                        OPSelect    = ALU_NOP;
                        ALU_LO_HI   = 2'b01;
                    end
                    default: OPSelect = ALU_NOP;
                endcase
            end

            default: begin
                if (ALUOp == 6'b001001) begin
                    OPSelect = ALU_ADD;
                end
                else if (ALUOp == 6'b111110) begin
                    OPSelect = ALU_OIN;
                end
                else if (ALUOp == 6'b010000) begin
                    OPSelect = ALU_SUB;
                end
                else if (ALUOp == 6'b001100) begin
                    OPSelect = ALU_AND;
                end
                else if (ALUOp == 6'b001101) begin
                    OPSelect = ALU_ORR;
                end
                else if (ALUOp == 6'b001110) begin
                    OPSelect = ALU_XOR;
                end
                else if (ALUOp == 6'b001010) begin
                    OPSelect = ALU_LTS;
                end
                else if (ALUOp == 6'b001011) begin
                    OPSelect = ALU_LTU;
                end
                else if (ALUOp == 6'b000100) begin
                    OPSelect = ALU_BEQ;
                end
                else if (ALUOp == 6'b000101) begin
                    OPSelect = ALU_BNE;
                end
                else if (ALUOp == 6'b000110) begin
                    OPSelect = ALU_BLQ;
                end
                else if (ALUOp == 6'b000111) begin
                    OPSelect = ALU_BGT;
                end
                else if (ALUOp == 6'b000001) begin
                    if (IR20_16 == 5'b00001) begin
                        OPSelect = ALU_BGQ;
                    end
                    else if (IR20_16 == 5'b00000) begin
                        OPSelect = ALU_BLT;
                    end
                end
                else begin
                    OPSelect = ALU_NOP;
                end
            end
        endcase
    end

endmodule
