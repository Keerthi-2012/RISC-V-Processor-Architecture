`timescale 1ns / 1ps

module full_bit_subtractor(
    input x,
    input y,
    input Bin,
    output D,
    output B
);
    wire xy_d;
    wire xy_b;
    wire bin_borrow;

    xor diff_xy(xy_d, x, y);               // XOR for the difference of x and y
    not (x_bar, x);                         // NOT of x
    and borrow_xy(xy_b, x_bar, y);          // AND for borrow
    xor difference1(D, xy_d, Bin);         // XOR for the final difference considering Bin
    not (xy_d_bar, xy_d);                  // NOT of xy_d
    and Borrow_Bin(bin_borrow, Bin, xy_d_bar); // AND for borrow with Bin
    or borrow1(B, xy_b, bin_borrow);       // Final OR for borrow output
endmodule


module bit64_subtractor (
    input signed [63:0] a,  // 64-bit signed input a
    input signed [63:0] b,  // 64-bit signed input b
    output signed [63:0] difference, // 64-bit signed subtraction result
    output borrow,         // Borrow output
    output overflow        // Overflow output
);

    wire [64:0] temp_borrow;  // Array to hold intermediate borrow values
    assign temp_borrow[0] = 0;  // Initial borrow is 0

    // Generate full subtractors for each bit
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            full_bit_subtractor u_full_bit_subtractor (
                .x(a[i]),
                .y(b[i]),
                .Bin(temp_borrow[i]),
                .D(difference[i]),
                .B(temp_borrow[i+1])
            );
        end
    endgenerate

    // Final borrow is stored in temp_borrow[64]
    assign borrow = temp_borrow[64];

    // Overflow detection for signed subtraction
    assign overflow = (a[63] & ~b[63] & ~difference[63]) | (~a[63] & b[63] & difference[63]);

endmodule
