module  top_level_final #(parameter WIDTH = 32)(
	input logic clk, rst,
	input logic [1:0] buttons,
	input logic [9:0] switches,
	output logic [7:0] display0,
	output logic [7:0] display1
);
	logic [9:0] switch_signal;
	logic [31:0] output_signal;
	
	assign switch_signal = 1'b0 & switches[8:0];

	top_level #(.WIDTH(WIDTH)) top_level_component(
		.clk(clk),
		.rst(rst), 
		.buttons(buttons),
		.switches(switch_signal),
		.OUTPORT(output_signal)
	);
	
	Seven_Segment_Display display_0(
		.i0(output_signal[0]),
		.i1(output_signal[1]),
		.i2(output_signal[2]),
		.i3(output_signal[3]),
		.HEX0(display0)
	);
	
	Seven_Segment_Display display_1(
		.i0(output_signal[4]),
		.i1(output_signal[5]),
		.i2(output_signal[6]),
		.i3(output_signal[7]),
		.HEX0(display1)
	);
endmodule
