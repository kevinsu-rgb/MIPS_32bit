`timescale 10ns/1ps

module ALU_tb;

  localparam int WIDTH = 32;

  logic [WIDTH-1:0] input1, input2;
  logic [4:0]       IR, OP_SELECT;
  logic [WIDTH-1:0] Result, Result_Hi;
  logic             Branch_Taken;

  ALU #(.WIDTH(WIDTH)) UUT (
    .input1(input1),
    .input2(input2),
    .IR(IR),
    .OP_SELECT(OP_SELECT),
    .Result(Result),
    .Result_Hi(Result_Hi),
    .Branch_Taken(Branch_Taken)
  );

  initial begin
    input1 = '0;
    input2 = '0;
    IR     = '0;
    OP_SELECT = '0;

    // 1. ADD: 10 + 15
    input1 = $signed(10);
    input2 = $signed(15);
    OP_SELECT = 5'b00000;
    #10;
    assert(Result == 32'd25) else $fatal("ADD failed");

    // 2. SUB: 25 - 10
    input1 = $signed(25);
    input2 = $signed(10);
    OP_SELECT = 5'b00001;
    #10;
    assert(Result == 32'd15) else $fatal("SUB failed");

    // 3. Signed MUL: 10 * -4 = -40
    input1 = $signed(10);
    input2 = $signed(-4);
    OP_SELECT = 5'b00010;
    #10;
    assert($signed(Result) == -40) else $fatal("Signed MUL failed");

    // 4. Unsigned MUL: 65536 * 131072 = 0x0000000200000000

    input1 = 32'd65536;
    input2 = 32'd131072;
    OP_SELECT = 5'b00011;
    #10;
    assert(Result == 32'h00000000) else $fatal("Unsigned MUL lower bits failed");
    assert(Result_Hi == 32'h00000002) else $fatal("Unsigned MUL upper bits failed");

    // 5. AND
    input1 = 32'h0000FFFF;
    input2 = 32'hFFFF1234;
    OP_SELECT = 5'b00100;
    #10;
    assert(Result == 32'h00001234) else $fatal("AND failed");

    // 6. SRL: 0x0000000F >> 4 = 0x1
    input2 = 32'h0000000F;
    IR = 5'd4;
    OP_SELECT = 5'b00111;
    #10;
    assert(Result == 32'h00000000) else $fatal("SRL failed");

    // 7. SRA: 0xF0000008 >>> 1 = 0xF8000004
    input2 = 32'hF0000008;
    IR = 5'd1;
    OP_SELECT = 5'b01001;
    #10;
    assert(Result == 32'hF8000004) else $fatal("SRA (neg) failed");
	 assert(Result_Hi == 32'hFFFFFFFF) else $fatal("Incorrect Hi Result");

    // 8. SRA: 0x00000008 >>> 1 = 0x00000004
    input2 = 32'h00000008;
    IR = 5'd1;
    OP_SELECT = 5'b01001;
    #10;
    assert(Result == 32'h00000004) else $fatal("SRA (pos) failed");
	 assert(Result_Hi == 32'h00000000) else $fatal("Incorrect Hi Result");


    // 9. SLT: 10 < 15 = 1
    input1 = $signed(10);
    input2 = $signed(15);
    OP_SELECT = 5'b01010;
    #10;
    assert(Result == 32'd1) else $fatal("SLT true failed");

    // 10. SLT: 15 < 10 = 0
    input1 = $signed(15);
    input2 = $signed(10);
    OP_SELECT = 5'b01010;
    #10;
    assert(Result == 32'd0) else $fatal("SLT false failed");

    // 11. BLEZ: 5 ≤ 0 => false => Branch_Taken = 0
    input1 = $signed(5);
    OP_SELECT = 5'b01110;
    #10;
    assert(Branch_Taken == 0) else $fatal("BLEZ failed");

    // 12. BGTZ: 5 > 0 => true => Branch_Taken = 1
    input1 = $signed(5);
    OP_SELECT = 5'b01111;
    #10;
    assert(Branch_Taken == 1) else $fatal("BGTZ failed");

    $display("✅ All ALU tests passed.");
    $finish;
  end

endmodule
