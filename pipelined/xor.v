`timescale 1ns / 1ps

module xor_gate(x,y,final);

input [63:0] x;
input [63:0] y;
output [63:0] final;

genvar i;

    generate 
 
        for (i = 0; i<64; i = i + 1) begin

            xor xor1(final[i], x[i], y[i]);

        end

    endgenerate

endmodule

