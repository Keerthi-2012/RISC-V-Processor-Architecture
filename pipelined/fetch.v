`timescale 1ns / 1ps
`include "mux.v"

module fetch (
    input         clk,
    input  [63:0] PC,        // Program Counter
    input  [31:0] instr,     // 32-bit instruction
    input         branch_taken, // Control signal indicating branch/jump should be taken
    input  [63:0] branch_target, // Target address for branch/jump

    // Decoded instruction fields
    output [6:0]  opcode,  
    output [4:0]  rd, rs1, rs2,  
    output [2:0]  funct3,  
    output [6:0]  funct7,  
    output [63:0] imm,  // Immediate Value
    output [63:0] nextp,  // Next PC

    // Control Signals
    output instr_valid, imem_error  
);

    // Extract opcode and rs1 (always valid)
    assign opcode = instr[6:0];
    assign rs1    = instr[19:15];

    // Internal signal for immediate value
    reg [63:0] imm_internal;

    // Default values for invalid fields
    reg [4:0] rd_internal, rs2_internal;
    reg [2:0] funct3_internal;
    reg [6:0] funct7_internal;

    always @(*) begin
        // Default invalid values
        rd_internal   = 5'b00000;
        rs2_internal  = 5'b00000;
        funct3_internal = 3'b000;
        funct7_internal = 7'b0000000;
        imm_internal  = 64'b0;

        case (opcode)
            7'b0110011: begin // R-type (e.g., add, sub)
                rd_internal    = instr[11:7];
                rs2_internal   = instr[24:20];
                funct3_internal = instr[14:12];
                funct7_internal = instr[31:25];
            end

            7'b0010011, // I-type (e.g., addi, andi, ori)
            7'b0000011: begin // Load (lw)
                rd_internal    = instr[11:7];
                funct3_internal = instr[14:12];
                imm_internal   = {{52{instr[31]}}, instr[31:20]};
            end
            
            7'b0100011: begin // S-type (e.g., sw, sh, sb)
                rs2_internal   = instr[24:20];
                funct3_internal = instr[14:12];
                imm_internal   = {{52{instr[31]}}, instr[31:25], instr[11:7]};
            end

            7'b1100011: begin // S B-type (e.g., beq, bne)
                rs2_internal   = instr[24:20];
                funct3_internal = instr[14:12];
                imm_internal   = {{51{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            7'b0110111, // U-type (lui) Loads a 20-bit immediate into the upper 20 bits of rd, setting the lower 12 bits to zero.
            7'b0010111: begin // U-type (auipc) AUIPC (Add Upper Immediate to PC) Computes PC + (imm << 12) and stores the result in rd
                rd_internal    = instr[11:7];
                imm_internal   = {{32{instr[31]}}, instr[31:12], 12'b0};
            end

            7'b1101111: begin // UJ-type (jal)
                rd_internal    = instr[11:7];
                imm_internal   = {{43{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            end
        endcase
    end

    assign rd     = rd_internal;
    assign rs2    = rs2_internal;
    assign funct3 = funct3_internal;
    assign funct7 = funct7_internal;
    assign imm    = imm_internal;

    // Calculate sequential next PC (PC+4)
    wire [63:0] sequential_pc;
assign sequential_pc = PC + 64'd4;
// assign branch_target = branch_target;
wire [63:0] branch_pc;
assign branch_pc = PC + branch_target;


    
    // Instantiate the 2-to-1 MUX for PC selection
    mux2to1 pc_mux (
        .Y(nextp),             // Output
        .A(sequential_pc),     // PC+4 (when S=0)
        .B(branch_pc),     // Branch target (when S=1)
        .S(branch_taken)       // Select signal
    );
    
    // Instruction validity check (basic check for known opcodes)
    assign instr_valid = (opcode == 7'b0110011) || // R-type (add, sub)
                         (opcode == 7'b0010011) || // I-type (addi, andi, ori)
                         (opcode == 7'b0000011) || // Load (lw)
                         (opcode == 7'b0100011) || // Store (sw)
                         (opcode == 7'b1100011) ;

    // Memory access error check (assuming a 1024-byte instruction memory)
    assign imem_error = (PC >= 1024) ? 1'b1 : 1'b0;

endmodule