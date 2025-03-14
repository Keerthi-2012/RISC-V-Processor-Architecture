
`timescale 1ns / 1ps

module ALU_tb();

    
    reg [3:0] control;
    reg signed [63:0] A;
    reg signed [63:0] B;
    reg [63:0] C;
    reg [63:0] D;

   
    wire signed [63:0] result;
    wire carry_alu;
    wire overflow_alu;
    wire single;

   
    ALU uut (
        .control(control),
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .result(result),
        .carry_alu(carry_alu),
        .overflow_alu(overflow_alu),
        .single(single)
    );

    initial begin
        $dumpfile("waveform.vcd");  // VCD file for GTKWave
        $dumpvars(0, ALU_tb);    // Dump all variables in this module
    end

    initial begin
      
        $monitor("Time: %0dns | control: %b | A: %b (%d)| B: %b (%d)| C:(%d)| D:(%d)| result: %b (%d) | carry_alu: %b | overflow_alu: %b | single: %b",
          $time, control, A, A, B, B, C, D, result, result, carry_alu, overflow_alu, single);

        // Test Case 1: ADD (4'b0010)
        control = 4'b0010;
        A = 64'd50;
        B = 64'd70;
        #10;

        control = 4'b0010;
        A = 64'd1;
        B = 64'd1;
        #10;

        control = 4'b0010;
        A = -64'd1;
        B = -64'd1;
        #10;


        control = 4'b0010;
        A= 64'b0001001100110100010101100111100001001010110010111100111101110111;
        B = 64'b1111111011101100101100100000100110000111010101011101001100000001;
        #10;

        control = 4'b0010;
        A = 64'sd9223372036854775807;  // Largest positive signed 64-bit number
        B = 64'sd1;
        #10;
        $display("");
        

        // Test Case 2: SUB (4'b0110)
        control = 4'b0110;
        A = 64'd100;
        B = 64'd50;
        #10;

        control = 4'b0110;
        A = 64'b0000000000000000000000000000000000000000000000000000000000000011;  // Decimal 3
        B = 64'b1111111111111111111111111111111111111111111111111111111111111100;  // Decimal -4
        #10;

        control = 4'b0110;
        A = 64'b1111111111111111111111111111111111111111111111111111111111111000;  // Decimal -8
        B = 64'b0000000000000000000000000000000000000000000000000000000000000001;  // Decimal 1
        #10;

        control = 4'b0110;
        A = -64'sd9223372036854775808;  // Smallest negative signed 64-bit number
        B = 64'sd1;
        #10;
        $display("");

        // Test Case 3: AND (4'b0000)
        control = 4'b0000;
        A = 64'hFFFF_FFFF_FFFF_FFFF;
        B = 64'h0000_FFFF_0000_FFFF;
        #10;
        $display("");

        // Test Case 4: OR (4'b0001)
        control = 4'b0001;
        A = 64'hFFFF_0000_FFFF_0000;
        B = 64'h0000_FFFF_0000_FFFF;
        #10;
        $display("");

        // Test Case 5: XOR (4'b0100)
        control = 4'b0100;
        A = 64'hAAAA_AAAA_AAAA_AAAA;
        B = 64'h5555_5555_5555_5555;
        #10;
        $display("");

        // Test Case 6: SLL (4'b1000)
        control = 4'b1000;
        A = 64'd5;
        B = 64'd2; 
        #10;

        control = 4'b1000;
        A = 64'd56;
        B = 64'd4; 
        #10;

        control = 4'b1000;
        A = 64'd1;
        B = 64'd0; 
        #10;
         $display("");

        // Test Case 7: SRL (4'b0101)
        control = 4'b0101;
        A = 64'hFFFF_FFFF_FFFF_FFFF;
        B = 64'd4; 
        #10;

        control = 4'b0101;
        A = 64'd1;
        B = 64'd0; 
        #10;

        control = 4'b0101;
        A = 64'd56;
        B = 64'd3; 
        #10;



         $display("");

        // Test Case 8: SRA (4'b1101)
        control = 4'b1101;
        A = -64'd16;
        B = 64'd3;
        #10;

        control = 4'b1101;
        A = 64'd1;
        B = 64'd0; 
        #10;

        control = 4'b1101;
        A = 64'd56;
        B = 64'd3; 
        #10;
         $display("");

        // Test Case 9: SLT (4'b0111)
        control = 4'b0111;
        A = -64'd5;
        B = 64'd10;
        #10;

        control = 4'b0111;
        A = 64'd5;
        B = 64'd1;
        #10;

        control = 4'b0111;
        A = -64'd5;
        B = -64'd10;
        #10;

        control = 4'b0111;
        A = 64'd5;
        B = 64'd5;
        #10;
        

        
         $display("");

        // Test Case 10: SLTU (4'b0011)
        control = 4'b0011;
        C = 64'd100;
        D = 64'd50;
        #10;

        control = 4'b0011;
        C = 64'hFFFFFFFFFFFFFFFF;
        D = 64'h0000000000000001;
        #10;

        control = 4'b0011;
        C = 64'd5;
        D = 64'd6;
        #10;


    

         $display("");
      

       

       

        $finish;
    end

endmodule

