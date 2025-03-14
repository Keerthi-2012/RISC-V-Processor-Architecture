`timescale 1ns / 1ps


`include "adder.v"
`include "sub.v"
`include "and.v"
`include "or.v"
`include "xor.v"
`include "slt.v"
`include "sltu.v"
`include "sll.v"
`include "srl.v"
`include "sra.v"

module ALU (
    input [3:0] control,  
    input signed [63:0] A,       
    input signed [63:0] B,  
    input [63:0] C,
    input [63:0] D,    
    output reg signed [63:0] result,
    output reg carry_alu,
    output reg overflow_alu,
    output reg single 
);

    wire [63:0] add_result, sub_result, and_result, or_result, xor_result;
    wire [63:0]  sll_result, srl_result, sra_result;
    wire add_carry, add_overflow;
    wire sub_borrow, sub_overflow;
    wire slt_result, sltu_result;

    
    bit64_adder add_inst (.a(A), .b(B), .sum(add_result), .carry(add_carry), .overflow(add_overflow));
    bit64_subtractor sub_inst (.a(A), .b(B), .difference(sub_result), .borrow(sub_borrow),.overflow(sub_overflow));
    and_gate and_inst (.x(A), .y(B), .final(and_result));
    or_gate or_inst (.x(A), .y(B), .final(or_result));
    xor_gate xor_inst (.x(A), .y(B), .final(xor_result));
    compare_bitwise_64_signed slt_inst (.rs1(A), .rs2(B), .result(slt_result));
    compare_bitwise_64 sltu_inst (.rs1(C), .rs2(D), .result(sltu_result));
    shift_sll sll_inst (.a(A), .n(B[5:0]), .result(sll_result)); 
    shift_srl srl_inst (.a(A), .n(B[5:0]), .result(srl_result));  
    shift_sra sra_inst (.a(A), .n(B[5:0]), .result(sra_result));  

   
    always @(*) begin
        case (control)
            4'b0010: //ADD
            begin
                result <= add_result;
                carry_alu <= add_carry;
                overflow_alu <= add_overflow;
                single <= 1'bx;
            end
            4'b0110:  // SUB   
            begin
                result <= sub_result;
                carry_alu <= sub_borrow;
                overflow_alu <= sub_overflow;
                single <= 1'bx;
            end
            4'b1000:  // SLL  
            begin
                result <= sll_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                single <= 1'bx;
            end 
            4'b0111:   // SLT
            begin
                result <= 1'bx;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                single <= slt_result;
            end 
            4'b0011: // SLTU
            begin
                result <= 1'bx;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                single <= sltu_result;
            end 
            4'b0100:   // XOR
            begin
                result <= xor_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                single <= 1'bx;
            end
            4'b0101:   // SRL
            begin
                result <= srl_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                single <= 1'bx;
            end 
            4'b1101:  // SRA
            begin
                result <= sra_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                single <= 1'bx;
            end 
            4'b0001:  // OR    
            begin
                result <= or_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                single <= 1'bx;
            end
            4'b0000:   // AND
            begin
                result <= and_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                single <= 1'bx;
            end 
             default: // DEFAULT CASE
            begin
                result <= 64'hx;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                single <= 1'bx;
            end 
        endcase
    end

endmodule







