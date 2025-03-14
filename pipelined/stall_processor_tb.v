`timescale 1ns / 1ps

module stall_processor_tb;
    // Testbench signals
    reg clk;
    reg reset;
    reg [31:0] instruction_reg;
    wire [63:0] result;
    wire zero;

    reg [31:0] instr_memory [0:1023];
    reg [9:0] instruction_pointer;
    
    // Instantiate the processor - use the registered instruction
    stall_processor dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction_reg),
        .result_final(result),
        .zero_final(zero)
    );

    wire [63:0] PC = dut.PC;

    // Register instruction to prevent combinational loops
    always @(posedge clk) begin
        instruction_reg <= instr_memory[PC[11:2]];
    end
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end
    
    // VCD file for waveform generation
    initial begin
        $dumpfile("wf_tb.vcd");
        $dumpvars(0, stall_processor_tb);
        $display("VCD info: dumpfile processor_tb.vcd opened for output.");
    end
    
    // Test stimulus with improved initialization
    initial begin
        // Initialize signals
        reset = 1;
        instruction_reg = 32'h00000013; // NOP instruction
        instruction_pointer = 0;
        
        // Initialize instruction memory
        for (integer i = 0; i < 1024; i = i + 1) begin
            instr_memory[i] = 32'h00000000; // Default NOP instruction
        end

        // Load all test instructions at the beginning
        // Load-use hazard test sequence  
        instr_memory[0] = 32'b0000000_00010_00001_000_00100_0110011; // add x4, x1, x2
        

        instr_memory[1] = 32'b0100000_00100_00101_000_00110_0110011; // sub x6, x5, x4
        

        instr_memory[2] = 32'b0000000_00100_00110_000_00111_0110011; // add x7, x4, x6
        

        instr_memory[3] = 32'b0000000_01001_00111_000_01000_0010011; // addi x8, x7, 9
        

        instr_memory[4] = 32'b0000000_01011_01101_011_01000_0100011; // sd x11, 8(x13) 
        

        instr_memory[5] = 32'b000000001000_01101_011_11000_0000011; // ld x24, 8(x13) 
        


        instr_memory[6] = 32'b0000000_11001_11000_111_10001_0110011; // and x17, x24, x25
        

        instr_memory[7] = 32'b0; 

        instr_memory[8] = 32'b0000000_11010_11011_110_10011_0110011; // or x19, x26, x27
        


        instr_memory[9] = 32'b0000000_01110_01101_000_0011_0_1100011; // beq x13,x14,3 (neq)
        

        instr_memory[10] = 32'b0000000_01111_01111_000_0010_0_1100011; // beq x15,x16,3 (eq)
        


        instr_memory[11] = 32'b0; 
        
        instr_memory[12] = 32'b0; 
        
        instr_memory[13] = 32'b0; 
        
        instr_memory[14] = 32'b0; 
        
        instr_memory[15] = 32'b0; 
        #10;
        // // Pre-initialize critical registers for testing
        // dut.inst_decode.registers[1] = 64'h1000; // Initialize x1 (base address for loads)
        // dut.inst_decode.registers[5] = 64'h00FF; // Initialize x5 (for AND operation)
        // dut.inst_decode.registers[6] = 64'hFF00; // Initialize x6 (for OR operation)
        // dut.inst_decode.registers[13] = 64'h2000; // Initialize x13 (base address for store/load)
        // dut.inst_decode.registers[14] = 64'h3000; // Initialize x14 (not equal to x13)
        // dut.inst_decode.registers[15] = 64'h4000; // Initialize x15 (equal to itself)
        // dut.inst_decode.registers[21] = 64'h0000;
        // Apply reset for 2 clock cycles
        #20
        reset = 0;
        
        // Run simulation for a fixed number of cycles
        #300;  // Run for 300ns (30 clock cycles)
        
        // Display final register values for verification
        $display("\nFinal Register Values:");
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("Register x%0d = %h", i, dut.inst_decode.registers[i]);
        end
        
        $display("\n========== Simulation completed ==========");
        $finish;
    end
    
    // Monitor for instruction execution
    // always @(posedge clk) begin
    //     if (!reset) begin
    //         $display("Time: %0t, PC: %0h, Instr: %0h", $time, PC, instruction_reg);
            
    //         // Debug output for stall and flush signals
    //         $display("Stall: %b, Flush: %b", dut.stall_pipeline, dut.flush_pipeline);
            
    //         // Display pipeline register values
    //         $display("IF/ID Pipeline: PC=%h, opcode=%h, rs1=%d, rs2=%d, rd=%d", 
    //                   dut.PC_out, dut.opcode_out, dut.rs1_out, dut.rs2_out, dut.rd_out);
            
    //         // Display forwarding information
    //         $display("Forwarding: ForwardA=%d, ForwardB=%d", dut.forwardA, dut.forwardB);
    //     end
    // end
endmodule