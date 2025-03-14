`timescale 1ns / 1ps

module riscv_ld_sd_tb();
    // Inputs
    reg clk;
    reg reset;
    
    // Signals for load/store testing
    reg [63:0] rs1;       // Base address register
    reg [63:0] rs2;       // Source/destination register
    reg [6:0] op;         // Opcode
    reg [6:0] f7;         // Funct7
    reg [2:0] f3;         // Funct3
    reg [11:0] imm12;     // Immediate offset
    reg memread;
    reg [63:0] addr;
    reg memwrite;
    reg mem2reg;
    reg [63:0] alures;    // Effective address

    // Outputs
    wire [63:0] rd;
    wire address_error;

    // Instantiate the Unit Under Test (UUT)
    pipe_mem uut (
        .rs1(rs1),
        .rs2(rs2),
        .op(op),
        .f7(f7),
        .f3(f3),
        .imm12(imm12),
        .clk(clk),
        .memread(memread),
        .addr(addr),
        .memwrite(memwrite),
        .mem2reg(mem2reg),
        .alures(alures),
        .rd(rd),
        .address_error(address_error)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        rs1 = 0;
        rs2 = 0;
        op = 0;
        f7 = 0;
        f3 = 0;
        imm12 = 0;
        memread = 0;
        memwrite = 0;
        mem2reg = 0;
        alures = 0; 
        addr = 0;

        // Wait 100 ns for global reset
        #100;

        // Test Case 1: Store Multiple Values
        $display("\n--- TEST CASE 1: STORE OPERATIONS ---");
        
        // First Store Operation (64-bit Double Word)
        op = 7'b0100011;  // Store type instruction (SD)
        f3 = 3'b011;      // Double word store
        f7 = 7'b0000000;
        
        // Store first value
        rs1 = 64'd13;  // Base address
        rs2 = 64'd11;  // Value to store
        imm12 = 12'd2;    
        addr = 64'd15;            // Offset
        
        // Explicitly calculate effective address
        alures = rs1 + {{52{imm12[11]}}, imm12};
        
        memwrite = 1;
        memread = 0;
        $display("Store 1: Address = %d, Value = %0h", addr, rs2);
        #10;

        // Second Store Operation
        rs1 = 64'h0000_0000_0000_2000;  // New base address
        rs2 = 64'hABCD_1234_5678_9ABC;  // Another value to store
        imm12 = 12'h008;   
        addr = 64'd8;                 // Different offset
        
        // Explicitly calculate effective address
        alures = rs1 + {{52{imm12[11]}}, imm12};
        
        $display("Store 2: Address = %d, Value = %0h", addr, rs2);
        #10;
        memwrite = 0;

        // Test Case 2: Load Stored Values
        $display("\n--- TEST CASE 2: LOAD OPERATIONS ---");
        
        // Prepare for first load
        op = 7'b0000011;  // Load type instruction (LD)
        f3 = 3'b011;      // Double word load
        memread = 1;
        memwrite = 0;
        
        // First Load Operation
        rs1 = 64'h0000_0000_0000_1000;  // Base address
        imm12 = 12'h004; 
        addr = 64'd4; 
                       // Offset
        
        // Explicitly calculate effective address
        alures = rs1 + {{52{imm12[11]}}, imm12};
        
        $display("Load 1: Address = %0h", addr);
        #10;
        $display("Loaded Value 1: %0h", rd);

        // Second Load Operation
        rs1 = 64'h0000_0000_0000_2000;  // New base address
        imm12 = 12'h008; 
        addr = 64'd8;                // Different offset
        
        // Explicitly calculate effective address
        alures = rs1 + {{52{imm12[11]}}, imm12};
        
        $display("Load 2: Address = %0h", addr);
        #10;
        $display("Loaded Value 2: %0h", rd);

        // Finish simulation
        #10 $finish;
    end

    // Optional: Waveform dump for GTKWave
    initial begin
        $dumpfile("riscv_ld_sd_tb.vcd");
        $dumpvars(0, riscv_ld_sd_tb);
    end
endmodule