import rv32i_types::*;

module EX
(
    input clk,
    input rst,

    input [31:0] EX_PC,
    input [31:0] EX_Read_Data1,
    input [31:0] EX_Read_Data2,
    input [31:0] EX_imm,
    input [3:0] EX_funct,
    input [4:0] EX_RS1,
    input [4:0] EX_RS2,
    input [4:0] MEM_RD,
    input [4:0] WB_RD,
    input [31:0] MEM_RESULT,
    input [31:0] WB_mux_out,
    input rv32i_control_word EX_control,
    input rv32i_control_word MEM_control,
    input rv32i_control_word WB_control,
    input [4:0] EX_RD,
    input [31:0] MEM_Forward,

    output [31:0] EX_ADD,
    output EX_ZERO,
    output [31:0] EX_RESULT,
    output [31:0] EX_ALU_IN1,
    output [31:0] EX_ALU_IN2,
    output logic EX_ALU_resp
);

    /* Internal signals */
    logic [31:0] forward_mux_a_out;
    logic [31:0] forward_mux_b_out;
    logic [1:0] ForwardA;
    logic [1:0] ForwardB;
    logic [31:0] alu_mux_out;
    logic branch_alu_done;
    logic [31:0] alu_branch_mux_out;
    logic jal_alu_done;
    logic [31:0] alu_jal_mux_out;
    logic [31:0] alu_out;
    logic [31:0] target_branch_addr;

    assign EX_ZERO = (EX_RESULT == 0) ? 1'b1 : 1'b0;
    assign EX_ALU_IN2 = forward_mux_b_out;
    assign EX_ALU_IN1 = forward_mux_a_out;
    assign EX_ADD = (EX_control.opcode == op_jalr) ? {target_branch_addr[31:1], 1'b0} : target_branch_addr;

    mux3to1 #(.width(32)) forward_mux_a(
        .out(forward_mux_a_out),
        .sel(ForwardA),
        .a(EX_Read_Data1),
        .b(MEM_Forward),
        .c(WB_mux_out)
    );

    mux3to1 #(.width(32)) forward_mux_b(
        .out(forward_mux_b_out),
        .sel(ForwardB),
        .a(EX_Read_Data2),
        .b(WB_mux_out),
        .c(MEM_Forward)
    );
    
    mux2to1 #(.width(32)) alu_mux(
        .out(alu_mux_out),
        .sel(EX_control.alusrc),
        .a(forward_mux_b_out),
        .b(EX_imm)
    );

    mux2to1 #(.width(32)) alu_branch_mux(
        .out(alu_branch_mux_out),
        .sel(EX_control.opcode == op_jalr),
        .a(EX_PC),
        .b(forward_mux_a_out)
    );
    
    alu alu_branch(
        .aluop(alu_add), 
        .a(EX_imm), 
        .b(alu_branch_mux_out), 
        .f(target_branch_addr),
        .funct3(EX_funct[2:0]),
        .done(branch_alu_done),
        .*
    );

    alu alu_jal(
        .aluop(alu_add), 
        .a(4), 
        .b(EX_PC), 
        .f(alu_jal_mux_out),
        .funct3(EX_funct[2:0]),
        .done(jal_alu_done),
        .*
    );
    
    alu alu(
        .aluop(EX_control.aluop),
        .a(forward_mux_a_out),
        .b(alu_mux_out),
        .f(alu_out),
        .funct3(EX_funct[2:0]),
        .done(EX_ALU_resp),
        .*
    );

    mux2to1 #(.width(32)) alu_out_mux(
        .out(EX_RESULT),
        .sel(EX_control.MEM_JAL),
        .a(alu_out),
        .b(alu_jal_mux_out)
    );

    // Forwarding Unit
    fu fu (
        .*
    );


endmodule : EX
