`timescale 1ns / 1ps

module single_compare_un(x,y,final);

input x;
input y;
output final;

wire x_not;

not (x_not,x);
and (final,x_not,y);

endmodule


module compare_bitwise_64 (
    input [63:0] rs1,  // A: 64-bit input
    input [63:0] rs2,  // B: 64-bit input
    output reg [63:0] result  // Output: 1 if A < B, 0 otherwise
);

reg res;
wire [63:0] check;
genvar i;
generate
    for (i = 63; i >= 0; i = i - 1) begin 
        single_compare_un u_single_compare_un (
            .x(rs1[i]),
            .y(rs2[i]),
            .final(check[i])
        );
    end
endgenerate


    reg found_difference;

    always @(*) begin
        res = 0;
        found_difference = 0;

        // Iterate from MSB to LSB
        for (integer i = 63; i >= 0; i = i - 1) begin
            if (!found_difference && (rs1[i] != rs2[i])) begin
                res = check[i];
                found_difference = 1;
            end
        end
    end

    always @(*) begin
        result = 64'b0;  
        result[0] = res;
    end

endmodule
