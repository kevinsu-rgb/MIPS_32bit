module mux2x1 #(parameter WIDTH = 32)(
	input logic [WIDTH-1:0] a,b, //Inputs
	input logic sel, // Select line
	output logic [WIDTH-1:0] y // Output
);

	always_comb begin
		if (sel == 1'b0)
			y = a;
		else
			y = b; 
	end
endmodule