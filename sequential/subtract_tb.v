`timescale 1ns / 1ps

module testbench;
    reg signed [63:0] a;
    reg signed [63:0] b;
    wire signed [63:0] difference;
    wire borrow;
    wire overflow;

    // Instantiate the bit64_subtractor module
    bit64_subtractor uut (
        .a(a),
        .b(b),
        .difference(difference),
        .borrow(borrow),
        .overflow(overflow)
    );

    initial begin
        // Test 1: A = 7, B = 2
        a = 64'b0000000000000000000000000000000000000000000000000000000000000111;  // Decimal 7
        b = 64'b0000000000000000000000000000000000000000000000000000000000000010;  // Decimal 2
        #10;
        $display("a =%b (%d), b =%b (%d), difference =%b (%d), borrow = %b, overflow = %b", a, a, b, b, difference, difference, borrow, overflow);

        // Test 2: A = 3, B = -4
        a = 64'b0000000000000000000000000000000000000000000000000000000000000011;  // Decimal 3
        b = 64'b1111111111111111111111111111111111111111111111111111111111111100;  // Decimal -4
        #10;
        $display("a =%b (%d), b =%b (%d), difference =%b (%d), borrow = %b, overflow = %b", a, a, b, b, difference, difference, borrow, overflow);

        // Test 3: A = -2, B = 5
        a = 64'b1111111111111111111111111111111111111111111111111111111111111110;  // Decimal -2
        b = 64'b0000000000000000000000000000000000000000000000000000000000000101;  // Decimal 5
        #10;
        $display("a =%b (%d), b =%b (%d), difference =%b (%d), borrow = %b, overflow = %b", a, a, b, b, difference, difference, borrow, overflow);

        // Test 4: A = -8, B = 1
        a = 64'b1111111111111111111111111111111111111111111111111111111111111000;  // Decimal -8
        b = 64'b0000000000000000000000000000000000000000000000000000000000000001;  // Decimal 1
        #10;
        $display("a =%b (%d), b =%b (%d), difference =%b (%d), borrow = %b, overflow = %b", a, a, b, b, difference, difference, borrow, overflow);

        $finish;
    end
endmodule
