`timescale 1ps / 1ps

module MIPS_Memory_tb;

  localparam int WIDTH = 32;
  time CLK_PERIOD = 10ns;  
  
  // DUT signals
    logic clk = 0;
    logic rst = 0;
    logic Inport0En = 0;
    logic Inport1En = 0;
    logic [WIDTH-1:0] Extended_Switch_Data = '0;
    logic MemWrite = 0;
    logic MemRead = 0;
    logic [WIDTH-1:0] WrData = '0;
    logic [WIDTH-1:0] addr = '0;
    logic [WIDTH-1:0] RdData;
    logic [WIDTH-1:0] Output_Port;
  
  MIPS_Memory #(.WIDTH(WIDTH)) UUT (
	.clk(clk),
	.rst(rst),
	.Inport0En(Inport0En),
	.Inport1En(Inport1En),
	.Extended_Switch_Data(Extended_Switch_Data),
	.MemWrite(MemWrite),
	.MemRead(MemRead),
	.WrData(WrData),
	.addr(addr),
	.RdData(RdData),
	.Output_Port(Output_Port)
  );
  
  // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;
	  // Stimulus process
    initial begin
        // Reset
        rst <= 1;
        #(CLK_PERIOD * 2);
        rst <= 0;
        #(CLK_PERIOD);

        // Test Case 1
        $display("Test Case 1: Write 0x0A0A0A0A to byte address 0x00000000");
        addr <= 32'h00000000;
        WrData <= 32'h0A0A0A0A;
        MemWrite <= 1;
        #(CLK_PERIOD);
        MemWrite <= 0;
        #(CLK_PERIOD);

        // Test Case 2
        $display("Test Case 2: Write 0xF0F0F0F0 to byte address 0x00000004");
        addr <= 32'h00000004;
        WrData <= 32'hF0F0F0F0;
        MemWrite <= 1;
        #(CLK_PERIOD);
        MemWrite <= 0;
        #(CLK_PERIOD);

        // Test Case 3
        $display("Test Case 3: Read from byte address 0x00000000");
        addr <= 32'h00000000;
        MemRead <= 1;
        #(CLK_PERIOD);
        MemRead <= 0;
        #(CLK_PERIOD);

        // Test Case 4
        $display("Test Case 4: Read from byte address 0x00000001");
        addr <= 32'h00000001;
        MemRead <= 1;
        #(CLK_PERIOD);
        MemRead <= 0;
        #(CLK_PERIOD);

        // Test Case 5
        $display("Test Case 5: Read from byte address 0x00000004");
        addr <= 32'h00000004;
        MemRead <= 1;
        #(CLK_PERIOD);
        MemRead <= 0;
        #(CLK_PERIOD);

        // Test Case 6
        $display("Test Case 6: Read from byte address 0x00000005");
        addr <= 32'h00000005;
        MemRead <= 1;
        #(CLK_PERIOD);
        MemRead <= 0;
        #(CLK_PERIOD);

        // Test Case 7
        $display("Test Case 7: Write 0x00001111 to the outport");
        addr <= 32'h0000FFFC;
        WrData <= 32'h00001111;
        MemWrite <= 1;
        #(CLK_PERIOD);
        MemWrite <= 0;
        #(CLK_PERIOD * 2);

        // Test Case 8
        $display("Test Case 8: Load 0x00010000 into inport 0");
        Extended_Switch_Data <= 32'h00010000;
        Inport0En <= 1;
        #(CLK_PERIOD);
        Inport0En <= 0;
        #(CLK_PERIOD);

        // Test Case 9
        $display("Test Case 9: Load 0x00000001 into inport 1");
        Extended_Switch_Data <= 32'h00000001;
        Inport1En <= 1;
        #(CLK_PERIOD);
        Inport1En <= 0;
        #(CLK_PERIOD);

        // Test Case 10
        $display("Test Case 10: Read from inport 0");
        addr <= 32'h0000FFF8;
        MemRead <= 1;
        #(CLK_PERIOD * 2);
        MemRead <= 0;
        #(CLK_PERIOD);

        // Test Case 11
        $display("Test Case 11: Read from inport 1");
        addr <= 32'h0000FFFC;
        MemRead <= 1;
        #(CLK_PERIOD * 2);
        MemRead <= 0;
        #(CLK_PERIOD);

        $display("All tests completed.");
        $finish;
    end
  
endmodule