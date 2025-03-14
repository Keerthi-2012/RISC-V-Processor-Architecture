`timescale 1ns / 1ps

`include "fetch.v"
`include "stall_ifid.v"
`include "cd.v"
`include "pipeline_idex.v"
`include "pipeline_execute.v"
`include "pipeline_exmem.v"
`include "pipeline_memory.v"
`include "pipeline_memwb.v"
`include "pipeline_forward.v"
`include "formux.v"
`include "hazard_detection.v"  // Add the hazard detection unit


module stall_processor(
    input wire clk,
    input wire reset,
    input [31:0] instruction,
    output wire [63:0] result_final,
    output wire zero_final
);

    // Define internal wires
    reg [63:0] PC;
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [63:0] imm;
    wire [63:0] nextp;
    wire instr_valid;
    wire imem_error;
    
    // Branch control signals
    wire branch_taken;
    wire [63:0] branch_target;

    // Hazard detection signals
    wire pipeline_stall;
    wire flush; // Added flush signal for branch taken
    
    // PC and IF/ID control based on stall and branch
    wire pc_write_enable;
    wire if_id_write_enable;
    wire if_id_flush;
    
    // Control signals for hazard handling
    assign pc_write_enable = ~pipeline_stall | branch_taken;
    assign if_id_write_enable = ~pipeline_stall;
    assign if_id_flush = branch_taken;

    //IF/ID Pipeline Register Outputs
    wire [6:0] opcode_out;
    wire [4:0] rd_out, rs1_out, rs2_out;
    wire [2:0] funct3_out;
    wire [6:0] funct7_out;
    wire [63:0] imm_out;
    wire [63:0] PC_out;
    
    initial begin 
        PC <= 64'b0;
    end
    
    // Update PC on the rising edge of the clock
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 64'b0;
        end else if (pc_write_enable) begin
            if (branch_taken) begin
                PC <= branch_target;  // Use branch target if branch is taken
            end else if (~pipeline_stall) begin
                PC <= nextp;  // Update PC to next sequential address if not stalled
            end
        end
        // If pc_write_enable is 0 (stalled and no branch), PC remains the same
    end

    // Instantiate Fetch module
    fetch fetch_unit (
        .clk(clk),
        .PC(PC),
        .instr(instruction),
        .branch_taken(1'b0), // Changed - branch is now handled in PC update logic above
        .branch_target(64'b0), // Changed - branch is now handled in PC update logic above
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm),
        .nextp(nextp),
        .instr_valid(instr_valid),
        .imem_error(imem_error)
    );

    // Instantiate IF/ID Pipeline Register with write enable for stalling and flush for branching
    stall_ifid ifid_unit (
        .clk(clk),
        .reset(reset | if_id_flush), // Flush on branch taken
        .write_enable(if_id_write_enable),
        .opcode_in(opcode),
        .rd_in(rd),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .funct3_in(funct3),
        .funct7_in(funct7),
        .imm_in(imm),
        .PC_in(PC), // Changed from nextp to PC for proper branching
        .opcode_out(opcode_out),
        .rd_out(rd_out),
        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .funct3_out(funct3_out),
        .funct7_out(funct7_out),
        .imm_out(imm_out),
        .PC_out(PC_out)
    );

    wire ALU_src, Mem_to_Reg, Reg_Write, Mem_Read, Mem_Write, Branch_en;
    wire signed [63:0] ValA, ValB;
    wire [2:0] funct3_out_cd;
    wire [6:0] funct7_out_cd;
    wire [63:0] imm_out_cd;
    wire [6:0] opcode_out_cd;
    wire [4:0] rs1_out_cd, rs2_out_cd, rd_out_cd;
    
    // Control signals after hazard mux
    wire ALU_src_mux, Mem_to_Reg_mux, Reg_Write_mux, Mem_Read_mux, Mem_Write_mux, Branch_en_mux;

    // Instantiate Control Decode module
    instruction_decoder inst_decode(
        .opcode(opcode_out),
        .rs1(rs1_out),
        .rs2(rs2_out),
        .rd(rd_out),
        .funct3(funct3_out),
        .funct7(funct7_out),
        .imm(imm_out),
        .ALU_src(ALU_src),
        .Mem_to_Reg(Mem_to_Reg),
        .Reg_Write(Reg_Write),
        .Mem_Read(Mem_Read),
        .Mem_Write(Mem_Write),
        .Branch_en(Branch_en),
        .ValA(ValA),
        .ValB(ValB),
        .opcode_out(opcode_out_cd),
        .rs1_out(rs1_out_cd),
        .rs2_out(rs2_out_cd),
        .rd_out(rd_out_cd), 
        .funct3_out(funct3_out_cd),
        .funct7_out(funct7_out_cd),
        .imm_out(imm_out_cd)
    );

    // Hazard Detection Unit
    hazard_detection_unit hazard_unit(
        .IF_ID_RegisterRs1(rs1_out),
        .IF_ID_RegisterRs2(rs2_out),
        .ID_EX_RegisterRd(rd_out_idex),
        .ID_EX_MemRead(Mem_Read_out),
        .stall(pipeline_stall)
    );

    // Control signal multiplexers for hazard handling
    // When pipeline_stall is 1, insert NOP by setting all control signals to 0
    assign ALU_src_mux = pipeline_stall ? 1'b0 : ALU_src;
    assign Mem_to_Reg_mux = pipeline_stall ? 1'b0 : Mem_to_Reg;
    assign Reg_Write_mux = pipeline_stall ? 1'b0 : Reg_Write;
    assign Mem_Read_mux = pipeline_stall ? 1'b0 : Mem_Read;
    assign Mem_Write_mux = pipeline_stall ? 1'b0 : Mem_Write;
    assign Branch_en_mux = pipeline_stall ? 1'b0 : Branch_en;

    wire [4:0] rd_out_idex;
    wire ALU_src_out, Mem_to_Reg_out, Reg_Write_out, Mem_Read_out, Mem_Write_out, Branch_en_out;
    wire [63:0] PC_out_idex;
    wire signed [63:0] ValA_idex, ValB_idex;
    wire [2:0] funct3_out_idex;
    wire [6:0] funct7_out_idex;
    wire [63:0] imm_out_idex;
    wire [6:0] opcode_out_idex;
    wire [4:0] rs1_out_idex, rs2_out_idex;

    // Instantiate ID/EX Pipeline Register with modified control signals for hazard handling
    idex idex_unit (
        .clk(clk),
        .reset(reset),
        .ALU_src_in(ALU_src_mux),
        .Mem_to_Reg_in(Mem_to_Reg_mux),
        .Reg_Write_in(Reg_Write_mux),
        .Mem_Read_in(Mem_Read_mux),
        .Mem_Write_in(Mem_Write_mux),
        .Branch_en_in(Branch_en_mux),
        .PC_in(PC_out),
        .ValA_in(ValA),
        .ValB_in(ValB),
        .imm_in(imm_out_cd),
        .opcode_in(opcode_out_cd),
        .funct3_in(funct3_out_cd),
        .funct7_in(funct7_out_cd),
        .rs1_in(rs1_out_cd),
        .rs2_in(rs2_out_cd),
        .rd_in(rd_out_cd),
        .opcode_out(opcode_out_idex),
        .ALU_src_out(ALU_src_out),
        .Mem_to_Reg_out(Mem_to_Reg_out),
        .Reg_Write_out(Reg_Write_out),
        .Mem_Read_out(Mem_Read_out),
        .Mem_Write_out(Mem_Write_out),
        .Branch_en_out(Branch_en_out),
        .PC_out(PC_out_idex),
        .ValA_out(ValA_idex),
        .ValB_out(ValB_idex),
        .imm_out(imm_out_idex),
        .funct3_out(funct3_out_idex),
        .funct7_out(funct7_out_idex),
        .rs1_out(rs1_out_idex),
        .rs2_out(rs2_out_idex),
        .rd_out(rd_out_idex)
    );

    // Forward declaration of forwarded signals
    wire signed [63:0] ValA_forwarded, ValB_forwarded;

    wire signed [63:0] reso;
    wire carry_alu, overflow_alu, zero_flag;
    wire [6:0] opcode_out_ex;
    wire [2:0] funct3_out_ex;
    wire [6:0] funct7_out_ex;
    wire [4:0] rs1_out_ex, rs2_out_ex, rd_out_ex;

    //Instantiate execute module
    ALU_Top alu_pipeline (
        .opcode(opcode_out_idex),
        .rs1(rs1_out_idex),
        .rs2(rs2_out_idex),
        .rd(rd_out_idex),    
        .funct3(funct3_out_idex),
        .funct7(funct7_out_idex),
        .alusrc(ALU_src_out),
        .imm(imm_out_idex),
        .ValA(ValA_forwarded),
        .ValB(ValB_forwarded),
        .result(reso),
        .carry_alu(carry_alu),
        .overflow_alu(overflow_alu),
        .opcode_out(opcode_out_ex),
        .rs1_out(rs1_out_ex),
        .rs2_out(rs2_out_ex),
        .rd_out(rd_out_ex),
        .funct3_out(funct3_out_ex),
        .funct7_out(funct7_out_ex),
        .zero_flag(zero_flag)
    );

    wire ALU_src_out_ex, Mem_to_Reg_out_ex, Reg_Write_out_ex, Mem_Read_out_ex, Mem_Write_out_ex, Branch_en_out_ex;
    wire [63:0] PC_out_exmem;
    wire signed [63:0] ValB_exmem;
    wire [4:0] rd_out_exmem;
    wire [63:0] imm_out_exmem;
    wire carry_alu_exmem, overflow_alu_exmem, zero_flag_exmem;
    wire signed [63:0] result_exmem;
    wire [6:0] opcode_out_exmem;
    wire [2:0] funct3_out_exmem;
    wire [6:0] funct7_out_exmem;
    wire [4:0] rs1_out_exmem, rs2_out_exmem;

    wire [63:0] branch_pc;
    assign branch_pc = PC_out_idex + (imm_out_idex << 1);

    //Instantiate ex/mem module
    exmem exmem_unit (
        .clk(clk),
        .reset(reset),
        .Mem_to_Reg_in(Mem_to_Reg_out),
        .Reg_Write_in(Reg_Write_out),
        .Mem_Read_in(Mem_Read_out),
        .Mem_Write_in(Mem_Write_out),
        .Branch_en_in(Branch_en_out),
        .PC_in(branch_pc),
        .zero_flag_in(zero_flag),
        .result_in(reso),
        .ValB_in(ValB_forwarded),
        .imm_in(imm_out_idex),
        .rd_in(rd_out_ex),
        .rs1(rs1_out_ex),
        .rs2(rs2_out_ex),
        .opcode(opcode_out_ex),
        .funct3_in(funct3_out_ex),
        .funct7_in(funct7_out_ex),
        .opcode_out(opcode_out_exmem),
        .rs1_out(rs1_out_exmem),
        .rs2_out(rs2_out_exmem),
        .funct3_out(funct3_out_exmem),
        .funct7_out(funct7_out_exmem),
        .Mem_to_Reg_out(Mem_to_Reg_out_ex),
        .Reg_Write_out(Reg_Write_out_ex),
        .Mem_Read_out(Mem_Read_out_ex),
        .Mem_Write_out(Mem_Write_out_ex),
        .Branch_en_out(Branch_en_out_ex),
        .PC_out(PC_out_exmem),
        .zero_flag_out(zero_flag_exmem),
        .result_out(result_exmem),
        .ValB_out(ValB_exmem),
        .imm_out(imm_out_exmem),
        .rd_out(rd_out_exmem)
    );

    // Branch logic - now using continuous assignment instead of always block
    assign branch_taken = Branch_en_out_ex & zero_flag_exmem;
    assign branch_target = PC_out_exmem;
    
    // Data Memory
    reg [63:0] data_memory [0:1023]; // 1024 entries of 64-bit memory
    wire [63:0] mem_addr;
    wire [63:0] mem_rd_data;
    
    // Initialize data memory with some values for testing
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            data_memory[i] = 64'h1000 + i; // Initialize with some pattern
        end
    end
    
    // Calculate memory address (use ALU result)
    assign mem_addr = result_exmem;
    
    // Memory read/write operations
    always @(posedge clk) begin
        if (Mem_Write_out_ex) begin
            data_memory[mem_addr[11:3]] <= ValB_exmem; // Store data to memory
            $display("Memory Write: Addr=%h, Data=%h", mem_addr, ValB_exmem);
        end
    end
    
    // Memory read operation (combinational)
    assign mem_rd_data = (Mem_Read_out_ex) ? data_memory[mem_addr[11:3]] : 64'h0;
    
    wire [63:0] rd_value_memwb;
    wire [63:0] result_memwb;
    wire [4:0] rd_addr_memwb;
    wire Reg_Write_out_memwb;
    wire Mem_to_Reg_out_memwb;

    pipeline_memwb memwb_unit (
       .clk(clk),
       .reset(reset),
       .rd_in(mem_rd_data),  // Memory data read
       .alu_result_in(result_exmem),
       .rd_addr_in(rd_out_exmem),
       .regwrite_in(Reg_Write_out_ex),
       .memtoreg_in(Mem_to_Reg_out_ex),
       .rd_out(rd_value_memwb),
       .alu_result_out(result_memwb),
       .rd_addr_out(rd_addr_memwb),
       .regwrite_out(Reg_Write_out_memwb),
       .memtoreg_out(Mem_to_Reg_out_memwb)
    );

    wire [1:0] forwardA;
    wire [1:0] forwardB;

    // Final write data selection (mux between ALU result and memory data)
    wire [63:0] write_data;
    // Use a continuous assignment with a conditional operator
    assign write_data = (Reg_Write_out_memwb) ? 
                    ((Mem_to_Reg_out_memwb) ? rd_value_memwb : result_memwb) : 
                    64'bx;
    // Register write-back with Reset Handling
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                inst_decode.registers[i] <= 64'b0 + i; // Reset each register to index value
            end
        end else if (Reg_Write_out_memwb && rd_addr_memwb != 0) begin
            inst_decode.registers[rd_addr_memwb] <= write_data;
            $display("Register Write: r%d = %h", rd_addr_memwb, write_data);
        end
    end

    assign result_final = write_data;
    assign zero_final = zero_flag_exmem;

    forwarding_unit pipeline(
        .ID_EX_RegisterRs1(rs1_out_idex),
        .ID_EX_RegisterRs2(rs2_out_idex),
        .EX_MEM_RegisterRd(rd_out_exmem),
        .MEM_WB_RegisterRd(rd_addr_memwb),
        .EX_MEM_RegWrite(Reg_Write_out_ex),
        .MEM_WB_RegWrite(Reg_Write_out_memwb),
        .ForwardA(forwardA),
        .ForwardB(forwardB)
    );

    forwarding_mux forward_mux_a (
        .forward_select(forwardA),
        .reg_value(ValA_idex),
        .ex_mem_value(result_exmem),
        .mem_wb_value(write_data),
        .mux_out(ValA_forwarded)
    );

    forwarding_mux forward_mux_b (
        .forward_select(forwardB),
        .reg_value(ValB_idex),
        .ex_mem_value(result_exmem),
        .mem_wb_value(write_data),
        .mux_out(ValB_forwarded)
    );

    always @(posedge clk) begin
        $display("---------- Clock Cycle ----------");
        $display("Reset: %h", reset);
        $display("Current PC: %h", PC);
        $display("Instruction: %h", instruction);
        $display("Pipeline Stall: %b", pipeline_stall);
        $display("Branch Taken: %b", branch_taken);
        
        $display("\nFetch Stage Outputs:");
        $display("  opcode: %b, rd: %d, rs1: %d, rs2: %d", opcode, rd, rs1, rs2);
        $display("  funct3: %b, funct7: %b", funct3, funct7);
        $display("  imm: %h", imm);
        $display("  Next PC: %h", nextp);
        $display("  Valid Instruction: %b, Memory Error: %b", instr_valid, imem_error);
        
        $display("\nPipeline Register IF/ID Outputs:");
        $display("  opcode_out: %b, rd_out: %d, rs1_out: %d, rs2_out: %d", 
                 opcode_out, rd_out, rs1_out, rs2_out);
        $display("  funct3_out: %b, funct7_out: %b", funct3_out, funct7_out);
        $display("  imm_out: %h", imm_out);
        $display("  PC_out: %h", PC_out);
        
        $display("\nInstruction Decoder Outputs:");
        $display("  Control Signals:");
        $display("    ALU_src: %b, Mem_to_Reg: %b, Reg_Write: %b", ALU_src, Mem_to_Reg, Reg_Write);
        $display("    Mem_Read: %b, Mem_Write: %b, Branch_en: %b", Mem_Read, Mem_Write, Branch_en);
        $display("  Hazard Controlled Signals:");
        $display("    ALU_src_mux: %b, Mem_to_Reg_mux: %b, Reg_Write_mux: %b", 
                ALU_src_mux, Mem_to_Reg_mux, Reg_Write_mux);
        $display("    Mem_Read_mux: %b, Mem_Write_mux: %b, Branch_en_mux: %b", 
                Mem_Read_mux, Mem_Write_mux, Branch_en_mux);
        $display("  Register Values:");
        $display("    ValA: %h, ValB: %h", ValA, ValB);
        $display("  Instruction Fields Passed to ID/EX:");
        $display("    opcode_out_cd: %b", opcode_out_cd);
        $display("    rs1_out_cd: %d, rs2_out_cd: %d, rd_out_cd: %d", rs1_out_cd, rs2_out_cd, rd_out_cd);
        $display("    funct3_out_cd: %b, funct7_out_cd: %b", funct3_out_cd, funct7_out_cd);
        $display("    imm_out_cd: %h", imm_out_cd);
        
        $display("\nID/EX Pipeline Register Outputs:");
        $display("  Control Signals:");
        $display("    ALU_src_out: %b, Mem_to_Reg_out: %b, Reg_Write_out: %b", 
                 ALU_src_out, Mem_to_Reg_out, Reg_Write_out);
        $display("    Mem_Read_out: %b, Mem_Write_out: %b, Branch_en_out: %b", 
                 Mem_Read_out, Mem_Write_out, Branch_en_out);
        $display("  Register Values and Forwarding:");
        $display("    ValA_idex: %h, ValB_idex: %h", ValA_idex, ValB_idex);
        $display("    forwardA: %b, forwardB: %b", forwardA, forwardB);
        $display("    ValA_forwarded: %h, ValB_forwarded: %h", ValA_forwarded, ValB_forwarded);
        $display("  Instruction Fields:");
        $display("    opcode_out_idex: %b", opcode_out_idex);
        $display("    rs1_out_idex: %d, rs2_out_idex: %d, rd_out_idex: %d", rs1_out_idex, rs2_out_idex, rd_out_idex);
        $display("    funct3_out_idex: %b, funct7_out_idex: %b", funct3_out_idex, funct7_out_idex);
        $display("    imm_out_idex: %h", imm_out_idex);
        $display("  Program Counter:");
        $display("    PC_out_idex: %h", PC_out_idex);
        $display("    Branch target: %h", branch_pc);
        
        $display("\nExecute Stage Outputs:");
        $display("  result: %h", reso);
        $display("  Carry: %b, Overflow: %b, Zero Flag: %b", carry_alu, overflow_alu, zero_flag);   
        $display("  Instruction Fields Passed to EX/MEM:");
        $display("    opcode_out_ex: %b", opcode_out_ex);
        $display("    rs1_out_ex: %d, rs2_out_ex: %d, rd_out_ex: %d", rs1_out_ex, rs2_out_ex, rd_out_ex);
        $display("    funct3_out_ex: %b, funct7_out_ex: %b", funct3_out_ex, funct7_out_ex);

        $display("\nEX/MEM Pipeline Register Outputs:");
        $display("  Control Signals:");
        $display("    Mem_to_Reg_out: %b, Reg_Write_out: %b, Mem_Read_out: %b", 
                 Mem_to_Reg_out_ex, Reg_Write_out_ex, Mem_Read_out_ex);
        $display("    Mem_Write_out: %b, Branch_en_out: %b", Mem_Write_out_ex, Branch_en_out_ex);
        $display("  Register Values:");
        $display("    ValB_exmem: %h", ValB_exmem);
        $display("  Result: %h", result_exmem);
        $display("  Zero Flag: %b", zero_flag_exmem); 
        $display("  Branch Signals:");
        $display("    branch_taken: %b", branch_taken);
        $display("    branch_target: %h", branch_target);

        $display("\nMemory Stage Outputs:");
        $display("  Control Signals:");
        $display("    Mem_Read: %b, Mem_Write: %b, Mem_to_Reg: %b", 
                Mem_Read_out_ex, Mem_Write_out_ex, Mem_to_Reg_out_ex);
        $display("  Memory Address: %h", mem_addr);
        $display("  Write Data (ValB): %h", ValB_exmem);
        $display("  Read Data: %h", mem_rd_data);
        $display("  Destination Register (rd): %d", rd_out_exmem);

        $display("\nMEM/WB Pipeline Register Outputs:");
        $display("  Control Signals:");
        $display("    Reg_Write_out: %b, Mem_to_Reg_out: %b", 
                Reg_Write_out_memwb, Mem_to_Reg_out_memwb);
        $display("  Memory Data: %h", rd_value_memwb);
        $display("  ALU Result: %h", result_memwb);
        $display("  Destination Register (rd): %d", rd_addr_memwb);
        $display("  Write Data (final): %h", write_data);

        $display("----------------------------------------\n");
    end
endmodule