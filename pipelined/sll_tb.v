module tb_shift_example;
    reg [63:0] test_input;
    reg [5:0] shift_amount;
    wire [63:0] shifted_output;

    // Instantiate the DUT
    shift_sll DUT (
        .a(test_input),
        .n(shift_amount),
        .result(shifted_output)
    );

    initial begin
        // Test Case 1: Shift by 1 bit
        test_input = 64'b1100101010101010101010101010101010101010101010101010101010101010;
        shift_amount = 6'd1;
        #5;
        $display("Input: %b", test_input);
        $display("Shifted by %d bits: %b", shift_amount, shifted_output);

        // Test Case 2: Shift by 4 bits
        test_input = 64'b0000000000000000000000000000000000000000000000000000000000001111;
        shift_amount = 6'd4;
        #5;
        $display("Input: %b", test_input);
        $display("Shifted by %d bits: %b", shift_amount, shifted_output);

     
        $finish;
    end
endmodule
