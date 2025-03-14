module tb_compare_bitwise_64;

reg signed [63:0] rs1;
reg signed [63:0] rs2;
wire signed [63:0] result;

compare_bitwise_64 dut (
    .rs1(rs1),
    .rs2(rs2),
    .result(result)
);

initial begin
    $monitor("At time %0t: rs1 = %d, rs2 = %d, result = %b", $time, rs1, rs2, result[0]);

    // Test case 1: rs1 = -15, rs2 = 16
    rs1 = -15; 
    rs2 = 16;
    #10;

    // Test case 2: rs1 = 32, rs2 = -16
    rs1 = 32;
    rs2 = -16;
    #10;

    // Test case 3: rs1 = -15, rs2 = -15
    rs1 = -15;
    rs2 = -15;
    #10;

    // Test case 4: rs1 = 0, rs2 = minimum signed 64-bit value (-2^63)
    rs1 = 0;
    rs2 = -64'h8000000000000000; // -2^63 (explicit hex representation)
    #10;

    $finish;
end

endmodule
