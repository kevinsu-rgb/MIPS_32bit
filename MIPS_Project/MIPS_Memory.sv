module MIPS_Memory #(parameter WIDTH = 32)(
	input logic clk,
	input logic rst,
	input logic Inport0En,
	input logic Inport1En,
	input logic [WIDTH-1:0] Extended_Switch_Data,
	input logic MemWrite,
	input logic MemRead,
	input logic [WIDTH-1:0] WrData,
	input logic [WIDTH-1:0] addr,
	output logic [WIDTH-1:0] RdData,
	output logic [WIDTH-1:0] Output_Port
);

// Submodule declarations
   logic OutportWrEn;
   logic WrEn;

   logic [WIDTH-1:0] InPort0_OUT;
   logic [WIDTH-1:0] InPort1_OUT;
   logic [WIDTH-1:0] Ram_OUT;
   logic [1:0] Output_Mux_Sel;
	localparam logic [WIDTH-1:0] zeros = '0;
	 
	register #(.WIDTH(WIDTH)) Inport0 (
        .in(Extended_Switch_Data),
        .reset(rst),
        .clk(clk),
        .enable(Inport0En),
        .out(InPort0_OUT)
   );
	
	register #(.WIDTH(WIDTH)) Inport1 (
        .in(Extended_Switch_Data),
        .reset(rst),
        .clk(clk),
        .enable(Inport1En),
        .out(InPort1_OUT)
   );
	
	register #(.WIDTH(WIDTH)) Outport (
        .in(WrData),
        .reset(rst),
        .clk(clk),
        .enable(OutportWrEn),
        .out(Output_Port)
   );
	
	mux4x1 #(.WIDTH(WIDTH)) mux4x1_0 (
		.a(InPort0_OUT),
		.b(InPort1_OUT),
		.c(Ram_OUT),
		.d(zeros),
		.sel(Output_Mux_Sel),
		.y(RdData)
	);
	
	RAM RAM_MODULE (
		.address(addr[9:2]),
		.clock(clk),
		.data(WrData),
		.wren(WrEn),
		.q(Ram_OUT)
	);
	
	always_comb begin
		OutportWrEn = 0;
		WrEn = 0;
		if(MemWrite == 1) begin
			if(addr == 32'h0000FFFC) begin
				OutportWrEn = 1;
				end
			else begin
				WrEn = 1;
				end
		end
	end
	
	always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            Output_Mux_Sel = 2'b11;
				end
        else if (MemRead) begin
				if(addr == 32'h0000FFF8) begin 
					Output_Mux_Sel = 2'b00;
					end
				else if(addr == 32'h0000FFFC) begin
					Output_Mux_Sel = 2'b01;
					end
				else begin
					Output_Mux_Sel = 2'b10;
					end
				end
			else begin
				Output_Mux_Sel = 2'b11;
				end
    end 

endmodule