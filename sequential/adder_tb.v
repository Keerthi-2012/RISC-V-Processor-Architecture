`timescale 1ns / 1ps

module testbench;
    reg signed [63:0] a, b;
    wire signed [63:0] sum;
    wire carry, overflow;

    // Instantiate the 64-bit adder
    bit64_adder uut (
        .a(a),
        .b(b),
        .sum(sum),
        .carry(carry),
        .overflow(overflow)
    );

    // Dump signals for GTKWave
    initial begin
        $dumpfile("waveform.vcd");  // VCD file for GTKWave
        $dumpvars(0, testbench);    // Dump all variables in this module
    end

    // Apply test vectors
    initial begin
        // Test Case 1: 0 + 0
        a = 64'b0000000000000000000000000000000000000000000000000000000000000000;
        b = 64'b0000000000000000000000000000000000000000000000000000000000000000;
        #10;
        $display("Test 1: a=%b (%d), b=%b (%d), sum=%b (%d), carry=%b, overflow=%b", 
                 a, a, b, b, sum, sum, carry, overflow);

        // Test Case 2: 1 + 1
        a = 64'b0000000000000000000000000000000000000000000000000000000000000111;
        b = 64'b0000000000000000000000000000000000000000000000000000000000000001;
        #10;
        $display("Test 2: a=%b (%d), b=%b (%d), sum=%b (%d), carry=%b, overflow=%b", 
                 a, a, b, b, sum, sum, carry, overflow);

        // Test Case 3: Max negative values (-1 + -1)
        a = 64'b1111111111111111111111111111111111111111111111111111111111111001; // -1
        b = 64'b1111111111111111111111111111111111111111111111111111111111111101; // -1
        #10;
        $display("Test 3: a=%b (%d), b=%b (%d), sum=%b (%d), carry=%b, overflow=%b", 
                 a, a, b, b, sum, sum, carry, overflow);

        // Test Case 4: Mixed large values
        a = 64'b0001001100110100010101100111100001001010110010111100111101110111;
        b = 64'b1111111011101100101100100000100110000111010101011101001100000001;
        #10;
        $display("Test 4: a=%b (%d), b=%b (%d), sum=%b (%d), carry=%b, overflow=%b", 
                 a, a, b, b, sum, sum, carry, overflow);

        // Test Case 5: One operand is zero
        a = 64'b0000000000000000000000000000000000000000000000000000000000000000;
        b = 64'b0001001100110100010101100111100001001010110010111100111101110111;
        #10;
        $display("Test 5: a=%b (%d), b=%b (%d), sum=%b (%d), carry=%b, overflow=%b", 
                 a, a, b, b, sum, sum, carry, overflow);

        // Test Case 6: Overflow case (maximum positive + 1)
        a = 64'b0111111111111111111111111111111111111111111111111111111111111111; // Max positive
        b = 64'b0000000000000000000000000000000000000000000000000000000000000001; // 1
        #10;
        $display("Test 6: a=%b (%d), b=%b (%d), sum=%b (%d), carry=%b, overflow=%b", 
                 a, a, b, b, sum, sum, carry, overflow);

        // Test Case 7: Carry-out case (maximum positive + maximum positive)
        a = 64'b0111111111111111111111111111111111111111111111111111111111111111; // Max positive
        b = 64'b0111111111111111111111111111111111111111111111111111111111111111; // Max positive
        #10;
        $display("Test 7: a=%b (%d), b=%b (%d), sum=%b (%d), carry=%b, overflow=%b", 
                 a, a, b, b, sum, sum, carry, overflow);

        $finish;
    end

endmodule