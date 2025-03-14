`timescale 1ns / 1ps

module mux2to1 (
    output [63:0] Y,  // Output
    input  [63:0] A,  // Input 0
    input  [63:0] B,  // Input 1
    input         S   // Select
);
    // When S=0, Y=A; when S=1, Y=B
    assign Y = S ? B : A;
endmodule