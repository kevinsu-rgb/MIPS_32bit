module ALU #(parameter WIDTH = 32)(
	input logic [WIDTH-1:0] input1,
	input logic [WIDTH-1:0] input2,
	input logic [4:0] 			 IR,
	input logic [4:0] 	OP_SELECT,
	output logic [WIDTH-1:0] Result,
	output logic [WIDTH-1:0] Result_Hi,
	output logic Branch_Taken
);

	always_comb begin
		Result       = '0;
		Result_Hi    = '0;
		Branch_Taken = 1'b0;
		
		if(OP_SELECT == 5'b00000) begin // Unsigned ADD
			Result = $unsigned(input1) + $unsigned(input2);
			Result_Hi = '0;
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b00001) begin // Unsigned Subtract
			Result = $unsigned(input1) - $unsigned(input2);
			Result_Hi = '0;
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b00010) begin // Signed Multiply
			{ Result_Hi, Result } = $signed(input1) * $signed(input2);
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b00011) begin // Unsigned Multiply
			{ Result_Hi, Result } = $unsigned(input1) * $unsigned(input2);
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b00100) begin // AND
			Result = (input1) & (input2);
			Result_Hi = '0;
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b00101) begin // OR
			Result = (input1) | (input2);
			Result_Hi = '0;
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b00110) begin // xor
			Result = (input1) ^ (input2);
			Result_Hi = '0;
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b00111) begin // Shift Right
			Result = (input2) >> (IR);
			Result_Hi = '0;
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b01000) begin // Shift Left
			Result = (input2) << (IR);
			Result_Hi = '0;
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b01001) begin // Shift Right Arithmetic
			Result = $signed(input2) >>> (IR);
			if(input2[WIDTH-1] == 1'b1) begin
				Result_Hi = '1;
				end
			else begin
				Result_Hi = '0;
				end
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b01010) begin // Set on less than signed
			if ($signed(input1) < $signed(input2)) begin
				Result = 1;
				Result_Hi = '0;
				Branch_Taken = 0;
				end
			else begin
				Result = '0;
				Result_Hi = '0;
				Branch_Taken = 0;
				end
			end
		else if(OP_SELECT == 5'b01011) begin // Set on less than unsigned using different syntax
			Result = ($unsigned(input1) < $unsigned(input2)) ? 1 : 0;
			Result_Hi = '0;
			Branch_Taken = 0;
			end
		else if(OP_SELECT == 5'b01100) begin // Branch on equal
			if ($signed(input1) == $signed(input2)) begin
				Result = 0;
				Result_Hi = '0;
				Branch_Taken = 1;
				end
			else begin
				Result = '0;
				Result_Hi = '0;
				Branch_Taken = 0;
				end
			end
		else if(OP_SELECT == 5'b01101) begin // Branch on not equal
			if ($signed(input1) == $signed(input2)) begin
				Result = 0;
				Result_Hi = '0;
				Branch_Taken = 0;
				end
			else begin
				Result = '0;
				Result_Hi = '0;
				Branch_Taken = 1;
				end
			end
		else if(OP_SELECT == 5'b01110) begin // Branch if less than or equal to 0
			if ($signed(input1) <= 0) begin
				Result = 0;
				Result_Hi = '0;
				Branch_Taken = 1;
				end
			else begin
				Result = '0;
				Result_Hi = '0;
				Branch_Taken = 0;
				end
			end
		else if(OP_SELECT == 5'b01111) begin // Branch if greater than 0
			if ($signed(input1) > 0) begin
				Result = 0;
				Result_Hi = '0;
				Branch_Taken = 1;
				end
			else begin
				Result = '0;
				Result_Hi = '0;
				Branch_Taken = 0;
				end
			end
		else if(OP_SELECT == 5'b10000) begin // Branch if less than 0
			if ($signed(input1) < 0) begin
				Result = 0;
				Result_Hi = '0;
				Branch_Taken = 1;
				end
			else begin
				Result = '0;
				Result_Hi = '0;
				Branch_Taken = 0;
				end
			end
		else if(OP_SELECT == 5'b10001) begin // Branch if greater than or equal to 0
			if ($signed(input1) >= 0) begin
				Result = 0;
				Result_Hi = '0;
				Branch_Taken = 1;
				end
			else begin
				Result = '0;
				Result_Hi = '0;
				Branch_Taken = 0;
				end
			end
		else if(OP_SELECT == 5'b10010) begin // Set output to input1
			Result = input1;
			Result_Hi = '0;
			Branch_Taken = 0;
			end
		else begin
			Result = '0;
			Result_Hi = '0;
			Branch_Taken = 0;
			end
	end


endmodule 