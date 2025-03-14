module shift_sll (
    input [63:0] a,          // 64-bit input
    input [5:0] n,           // Number of bits to shift (0 to 63)
    output reg [63:0] result // Shifted result
);
    integer i;

    always @(*) begin
        result = 64'b0;  // Initialize the result to zero
        if (n < 64) begin
            for (i = 0; i < 64 - n; i = i + 1) begin
                result[i + n] = a[i];
            end
        end
    end
endmodule
