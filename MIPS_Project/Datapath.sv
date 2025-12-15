module Datapath #(
    parameter int WIDTH = 32
)(
    input  logic               clk,
    input  logic               rst,
    input  logic               Inport0En,
    input  logic               Inport1En,
    input  logic [9:0]         inport_in,
    input  logic               PCWriteCond,
    input  logic               PCWrite,
    input  logic               IorD,
    input  logic               MemRead,
    input  logic               MemWrite,
    input  logic               MemToReg,
    input  logic               IRWrite,
    input  logic               JumpAndLink,
    input  logic               IsSigned,
    input  logic [1:0]         PCSource,
    input  logic [5:0]         ALUOp,
    input  logic [1:0]         ALUSrcB,
    input  logic               ALUSrcA,
    input  logic               RegWrite,
    input  logic               RegDst,
    output logic [31:0]        IO_out,
    output logic [5:0]         IR31_26,
    output logic [5:0]         IR5_0
);
	// PC Register Signals:
	logic [31:0] PCInMuxOut;
	logic PC_EN;
	logic [31:0] PCOut;
	
	// Instruction Register Signals:
	logic [31:0] MemoryOutput;
	logic [31:0] instruction_register_output;
	// IR Output Signals
	logic [15:0] IR15_0;
	logic [25:0] IR25_0;
	logic [4:0] IR25_21;
	logic [4:0] IR20_16;
	logic [4:0] IR15_11;
	logic [4:0] IR10_6_sig;

	
	// PC Mux Signals
	logic [31:0] ALUOut;
	logic [31:0] PCMUXout;
	// Also needs PCOut
	
	// Memory Signals
	logic [31:0] zero_extend;
	logic [31:0] RegBOut;
	
	// Sign Extend Signals
	// Input of IR15_0
	logic [31:0] signextend_output;
	
	// IRWRMux Signals
	// Input of IR20_16
	// Input of IR15_11
	logic [4:0] IRWRMuxOutput;
	
	// MemoryRegisterWritedata Mux signals
	logic [31:0] LOHIMUXOutput;
	// MemoryOutput
	logic [31:0]MemoryRegisterWritedataoutput;
	
	// Registerfile Signals
	// IR25_21
	// IR20_16
	// IRWRMuxOutput
	logic [31:0] RegAOut;
	// RegBOut
	// MemoryRegisterWritedataoutput

	// Input1MUX Signals
	// PCOut
	// RegAout
	logic [31:0] Input1MUX_out;

	// Input2MUX Signals
	// RegBOut
	// Signextend_output
	logic [31:0] SL2Output;
	logic [31:0] Input2MUX_out;
	
	// ALU_Component Signals
	logic BranchTaken;
	logic [4:0] OP_SELECT;
	logic [WIDTH-1:0] Result;
	logic [WIDTH-1:0] Result_Hi;

	// ALUOUT_Reg Signals
	// Already instantiated
	
	// LO_Reg Signals
	logic [WIDTH-1:0] LOReg_output;

	// HI_Reg Signals
	logic [WIDTH-1:0] HIReg_output;

	// ALU_Controller_Component Signals
	logic HI_en;
	logic LO_en;
	logic [1:0] ALU_LO_HI;
	
	// PCSRCMUX Signals
	logic [31:0] concat_output;
		
	// Begin
	assign zero_extend = {22'b0, inport_in};
	assign PC_EN = (BranchTaken && PCWriteCond) || PCWrite;
	
	assign IR15_0 = instruction_register_output[15:0];
	assign IR25_0 = instruction_register_output[25:0];
	assign IR25_21 = instruction_register_output[25:21];
	assign IR20_16 = instruction_register_output[20:16];
	assign IR15_11 = instruction_register_output[15:11];
	assign IR10_6_sig = instruction_register_output[10:6];
	
	assign IR31_26 = instruction_register_output[31:26];
	assign IR5_0 = instruction_register_output[5:0];
	assign SL2Output = signextend_output << 2;
	assign concat_output[31:28] = PCOut[31:28];
	assign concat_output[27:0] = {IR25_0, 2'b00};

	register #(.WIDTH(WIDTH)) PC (
	  .in(PCInMuxOut),
	  .reset(rst),
	  .clk(clk),
	  .enable(PC_EN),
	  .out(PCOut)
   );
	
	register #(.WIDTH(WIDTH)) Instruction_Register (
	  .in(MemoryOutput),
	  .reset(rst),
	  .clk(clk),
	  .enable(IRWrite),
	  .out(instruction_register_output)
   );
	
	mux2x1 #(.WIDTH(WIDTH)) PC_MUX (
		.a(PCOut),
		.b(ALUOut),
		.sel(IorD),
		.y(PCMUXout)
	);
	
	MIPS_Memory #(.WIDTH(WIDTH)) MIPS_Memory (
		.clk(clk),
		.rst(rst),
		.Inport0En(Inport0En),
		.Inport1En(Inport1En),
		.Extended_Switch_Data(zero_extend),
		.MemWrite(MemWrite),
		.MemRead(MemRead),
		.WrData(RegBOut),
		.addr(PCMUXout),
		.RdData(MemoryOutput),
		.Output_Port(IO_out)
	);
	
	Sign_Extender #(.WIDTH(16)) Sign_Extender (
		.IsSigned(IsSigned),
		.input_data(IR15_0),
		.output_data(signextend_output)
	);
	
	
	mux2x1 #(.WIDTH(5)) IRWRMux (
		.a(IR20_16),
		.b(IR15_11),
		.sel(RegDst),
		.y(IRWRMuxOutput)
	);
	
	mux2x1 #(.WIDTH(WIDTH)) MemoryRegisterWritedata (
		.a(LOHIMUXOutput),
		.b(MemoryOutput),
		.sel(MemToReg),
		.y(MemoryRegisterWritedataoutput)
	);
	
	registerfile Register_File (
		.clk(clk),
		.rst(rst),
		.rd_addr0(IR25_21),
		.rd_addr1(IR20_16),
		.wr_addr(IRWRMuxOutput),
		.wr_en(RegWrite),
		.wr_data(MemoryRegisterWritedataoutput),
		.rd_data0(RegAOut),
		.rd_data1(RegBOut),
		.JumpAndLink(JumpAndLink)
	);
	
	mux2x1 #(.WIDTH(WIDTH)) Input1MUX (
		.a(PCOut),
		.b(RegAOut),
		.sel(ALUSrcA),
		.y(Input1MUX_out)
	);
	
	mux4x1 #(.WIDTH(WIDTH)) Input2MUX (
		.a(RegBOut),
		.b(32'h00000004),
		.c(signextend_output),
		.d(SL2Output),
		.sel(ALUSrcB),
		.y(Input2MUX_out)
	);
	
	ALU #(.WIDTH(WIDTH)) ALU_Component (
		.input1(Input1MUX_out),
		.input2(Input2MUX_out),
		.IR(IR10_6_sig),
		.OP_SELECT(OP_SELECT),
		.Result(Result),
		.Result_Hi(Result_Hi),
		.Branch_Taken(BranchTaken)
	);
	
	reg_noEN #(.WIDTH(WIDTH)) ALUOUT_Reg (
		.in(Result),
		.reset(rst),
		.clk(clk),
		.out(ALUOut)
	);
	
	register #(.WIDTH(WIDTH)) LO_Reg (
	  .in(Result),
	  .reset(rst),
	  .clk(clk),
	  .enable(LO_en),
	  .out(LOReg_output)
   );
	
	register #(.WIDTH(WIDTH)) HI_Reg (
	  .in(Result_Hi),
	  .reset(rst),
	  .clk(clk),
	  .enable(HI_en),
	  .out(HIReg_output)
   );
	
	
	ALU_controller ALU_Controller_Component (
		.ALUOp(ALUOp),
		.IR5_0(IR5_0),
		.IR20_16(IR20_16),
		.HI_en(HI_en),
		.LO_en(LO_en),
		.ALU_LO_HI(ALU_LO_HI),
		.OPSelect(OP_SELECT)
	);
	
		
	mux4x1 #(.WIDTH(WIDTH)) PCSRCMUX (
		.a(Result),
		.b(ALUOut),
		.c(concat_output),
		.d(32'h00000000),
		.sel(PCSource),
		.y(PCInMuxOut)
	);
	
	mux4x1 #(.WIDTH(WIDTH)) OutputMux (
		.a(ALUOut),
		.b(LOReg_output),
		.c(HIReg_output),
		.d(32'h00000000),
		.sel(ALU_LO_HI),
		.y(LOHIMUXOutput)
	);
	
	
endmodule
