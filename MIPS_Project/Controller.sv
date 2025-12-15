module Controller #(
    parameter int WIDTH = 32)
(
	input logic clk, 
	input logic rst,
	input logic [5:0] IR31_26,
	input logic [5:0] IR5_0,
	output logic PCWriteCond, 
	output logic PCWrite, 
	output logic IorD,
	output logic MemRead,
	output logic MemWrite,
	output logic MemToReg,
	output logic IRWrite,
	output logic JumpAndLink,
	output logic IsSigned,
	output logic [1:0] PCSource,
	output logic [5:0] ALUOp,
	output logic [1:0] ALUSrcB,
	output logic ALUSrcA,
	output logic RegWrite,
	output logic RegDst
);

	localparam logic [4:0] ALU_ADD = 5'b00000;
	typedef enum logic [4:0] {
    IF_C1,
    IF_C2,
    IDFR,
    R_C1,
    R_C2,
    I_C1,
    I_C2,
    LOAD_C1,
    LOAD_C2,
    LOAD_C3,
    STORE_C1,
    STORE_C2,
    JUMP_C1,
    JUMPTOAC1,
    JUMPTOAC2,
    JUMPANDLINKC1,
    JUMPANDLINKC2,
    BranchC1,
    BranchC2
	 } state_type;

	state_type state, next_state;
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			state = IF_C1;
		end
		else if (clk) begin
			state = next_state;
		end
	end
	
	always_comb begin
		PCWriteCond = 1'b0;
		PCWrite     = 1'b0;
		IorD        = 1'b0;
		MemRead	  	= 1'b1;
		MemWrite    = 1'b0;
		MemToReg    = 1'b0;
		IRWrite     = 1'b0;
		JumpAndLink = 1'b0;
		IsSigned    = 1'b0;
		PCSource    = 2'b00;
		ALUOp       = 6'b111111;
		ALUSrcB     = 2'b00;
		ALUSrcA     = 1'b0;
		RegWrite    = 1'b0;
		RegDst      = 1'b0;
		next_state = state;
		case(state)
			IF_C1: begin
				IorD = 1'b0;
				MemRead <= 1'b1;
				next_state = IF_C2;
			end
			IF_C2: begin
				IRWrite = 1'b1;
				ALUSrcA <= 1'b0;
				MemRead <= 1'b1; 
				ALUSrcB <= 2'b01;
				ALUOp <= 6'b001001;
				PCSource <= 2'b00;
				PCWrite <= 1'b1;
				next_state <= IDFR;
			end
			IDFR: begin
				if (IR31_26 == 6'b000000 && IR5_0 == 6'b001000) begin // Jump Register
					next_state = JUMP_C1;
				end
				else if (IR31_26 == 6'b000000 && IR5_0 == 6'b010000) begin // Mov hi
					next_state = R_C2;
				end
				else if (IR31_26 == 6'b000000 && IR5_0 == 6'b010010) begin // Mov low
					next_state = R_C2;
				end
				else if (IR31_26 == 6'b001001) begin // Add immediate
					next_state = I_C1;
				end
				else if (IR31_26 == 6'b010000) begin // Sub immediate
					next_state = I_C1;
				end
				else if (IR31_26 == 6'b001100) begin // AND immediate
					next_state = I_C1;
				end
				else if (IR31_26 == 6'b001101) begin // OR immediate
					next_state = I_C1;
				end
				else if (IR31_26 == 6'b001110) begin // XOR immediate
					next_state = I_C1;
				end
				else if (IR31_26 == 6'b001010) begin // Set on less than immediate
					next_state = I_C1;
				end
				else if (IR31_26 == 6'b001011) begin // Set on less than immediate Unsigned
					next_state = I_C1;
				end
				else if (IR31_26 == 6'b100011) begin // Load word
					next_state = LOAD_C1;
				end
				else if (IR31_26 == 6'b101011) begin // Store word
					next_state = STORE_C1;
				end
				else if (IR31_26 == 6'b000100) begin // Beq
					next_state = BranchC1;
				end
				else if (IR31_26 == 6'b000101) begin // BNeq
					next_state = BranchC1;
				end
				else if (IR31_26 == 6'b000110) begin // Branch on less than or equal to zero
					next_state = BranchC1;
				end
				else if (IR31_26 == 6'b000111) begin // Branch on greater than zero
					next_state = BranchC1;
				end
				else if (IR31_26 == 6'b000001) begin // Branch on less than zero or Branch on Greater than or equal to zero
					next_state = BranchC1;
				end
				else if (IR31_26 == 6'b000010) begin // Jump to address
					next_state = JUMPTOAC1;
				end
				else if (IR31_26 == 6'b000011) begin // Jump and link
					ALUOp = 6'b111110; // Add
					next_state = JUMPANDLINKC1;
				end
				else if (IR31_26 == 6'b000000) begin // R-type
					next_state = R_C1;
				end
			end
			R_C1: begin
				ALUSrcA = 1'b1;
				ALUSrcB = 2'b00;
				ALUOp = IR31_26;
				next_state = R_C2;
			end
			R_C2: begin
				MemToReg = 1'b0;
				RegDst = 1'b1;
				RegWrite = 1'b1;
				if (IR5_0 == 6'b010000) begin // mfhi and mflo need their alu op in this cycle because they store to register file where they operate.
					ALUOp = 6'b000000;
				end
				else if (IR5_0 == 6'b010010) begin
					ALUOp = 6'b000000;
				end
				next_state = IF_C1;
			end
			I_C1: begin
				ALUSrcA = 1'b1;
				ALUSrcB = 2'b10;
				ALUOp = IR31_26;
				next_state = I_C2;
			end
			I_C2: begin
				MemToReg = 1'b0;
				RegDst = 1'b0;
				RegWrite = 1'b1;
				next_state = IF_C1;
			end
			LOAD_C1: begin
				IsSigned = 1'b0;
				ALUSrcA = 1'b1;
				ALUSrcB = 2'b10;
				ALUOp = 6'b001001;
				next_state = LOAD_C2;
			end
			LOAD_C2: begin
				IorD = 1'b1;
				ALUSrcA = 1'b1;
				ALUSrcB = 2'b10;
				ALUOp = 6'b001001;
				next_state = LOAD_C3;
			end
			LOAD_C3: begin
				IorD = 1'b1;
				ALUSrcA = 1'b1;
				ALUSrcB = 2'b10;
				MemRead = 1'b1;
				RegWrite = 1'b1;
				MemToReg = 1'b1;
				ALUOp = 6'b001001;
				next_state = IF_C1;
			end
			STORE_C1: begin
				IsSigned = 1'b0;
				ALUSrcA = 1'b1;
				ALUSrcB = 2'b10;
				ALUOp = 6'b001001;
				next_state = STORE_C2;
			end
			STORE_C2: begin
				ALUSrcA = 1'b1;
				ALUSrcB = 2'b10;
				IorD = 1'b1;
				MemWrite = 1'b1;
				next_state = IF_C1;
			end
			BranchC1: begin
				IsSigned = 1'b1;
				ALUSrcB = 2'b11;
				ALUSrcA = 1'b0;
				ALUOp = 6'b001001;	
				next_state = BranchC2;
			end
			BranchC2: begin
				ALUSrcA = 1'b1;
				ALUSrcB = 2'b00;
				ALUOp = IR31_26;
				PCWriteCond = 1'b1;
				PCSource = 2'b01;
				next_state = IF_C1;
			end
			JUMP_C1: begin
				PCSource = 2'b00;
				PCWrite = 1'b1;
				ALUSrcA = 1'b1;
				ALUOp = 6'b111110;
				next_state = IF_C1;
			end
			JUMPTOAC1: begin
				PCSource = 2'b10;
				PCWrite = 1'b1;
				ALUOp = 6'b111111;
				next_state = IF_C1;
			end
			JUMPANDLINKC1: begin
				ALUOp = 6'b111110; //Add
				PCWrite = 1'b1;
				PCSource = 2'b10;
				ALUSrcB = 2'b01;
				JumpAndLink = 1'b1;
				next_state = IF_C1;
			end
			default: begin;
			end
		endcase
	end

endmodule	
