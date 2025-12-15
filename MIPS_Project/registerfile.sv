module registerfile (
	input logic clk,
	input logic rst,
	input logic [4:0] rd_addr0,
	input logic [4:0] rd_addr1,
	input logic [4:0] wr_addr,
	input logic wr_en,
	input logic [31:0] wr_data,
	output logic [31:0] rd_data0,
	output logic [31:0] rd_data1,
	input logic JumpAndLink
);
	logic [31:0] regs [0:31];
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			for (int i = 0; i <= 31; i++) begin
				regs[i] = '0;
			end
		end
		else if(clk) begin
			if(wr_en) begin
				regs[wr_addr] = wr_data;
			end
			if(JumpAndLink) begin
				regs[31] = wr_data;
			end
			regs[0] = '0;
		end
	end
	// Combinational read
   assign rd_data0 = regs[rd_addr0];
   assign rd_data1 = regs[rd_addr1];
		
endmodule