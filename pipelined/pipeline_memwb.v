`timescale 1ns / 1ps
module pipeline_memwb(
    input wire clk,
    input wire reset,
    // Data inputs
    input wire [63:0] rd_in,
    input wire [63:0] alu_result_in,
    input wire [4:0] rd_addr_in,
    // Control inputs
    input wire regwrite_in,
    input wire memtoreg_in,
    // Data outputs
    output reg [63:0] rd_out,
    output reg [63:0] alu_result_out,
    output reg [4:0] rd_addr_out,
    // Control outputs
    output reg regwrite_out,
    output reg memtoreg_out
);

// Pipeline register update logic - synchronous reset
always @(posedge clk) begin
    if (reset) begin
        // Reset all registers to known values
        rd_out <= 64'bx;
        alu_result_out <= 64'bx;
        rd_addr_out <= 5'bx;
        regwrite_out <= 1'bx;
        memtoreg_out <= 1'bx;
    end
    else begin
        // SYNCHRONIZE THE OUTPUT - pass values from MEM to WB
        rd_out <= rd_in;
        alu_result_out <= alu_result_in;
        rd_addr_out <= rd_addr_in;
        regwrite_out <= regwrite_in;
        memtoreg_out <= memtoreg_in;
    end
end
endmodule