module shift_sra (
    input [63:0] a,          // 64-bit input
    input [5:0] n,           // Number of bits to shift (0 to 63)
    output reg [63:0] result // Shifted result
);
    integer i;
    wire sign;
    
    assign sign = a[63];  // Extract the sign bit

    always @(*) begin
        result = 64'b0;  // Initialize the result to zero
        if (n < 64) begin
            // Perform right arithmetic shift
            for (i = n; i < 64; i = i + 1) begin
                result[i - n] = a[i];
            end

            // Fill the upper bits with the sign bit
            for (i = 63; i > 63 - n; i = i - 1) begin
                result[i] = sign;
            end
        end
    end
endmodule
