import rv32i_types::*;

module if_id_register(
    input clk,
    input rst,
    input if_id_load,
    
    input [31:0] IF_Instruction,
    input [31:0] IF_PC,

    output [31:0] ID_Instruction,
    output [31:0] ID_PC
);
    register #(.width(32)) instruction_reg(
        .load(if_id_load),
        .in(IF_Instruction),
        .out(ID_Instruction),
        .*
    );
    
    register #(.width(32)) pc_reg(
        .load(if_id_load),
        .in(IF_PC),
        .out(ID_PC),
        .*
    );

endmodule : if_id_register

module id_ex_register(
    input clk,
    input rst,
    input id_ex_load,
    
    input rv32i_control_word ID_control,
    input [31:0] ID_PC,
    input [4:0] ID_RS1,
    input [4:0] ID_RS2,
    input [31:0] ID_Read_Data1,
    input [31:0] ID_Read_Data2,
    input [31:0] ID_imm,
    input [3:0] ID_funct,
    input [4:0] ID_RD,
    
    output rv32i_control_word EX_control,
    output [31:0] EX_PC,
    output [4:0] EX_RS1,
    output [4:0] EX_RS2,
    output [31:0] EX_Read_Data1,
    output [31:0] EX_Read_Data2,
    output [31:0] EX_imm,
    output [3:0] EX_funct,
    output [4:0] EX_RD
);
    register #(.width($size(rv32i_control_word))) control_reg(
        .load(id_ex_load),
        .in(ID_control),
        .out(EX_control),
        .*
    );
    
    register #(.width(32)) pc_reg(
        .load(id_ex_load),
        .in(ID_PC),
        .out(EX_PC),
        .*
    );
    
    register #(.width(5)) rs1_reg(
        .load(id_ex_load),
        .in(ID_RS1),
        .out(EX_RS1),
        .*
    );
    
    register #(.width(5)) rs2_reg(
        .load(id_ex_load),
        .in(ID_RS2),
        .out(EX_RS2),
        .*
    );
    
    register #(.width(5)) rd_reg(
        .load(id_ex_load),
        .in(ID_RD),
        .out(EX_RD),
        .*
    );

    register #(.width(32)) read_data1_reg(
        .load(id_ex_load),
        .in(ID_Read_Data1),
        .out(EX_Read_Data1),
        .*
    );
    
    register #(.width(32)) read_data2_reg(
        .load(id_ex_load),
        .in(ID_Read_Data2),
        .out(EX_Read_Data2),
        .*
    );

    register #(.width(32)) imm_reg(
        .load(id_ex_load),
        .in(ID_imm),
        .out(EX_imm),
        .*
    );
    
    register #(.width(4)) funct_reg(
        .load(id_ex_load),
        .in(ID_funct),
        .out(EX_funct),
        .*
    );

endmodule : id_ex_register

module ex_mem_register(
    input clk,
    input rst,
    input ex_mem_load,    
    
    input rv32i_control_word EX_control, 
    output rv32i_control_word MEM_control,
    
    input [4:0] EX_RD,
    input [31:0]EX_ADD,
    input EX_ZERO,
    input [31:0] EX_RESULT,
    input [31:0] EX_ALU_IN1,
    input [31:0] EX_ALU_IN2,
    input [31:0] EX_imm,
    input [3:0] EX_funct,
    input [4:0] EX_RS1,
    input [4:0] EX_RS2,
    input [31:0] EX_Read_Data2,
    
    output [31:0] MEM_Read_Data2,
    output [4:0] MEM_RS1,
    output [4:0] MEM_RS2,
    output [3:0] MEM_funct,
    output [31:0] MEM_lui,
    output [31:0] MEM_ADD,
    output MEM_ZERO,
    output [31:0] MEM_RESULT,
    output [31:0] MEM_ALU_IN1,
    output [31:0] MEM_ALU_IN2,
    output [4:0] MEM_RD
);
    register #(.width($size(rv32i_control_word))) control_reg(
        .load(ex_mem_load),
        .in(EX_control),
        .out(MEM_control),
        .*
    );

    register #(.width(5)) rd_reg(
        .load(ex_mem_load),
        .in(EX_RD),
        .out(MEM_RD),
        .*        
    );
    
    register #(.width(32)) add_reg(
        .load(ex_mem_load),
        .in(EX_ADD),
        .out(MEM_ADD),
        .* 
    );

    register #(.width(1)) zero_reg(
        .load(ex_mem_load),
        .in(EX_ZERO),
        .out(MEM_ZERO),
        .* 
    );
    
    register #(.width(32)) result_reg(
        .load(ex_mem_load),
        .in(EX_RESULT),
        .out(MEM_RESULT),
        .* 
    );

    register #(.width(32)) alu_in1_reg(
        .load(ex_mem_load),
        .in(EX_ALU_IN1),
        .out(MEM_ALU_IN1), 
        .*
    );

    register #(.width(32)) alu_in2_reg(
        .load(ex_mem_load),
        .in(EX_ALU_IN2),
        .out(MEM_ALU_IN2), 
        .*
    );

    register #(.width(32)) lui_reg(
        .load(ex_mem_load),
        .in(EX_imm),
        .out(MEM_lui),
        .*
    );

    register #(.width(4)) funct_reg(
        .load(ex_mem_load),
        .in(EX_funct),
        .out(MEM_funct),
        .*
    );

    register #(.width(5)) rs1_reg(
        .load(ex_mem_load),
        .in(EX_RS1),
        .out(MEM_RS1),
        .*
    );
    
    register #(.width(5)) rs2_reg(
        .load(ex_mem_load),
        .in(EX_RS2),
        .out(MEM_RS2),
        .*
    );

    register #(.width(32)) read_data2_reg(
        .load(ex_mem_load),
        .in(EX_Read_Data2),
        .out(MEM_Read_Data2),
        .*
    );    
    
endmodule : ex_mem_register

module mem_wb_register(
    input clk,
    input rst,
    input mem_wb_load,

    input rv32i_control_word MEM_control,
    input [31:0] MEM_RESULT,
    input [31:0] MEM_Read_Data,
    input [4:0] MEM_RD,
    input [31:0] MEM_lui,
    input [31:0] MEM_ADD,
    
    output [31:0] WB_auipc,
    output [31:0] WB_lui,
    output rv32i_control_word WB_control,
    output [31:0] WB_RESULT,
    output [31:0] WB_Read_Data,
    output [4:0] WB_RD   
);
    register #(.width($size(rv32i_control_word))) control_reg(
        .load(mem_wb_load),
        .in(MEM_control),
        .out(WB_control),
        .*
    );
    
    register #(.width(32)) result_reg(
        .load(mem_wb_load),
        .in(MEM_RESULT),
        .out(WB_RESULT),
        .*
    );
    
    register #(.width(32)) read_data_reg(
        .load(mem_wb_load),
        .in(MEM_Read_Data),
        .out(WB_Read_Data),
        .*
    );

    register #(.width(5)) rd_reg(
        .load(mem_wb_load),
        .in(MEM_RD),
        .out(WB_RD),
        .*        
    );

    register #(.width(32)) lui_reg(
        .load(mem_wb_load),
        .in(MEM_lui),
        .out(WB_lui),
        .*
    );

    register #(.width(32)) add_reg(
        .load(mem_wb_load),
        .in(MEM_ADD),
        .out(WB_auipc),
        .* 
    );

endmodule: mem_wb_register