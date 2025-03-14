`timescale 1ns / 1ps

module ALU_tb;

    // Inputs
    reg [6:0] funct7;
    reg [2:0] funct3;
    reg [6:0] opcode;
    reg signed [63:0] A;
    reg signed [63:0] B;
    reg [11:0] addr;
    
    // Outputs
    wire signed [63:0] result;
    wire carry_alu;
    wire overflow_alu;
    wire zero_flag;
    
    // Instantiate the Unit Under Test (UUT)
    ALU uut (
        .funct7(funct7),
        .funct3(funct3),
        .opcode(opcode),
        .A(A),
        .B(B),
        .addr(addr),
        .result(result),
        .carry_alu(carry_alu),
        .overflow_alu(overflow_alu),
        .zero_flag(zero_flag)
    );
    
    // For monitoring
    integer test_case = 0;
    
    initial begin
        // Initialize inputs
        funct7 = 7'b0000000;
        funct3 = 3'b000;
        opcode = 7'b0000000;
        A = 64'd0;
        B = 64'd0;
        addr = 12'd0;
        
        // Wait for global reset
        #10;
        
        // Set BEQ instruction specifics
        // BEQ uses opcode=1100011, funct3=000
        opcode = 7'b1100011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        
        // Test Case 1: Equal values (should branch - zero_flag should be 1)
        test_case = 1;
        A = 64'd100;
        B = 64'd100;
        addr = 12'h008; // Branch offset
        #10;
        $display("Test Case %0d: BEQ with Equal Values", test_case);
        $display("A = %0d, B = %0d", A, B);
        $display("zero_flag = %0b (Expected: 1 - Branch taken)", zero_flag);
        $display("result = %0h", result);
        $display("----------------------------------------");
        
        // Test Case 2: Different values (should not branch - zero_flag should be 0)
        test_case = 2;
        A = 64'd200;
        B = 64'd300;
        addr = 12'h008; // Branch offset
        #10;
        $display("Test Case %0d: BEQ with Different Values", test_case);
        $display("A = %0d, B = %0d", A, B);
        $display("zero_flag = %0b (Expected: 0 - Branch not taken)", zero_flag);
        $display("result = %0h", result);
        $display("----------------------------------------");
        
        // Test Case 3: Equal negative values (should branch - zero_flag should be 1)
        test_case = 3;
        A = -64'd50;
        B = -64'd50;
        addr = 12'h008; // Branch offset
        #10;
        $display("Test Case %0d: BEQ with Equal Negative Values", test_case);
        $display("A = %0d, B = %0d", A, B);
        $display("zero_flag = %0b (Expected: 1 - Branch taken)", zero_flag);
        $display("result = %0h", result);
        $display("----------------------------------------");
        
        // Test Case 4: Different negative values (should not branch - zero_flag should be 0)
        test_case = 4;
        A = -64'd75;
        B = -64'd25;
        addr = 12'h008; // Branch offset
        #10;
        $display("Test Case %0d: BEQ with Different Negative Values", test_case);
        $display("A = %0d, B = %0d", A, B);
        $display("zero_flag = %0b (Expected: 0 - Branch not taken)", zero_flag);
        $display("result = %0h", result);
        $display("----------------------------------------");
        
        // Test Case 5: Zero values (should branch - zero_flag should be 1)
        test_case = 5;
        A = 64'd0;
        B = 64'd0;
        addr = 12'h008; // Branch offset
        #10;
        $display("Test Case %0d: BEQ with Zero Values", test_case);
        $display("A = %0d, B = %0d", A, B);
        $display("zero_flag = %0b (Expected: 1 - Branch taken)", zero_flag);
        $display("result = %0h", result);
        $display("----------------------------------------");
        
        // Test Case 6: Large positive values (should branch - zero_flag should be 1)
        test_case = 6;
        A = 64'd9223372036854775807; // Maximum positive 64-bit signed value
        B = 64'd9223372036854775807;
        addr = 12'h008; // Branch offset
        #10;
        $display("Test Case %0d: BEQ with Large Positive Values", test_case);
        $display("A = %0d, B = %0d", A, B);
        $display("zero_flag = %0b (Expected: 1 - Branch taken)", zero_flag);
        $display("result = %0h", result);
        $display("----------------------------------------");
        
        // Test Case 7: Large negative values (should branch - zero_flag should be 1)
        test_case = 7;
        A = -64'd9223372036854775808; // Minimum negative 64-bit signed value
        B = -64'd9223372036854775808;
        addr = 12'h008; // Branch offset
        #10;
        $display("Test Case %0d: BEQ with Large Negative Values", test_case);
        $display("A = %0d, B = %0d", A, B);
        $display("zero_flag = %0b (Expected: 1 - Branch taken)", zero_flag);
        $display("result = %0h", result);
        $display("----------------------------------------");
        
        // Test Case 8: Negative branch address
        test_case = 8;
        A = 64'd42;
        B = 64'd42;
        addr = 12'hFF8; // Negative branch offset (-8)
        #10;
        $display("Test Case %0d: BEQ with Negative Branch Offset", test_case);
        $display("A = %0d, B = %0d, addr = %0h", A, B, addr);
        $display("zero_flag = %0b (Expected: 1 - Branch taken)", zero_flag);
        $display("result = %0h", result);
        $display("----------------------------------------");
        
        $finish;
    end
      
endmodule