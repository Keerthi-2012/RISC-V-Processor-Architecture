module forwarding_unit_tb();
    reg [4:0] ID_EX_RegisterRs1;
    reg [4:0] ID_EX_RegisterRs2;
    reg [4:0] EX_MEM_RegisterRd;
    reg [4:0] MEM_WB_RegisterRd;
    reg EX_MEM_RegWrite;
    reg MEM_WB_RegWrite;
    
    wire [1:0] ForwardA;
    wire [1:0] ForwardB;
    
    forwarding_unit dut(
        .ID_EX_RegisterRs1(ID_EX_RegisterRs1),
        .ID_EX_RegisterRs2(ID_EX_RegisterRs2),
        .EX_MEM_RegisterRd(EX_MEM_RegisterRd),
        .MEM_WB_RegisterRd(MEM_WB_RegisterRd),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );
    
    initial begin
        $monitor("Time=%0t, Rs1=%d, Rs2=%d, EX_MEM_Rd=%d, MEM_WB_Rd=%d, EX_MEM_RegWrite=%b, MEM_WB_RegWrite=%b, ForwardA=%b, ForwardB=%b",
                  $time, ID_EX_RegisterRs1, ID_EX_RegisterRs2, EX_MEM_RegisterRd, MEM_WB_RegisterRd,
                  EX_MEM_RegWrite, MEM_WB_RegWrite, ForwardA, ForwardB);
        
        // Test Case 1: No forwarding needed
        ID_EX_RegisterRs1 = 5'd1;
        ID_EX_RegisterRs2 = 5'd2;
        EX_MEM_RegisterRd = 5'd3;
        MEM_WB_RegisterRd = 5'd4;
        EX_MEM_RegWrite = 1'b1;
        MEM_WB_RegWrite = 1'b1;
        #10;
        
        // Test Case 2: Forward from EX/MEM to Rs1
        ID_EX_RegisterRs1 = 5'd3;
        ID_EX_RegisterRs2 = 5'd2;
        EX_MEM_RegisterRd = 5'd3;
        MEM_WB_RegisterRd = 5'd4;
        EX_MEM_RegWrite = 1'b1;
        MEM_WB_RegWrite = 1'b1;
        #10;
        
        // Test Case 3: Forward from EX/MEM to Rs2
        ID_EX_RegisterRs1 = 5'd1;
        ID_EX_RegisterRs2 = 5'd3;
        EX_MEM_RegisterRd = 5'd3;
        MEM_WB_RegisterRd = 5'd4;
        EX_MEM_RegWrite = 1'b1;
        MEM_WB_RegWrite = 1'b1;
        #10;
        
        // Test Case 4: Forward from MEM/WB to Rs1
        ID_EX_RegisterRs1 = 5'd4;
        ID_EX_RegisterRs2 = 5'd2;
        EX_MEM_RegisterRd = 5'd3;
        MEM_WB_RegisterRd = 5'd4;
        EX_MEM_RegWrite = 1'b1;
        MEM_WB_RegWrite = 1'b1;
        #10;
        
        // Test Case 5: Forward from MEM/WB to Rs2
        ID_EX_RegisterRs1 = 5'd1;
        ID_EX_RegisterRs2 = 5'd4;
        EX_MEM_RegisterRd = 5'd3;
        MEM_WB_RegisterRd = 5'd4;
        EX_MEM_RegWrite = 1'b1;
        MEM_WB_RegWrite = 1'b1;
        #10;
        
        // Test Case 6: Forward from EX/MEM has priority over MEM/WB
        ID_EX_RegisterRs1 = 5'd5;
        ID_EX_RegisterRs2 = 5'd2;
        EX_MEM_RegisterRd = 5'd5;
        MEM_WB_RegisterRd = 5'd5;
        EX_MEM_RegWrite = 1'b1;
        MEM_WB_RegWrite = 1'b1;
        #10;
        
        // Test Case 7: No forwarding if RegWrite is disabled
        ID_EX_RegisterRs1 = 5'd6;
        ID_EX_RegisterRs2 = 5'd7;
        EX_MEM_RegisterRd = 5'd6;
        MEM_WB_RegisterRd = 5'd7;
        EX_MEM_RegWrite = 1'b0;
        MEM_WB_RegWrite = 1'b0;
        #10;
        
        // Test Case 8: No forwarding if destination is r0
        ID_EX_RegisterRs1 = 5'd0;
        ID_EX_RegisterRs2 = 5'd0;
        EX_MEM_RegisterRd = 5'd0;
        MEM_WB_RegisterRd = 5'd0;
        EX_MEM_RegWrite = 1'b1;
        MEM_WB_RegWrite = 1'b1;
        #10;

        // Test Case: All Registers Are Equal
ID_EX_RegisterRs1 = 5'd5;
ID_EX_RegisterRs2 = 5'd5;
EX_MEM_RegisterRd = 5'd5;
MEM_WB_RegisterRd = 5'd5;
EX_MEM_RegWrite = 1'b1;
MEM_WB_RegWrite = 1'b1;
#10;

        
        $finish;
    end
endmodule