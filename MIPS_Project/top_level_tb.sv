module top_level_tb;
	localparam int WIDTH = 32;
	time CLK_PERIOD = 10ns; 
	
	logic clk;
	logic rst;
	logic [1:0] buttons;
	logic [9:0] switches;
	logic [WIDTH-1:0] Output_Port;
	
	top_level #(.WIDTH(WIDTH)) UUT (
		.clk(clk),
		.rst(rst),
		.buttons(buttons),
		.switches(switches),
		.OUTPORT(Output_Port)
	);
	initial clk = 0;
	 // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;
	
 initial begin
        buttons = 2'b01;
		  switches = 10'b0111111111;
        // Reset
        rst <= 1;
		  @(posedge clk);
        rst <= 0;
		  @(posedge clk);
		  for (int i = 0; i <= 500; i++) begin
				 @(posedge clk);
		  end
		  rst <= 1;
        $display("All tests completed.");
        $finish;
    end
  
endmodule