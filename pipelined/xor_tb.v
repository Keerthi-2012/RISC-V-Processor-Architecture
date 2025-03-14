`timescale 1ns / 1ps

module xor_gate_tb;

reg [63:0] x,y;
wire [63:0] final;

xor_gate uut (
    .x(x),
    .y(y),
    .final(final)
);

    initial begin 
        $dumpfile("waveform.vcd");  // VCD file for GTKWave
        $dumpvars(0, xor_gate_tb);    // Dump all variables in this module
    end

    initial begin
     
        x = 64'b0000000000000000000000000000000000000000000000000000000000000000;
        y = 64'b0000000000000000000000000000000000000000000000000000000000000000;
        #10;
        $display("Test 1: x=%b, y=%b, final=%b", x,y,final);

    
        x = 64'b0000000000000000000000000000000000000000000000000000000000000001;
        y = 64'b0000000000000000000000000000000000000000000000000000000000000001;
        #10;
         $display("Test 2: x=%b, y=%b , final=%b", x,y,final);

      
        x = 64'b1111111111111111111111111111111111111111111111111111111111111111; // -1
        y = 64'b1111111111111111111111111111111111111111111111111111111111111111; // -1
        #10;
         $display("Test 3: x=%b, y=%b , final=%b", x,y,final);

      
        x = 64'b0001001100110100010101100111100001001010110010111100111101110111;
        y = 64'b1111111011101100101100100000100110000111010101011101001100000001;
        #10;
        $display("Test 4: x=%b, y=%b, final=%b", x,y,final);
        
        $finish;
    end

endmodule

