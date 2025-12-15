module mux4x1 #(parameter WIDTH = 32)(
	input logic [WIDTH-1:0] a,b,c,d, //Inputs
	input logic [1:0] sel, // Select line
	output logic [WIDTH-1:0] y // Output
);

	 always_comb begin
        case (sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            2'b11: y = d;
            // default: y = '0; // Optional default
        endcase
    end
	 
endmodule