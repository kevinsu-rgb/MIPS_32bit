module  top_level #(parameter WIDTH = 32)(
	input logic clk, rst,
	input logic [1:0] buttons,
	input logic [9:0] switches,
	output logic [31:0] OUTPORT
);
	logic PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemToReg, IRWrite, JumpAndLink, IsSigned, ALUSrcA, RegWrite, RegDst;
	logic [5:0] ALUOp;
	logic [1:0] ALUSrcB, PCSource;
	logic [5:0] IR5_0;
	logic [5:0] IR31_26;
	
	Datapath #(.WIDTH(WIDTH)) DataPath_Module(
		.clk(clk),
		.rst(rst),
		.Inport0En(buttons[0]),
		.Inport1En(buttons[1]),
		.inport_in(switches),
		.PCWriteCond(PCWriteCond),
		.PCWrite(PCWrite),
		.IorD(IorD),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.MemToReg(MemToReg),
		.IRWrite(IRWrite),
		.JumpAndLink(JumpAndLink),
		.IsSigned(IsSigned),
		.PCSource(PCSource),
		.ALUOp(ALUOp),
		.ALUSrcB(ALUSrcB),
		.ALUSrcA(ALUSrcA),
		.RegWrite(RegWrite),
		.RegDst(RegDst),
		.IO_out(OUTPORT),
		.IR31_26(IR31_26),
		.IR5_0(IR5_0)
	);
	
		Controller #(.WIDTH(WIDTH)) Controller_module(
		.clk(clk),
		.rst(rst),
		.IR31_26(IR31_26),
		.IR5_0(IR5_0),
		.PCWriteCond(PCWriteCond),
		.PCWrite(PCWrite),
		.IorD(IorD),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.MemToReg(MemToReg),
		.IRWrite(IRWrite),
		.JumpAndLink(JumpAndLink),
		.IsSigned(IsSigned),
		.PCSource(PCSource),
		.ALUOp(ALUOp),
		.ALUSrcB(ALUSrcB),
		.ALUSrcA(ALUSrcA),
		.RegWrite(RegWrite),
		.RegDst(RegDst)
	);

endmodule