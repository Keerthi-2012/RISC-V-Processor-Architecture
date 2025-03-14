`timescale 1ns / 1ps
`include "memory.v"
`include "fetch.v"

module main (
    input wire clk,
    input wire reset,
    input [31:0] instruction,
    output wire [63:0] result,
    output wire zero
);

    // Program Counter registers and wires
    reg [63:0] PC_reg;  // Program Counter register
    wire [63:0] next_PC;
    
    // Instruction decode wires
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [63:0] imm;
    wire instr_valid, imem_error;
    
    // Control signals
    wire ALU_src, Mem_to_Reg, Reg_Write, Mem_Read, Mem_Write, Branch_en;
    wire [2:0] funct3_out;
    wire [6:0] funct7_out;
    wire branch_taken;
    wire [63:0] branch_target;
    
    // ALU related wires
    wire [63:0] ValA, ValB;
    wire [63:0] alu_result;
    wire zero_flag, carry_alu, overflow_alu;
    
    // Memory related wires
    wire [63:0] mem_read_data;
    wire address_error;
    
    // Write back wire
    reg [63:0] write_data;

    // Update PC on clock edge
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_reg <= 64'h0;  // Reset PC to address 0
        end else begin
            PC_reg <= next_PC;  // Update PC with the next PC value
        end
    end

    // Fetch Unit
    fetch fetch_unit (
        .clk(clk),
        .PC(PC_reg),  // Use PC register here
        .instr(instruction),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm),
        .nextp(next_PC),
        .instr_valid(instr_valid),
        .imem_error(imem_error)
    );

    // Instruction Decoder - Updated to handle I-type instructions properly
    instruction_decoder decoder_main (
        .opcode(opcode),
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm),
        .ALU_src(ALU_src),
        .Mem_to_Reg(Mem_to_Reg),
        .Reg_Write(Reg_Write),
        .Mem_Read(Mem_Read),
        .Mem_Write(Mem_Write),
        .Branch_en(Branch_en),
        .ValA(ValA),  
        .ValB(ValB),
        .funct3_out(funct3_out),
        .funct7_out(funct7_out)
    );

    // ALU module connection
    ALU_Top alu_unit (
        
        .opcode(opcode),
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd),
        .funct3(funct3_out),
        .funct7(funct7_out),
        .alusrc(ALU_src),
        .imm(imm),
          // Use immediate if ALU_src is 1

        .result(alu_result),
        .carry_alu(carry_alu),
        .overflow_alu(overflow_alu),
        .zero_flag(zero_flag)
    );
    
    // Branch logic
    assign branch_taken = Branch_en & zero_flag;
    assign branch_target = imm;
    
    // Memory Integration - FIXED
    riscv_ld_sd memory_unit (
        .rs1(ValA),      
        .rs2(ValB),  
        .op(opcode),    
        .f7(funct7),
        .f3(funct3),   
        .imm12(imm[11:0]),  
        .clk(clk),               
        .memread(Mem_Read),  
        .memwrite(Mem_Write),
        .mem2reg(Mem_to_Reg),  
        .alures(alu_result),  // This is the effective address calculated by ALU
        .rd(mem_read_data),    
        .address_error(address_error)  
    );

    // Memory to Register MUX
    always @(*) begin
        if (Mem_to_Reg)
            write_data = mem_read_data;
        else
            write_data = alu_result;
    end

    // Register write-back with Reset Handling
    integer i;  

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                decoder_main.registers[i] <= 64'b0 + i; // Reset each register to index value
            end
        end else if (Reg_Write && rd != 0) begin
            decoder_main.registers[rd] <= write_data;
        end
    end

    // Debugging print statements - properly commented
    always @(posedge clk) begin
        /*
        if (Mem_Write)
            $display("STORE: Addr=%h, Data=%h", alu_result, ValB);
        if (Mem_Read)
            $display("LOAD: Addr=%h, Data=%h", alu_result, mem_read_data);
        
        // Add additional debugging for addi instruction
        if (opcode == 7'b0010011 && funct3 == 3'b000)
            $display("ADDI: rs1=%h, imm=%h, rd=%h, result=%h", ValA, imm, rd, alu_result);
            
        // General PC debugging
        $display("PC=%h, NextPC=%h, Instruction=%h", PC_reg, next_PC, instruction);
        */
    end

    // Output the final result (for monitoring/debugging)
    assign result = write_data;
    assign zero = zero_flag;

endmodule