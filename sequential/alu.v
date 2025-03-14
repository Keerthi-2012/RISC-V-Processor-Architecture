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
    input [6:0] funct7,  
    input [2:0] funct3,  
    input [6:0] opcode,  
    input signed [63:0] A,       
    input signed [63:0] B, 
    input [11:0] addr,
   
    output reg signed [63:0] result,
    output reg carry_alu,
    output reg overflow_alu,
    output reg zero_flag
   
);





    wire [63:0] add_result, sub_result, and_result, or_result, xor_result;
    wire [63:0]  sll_result, srl_result, sra_result, mem_result;
    wire add_carry, add_overflow;
    wire sub_borrow, sub_overflow;
    wire [63:0] slt_result, sltu_result;
    wire add_err;
   
    wire carry_out, overflow_flag;
    wire [63:0] address;

wire carry_outi, overflow_flagi;
    wire [63:0] addressi;


    
    bit64_adder add_inst (.a(A), .b(B), .sum(add_result), .carry(add_carry), .overflow(add_overflow));
    bit64_subtractor sub_inst (.a(A), .b(B), .difference(sub_result), .borrow(sub_borrow),.overflow(sub_overflow));
    and_gate and_inst (.x(A), .y(B), .final(and_result));
    or_gate or_inst (.x(A), .y(B), .final(or_result));
    xor_gate xor_inst (.x(A), .y(B), .final(xor_result));
    compare_bitwise_64_signed slt_inst (.rs1(A), .rs2(B), .result(slt_result));
    compare_bitwise_64 sltu_inst (.rs1($unsigned(A)), .rs2($unsigned(B)), .result(sltu_result));
    shift_sll sll_inst (.a(A), .n(B[5:0]), .result(sll_result)); 
    shift_srl srl_inst (.a(A), .n(B[5:0]), .result(srl_result));  
    shift_sra sra_inst (.a(A), .n(B[5:0]), .result(sra_result));  
   
bit64_adder addr_adder_inst (
    .a($unsigned(A)), 
    .b({{52{addr[11]}}, addr}), 
    .sum(address),
    .carry(carry_out),
    .overflow(overflow_flag)
);
    bit64_adder addr_adderimm_inst (
        .a(A), 
        .b({{52{addr[11]}}, addr}), 
        .sum(addressi),
        .carry(carry_outi),
        .overflow(overflow_flagi)
    );

    bit64_subtractor beq_inst (.a(A), .b(B), .difference(sub_result), .borrow(sub_borrow),.overflow(sub_overflow));

    


   
    always @(*) begin
        
        case ({opcode, funct3, funct7})
           //ADD
            {7'b0110011, 3'b000, 7'b0000000}:begin
                result <= add_result;
                carry_alu <= add_carry;
                overflow_alu <= add_overflow;
                zero_flag <= 1'bx;

            end
           // SUB   
            {7'b0110011, 3'b000, 7'b0100000}: begin
                result <= sub_result;
                carry_alu <= sub_borrow;
                overflow_alu <= sub_overflow;
                zero_flag <= 1'bx;

               // if (sub_result == 64'd0) 
                  //  zero_flag <= 1'b1;
            end
            {7'b0110011, 3'b001, 7'b0000000}:  // SLL  
            begin
                result <= sll_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                zero_flag <= 1'bx;

            end 

            {7'b0110011, 3'b010, 7'b0000000}: begin   // SLT
            
                result <= slt_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                zero_flag <= 1'bx;

            end 
            {7'b0110011, 3'b011, 7'b0000000}:// SLTU
            begin
                result <= sltu_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;

            end 
            {7'b0110011, 3'b100, 7'b0000000}:   // XOR
            begin
                result <= xor_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                zero_flag <= 1'bx;

            end
            {7'b0110011, 3'b101, 7'b0000000}:   // SRL
            begin
                result <= srl_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
            end 
            {7'b0110011, 3'b101, 7'b0100000}:  // SRA
            begin
                result <= sra_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                zero_flag <= 1'bx;
            end 
          
            {7'b0110011, 3'b111, 7'b0000000}:  // AND
            begin
                result <= and_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                zero_flag <= 1'bx;
            end 
            {7'b0110011, 3'b110, 7'b0000000}:  // OR    
            begin
                result <= or_result;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                zero_flag <= 1'bx;
            end

            {7'b0000011, 3'b011, 7'b0000000}:  // LOAD   (add)
            begin
                result <= address;
                zero_flag <= 1'bx;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;

            end 

            {7'b0100011, 3'b011, 7'b0000000}:  // store  
            begin
                result <= address;
                zero_flag <= 1'bx;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
            end

            {7'b1100011, 3'b000, 7'b0000000}: //Beq
            begin
                result <= 64'bx;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                
                if (sub_result == 64'd0) 
                    zero_flag <= 1'b1; 
                else 
                    zero_flag <= 1'b0;
               
                  
            end

            {7'b0010011, 3'b000, 7'b0000000}:  // addi   (add)
            begin
                result <= addressi;
                zero_flag <= 1'bx;

            end 


            

             default: // DEFAULT CASE
            begin
                result <= 64'hx;
                carry_alu <= 1'bx;
                overflow_alu <= 1'bx;
                zero_flag <= 1'bx;
            end 
        endcase
    end

endmodule







