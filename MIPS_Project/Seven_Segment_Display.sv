module Seven_Segment_Display (
    input  logic i0,
    input  logic i1,
    input  logic i2,
    input  logic i3,
    output logic [7:0] HEX0
);

    logic [3:0] num;

    always_comb begin
        num = {i3, i2, i1, i0};

        case (num)
            4'b0000: HEX0 = 8'b01000000; // 0
            4'b0001: HEX0 = 8'b01111001; // 1
            4'b0010: HEX0 = 8'b00100100; // 2
            4'b0011: HEX0 = 8'b00110000; // 3
            4'b0100: HEX0 = 8'b00011001; // 4
            4'b0101: HEX0 = 8'b00010010; // 5
            4'b0110: HEX0 = 8'b00000010; // 6
            4'b0111: HEX0 = 8'b01111000; // 7
            4'b1000: HEX0 = 8'b00000000; // 8
            4'b1001: HEX0 = 8'b00011000; // 9
            4'b1010: HEX0 = 8'b00001000; // A
            4'b1011: HEX0 = 8'b00000011; // B
            4'b1100: HEX0 = 8'b01000110; // C
            4'b1101: HEX0 = 8'b00100001; // D
            4'b1110: HEX0 = 8'b00000110; // E
            4'b1111: HEX0 = 8'b00001110; // F
            default: HEX0 = 8'b01111111; // OFF
        endcase
    end

endmodule
