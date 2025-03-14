`timescale 1ns / 1ps

module twos_complement(

    input [63:0] in,
    output [63:0] out

);

assign out = ~in+1;
endmodule