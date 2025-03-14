module hazard_detection_unit (
    input wire [4:0] IF_ID_RegisterRs1,
    input wire [4:0] IF_ID_RegisterRs2,
    input wire [4:0] ID_EX_RegisterRd,
    input wire ID_EX_MemRead,
    output reg stall
);

always @(*) begin
    if (ID_EX_MemRead && ((ID_EX_RegisterRd == IF_ID_RegisterRs1) || (ID_EX_RegisterRd == IF_ID_RegisterRs2))) begin
        stall = 1'b1;
    end else begin
        stall = 1'b0;
    end
end

endmodule