module register #(parameter WIDTH = 32)(
	input logic [WIDTH-1:0] in, //Inputs
	input logic reset, // Reset
	input logic clk, // Clock
	input logic enable, // enable
	output logic [WIDTH-1:0] out // Output
);

 always_ff @(posedge clk or posedge reset) begin
        if (reset)
            out = '0;
        else if (enable)
            out = in;
    end 
	 
endmodule