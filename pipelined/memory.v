`timescale 1ns / 1ps
`include "execute.v"

module riscv_ld_sd (
    input signed [63:0] rs1,        // Base register address
    input signed [63:0] rs2,        // Store value register
    input [6:0] op,                 // Operation opcode
    input [6:0] f7,                 // Funct7 field
    input [2:0] f3,                 // Function code (load/store type)
    input [11:0] imm12,             // 12-bit immediate offset
    input clk,                      // Clock signal
    input memread,                  // Memory read enable
    input memwrite,                 // Memory write enable
    input mem2reg,                  // Memory to register control
    input [63:0] alures,            
    output reg [63:0] rd,           // Destination register (loaded value)
    output reg address_error        // Address out of bounds flag
);
    
    // Address calculation wire
    wire [63:0] addr;
    wire carry_out, overflow_flag;

    // Use ALU to calculate memory address 
    ALU address_calc (
        .funct7(f7),
        .funct3(f3),
        .opcode(op),
        .A(rs1),
        .B({{52{imm12[11]}}, imm12}),  // Sign-extend immediate
        .addr(imm12),
        .result(addr),
        .carry_alu(carry_out),
        .overflow_alu(overflow_flag)
    );
    
    // bit64_adder add_instin(
    //     .a(rs1),
    //     .b({{52{imm12[11]}}, imm12}),
    //     .sum(addr),
    //     .carry(carry_out),
    //     .overflow(overflow_flag)
    // );


    // Memory with 1024 entries for 64-bit doublewords
    reg [63:0] memory [0:1023];
    
    // Memory initialization - Avoids truncation warnings
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 64'h0000000000000000;  // Ensure width consistency
        end
    end

    // Explicit 12-bit address extraction with masking to ensure correct range
    wire [11:0] word_addr = addr[11:0] & 12'hFFF; // Ensure only valid range is used

    // Memory access logic for SD and LD instructions
    always @(posedge clk) begin
        // Address boundary check
        if (word_addr > 12'hFFF) begin  // Ensure within 0 - 1023
            address_error <= 1'b1;  // Out of bounds
            rd <= 64'hX;            // Invalid data
        end else begin
            address_error <= 1'b0;
            
            // STORE Doubleword (SD) Operation
            if (memwrite && f3 == 3'b011) begin
                memory[word_addr] <= rs2;
                // $display("SD: Store Doubleword - Addr=%h, Value=%h", addr, rs2);
            end
            
            // LOAD Doubleword (LD) Operation
            if (memread && f3 == 3'b011) begin
                rd <= memory[word_addr];
                // $display("LD: Load Doubleword - Addr=%h, Value=%h", addr, memory[word_addr]);
            end
        end
    end

endmodule