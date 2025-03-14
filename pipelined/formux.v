// Corrected Forwarding MUX module
module forwarding_mux (
    input [1:0] forward_select,
    input [63:0] reg_value,      // Original register value
    input [63:0] ex_mem_value,   // Value from EX/MEM stage
    input [63:0] mem_wb_value,   // Value from MEM/WB stage
    output reg [63:0] mux_out    // Output value
);

    always @(*) begin
        case (forward_select)
            2'b00: mux_out = reg_value;      // No forwarding, use register value
            2'b01: mux_out = mem_wb_value;   // Forward from MEM/WB stage
            2'b10: mux_out = ex_mem_value;   // Forward from EX/MEM stage
            default: mux_out = reg_value;    // Default case
        endcase
    end
endmodule
