`timescale 1ns / 1ps

module singlebit(x,y,cin,s,c);

input x;
input y;
input cin;
output s;
output c;


wire xy_s;
wire xy_c;
wire cin_carry;

xor sum_xy(xy_s,x,y);
and carry_xy(xy_c,x,y);
xor sum1(s,xy_s,cin);
and carry_cin(cin_carry,cin,xy_s);
or carry1(c,xy_c,cin_carry);

endmodule






module bit64_adder (
    input signed [63:0] a,
    input signed [63:0] b,
    output signed [63:0] sum,
    output carry,
    output overflow
);

wire [64:0] temp_carry;
assign temp_carry[0] = 0;



genvar i;
generate
    for (i = 0; i < 64; i = i + 1) begin 
        singlebit u_singlebit (
            .x(a[i]),
            .y(b[i]),
            .cin(temp_carry[i]),
            .s(sum[i]),
            .c(temp_carry[i + 1])
        );
    end
endgenerate

assign carry = temp_carry[64];
assign overflow = (a[63] == b[63]) && (sum[63] != a[63]);

endmodule
