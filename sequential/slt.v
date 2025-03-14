`timescale 1ns / 1ps

module single_compare(x, y, final);
    input x;
    input y;
    output final;

    wire x_not;
    not (x_not, x);
    and (final, x_not, y);
endmodule

module compare_bitwise_64_signed (
    input signed [63:0] rs1,  // A: 64-bit signed input
    input signed [63:0] rs2,  // B: 64-bit signed input
    output reg signed [63:0] result // Output: 1 if A < B, 0 otherwise
);

    reg res;
    wire [62:0] check; // Wire for bitwise comparison results
    genvar i;

    generate
        for (i = 62; i >= 0; i = i - 1) begin : compare_loop
            single_compare u_single_compare (
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

        // Handle sign bit comparison first
        if (rs1[63] != rs2[63]) begin
            res = rs1[63];  // If rs1 is negative and rs2 is positive, rs1 < rs2
        end else begin
            // Sign bits are the same, compare from MSB to LSB
            for (integer j = 62; j >= 0; j = j - 1) begin
                if (!found_difference && (rs1[j] != rs2[j])) begin
                    res = check[j];
                    found_difference = 1;
                end
            end
        end
    end

    always @(*) begin
        result = 64'b0;  
        result[0] = res;
    end

endmodule
