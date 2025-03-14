module forwarding_unit(
    input [4:0] ID_EX_RegisterRs1,
    input [4:0] ID_EX_RegisterRs2,
    input [4:0] EX_MEM_RegisterRd,
    input [4:0] MEM_WB_RegisterRd,
    
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;
        
        if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && 
            (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) begin
            ForwardA = 2'b10;
        end
        
        if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && 
            (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) begin
            ForwardB = 2'b10;
        end
        
        if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && 
            !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) &&
            (MEM_WB_RegisterRd == ID_EX_RegisterRs1)) begin
            ForwardA = 2'b01;
        end
        
        if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && 
            !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) &&
            (MEM_WB_RegisterRd == ID_EX_RegisterRs2)) begin
            ForwardB = 2'b01;
        end
    end
endmodule