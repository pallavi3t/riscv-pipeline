import rv32i_types::*;

module ID
(
    input clk,
    input rst,

    input [31:0] ID_PC,
    input [31:0] ID_Instruction,
    input [31:0] WB_mux_out,
    input [4:0] EX_RD,
    input [4:0] MEM_RD,
    input [4:0] WB_RD,
    input [4:0] EX_RS1,
    input [4:0] EX_RS2,
    input rv32i_control_word EX_control,
    input rv32i_control_word MEM_control,
    input rv32i_control_word WB_control,
    input IF_resp,
    input MEM_resp,
    input EX_ALU_resp,
    input PCSrc,
    
    output [4:0] ID_RS1,
    output [4:0] ID_RS2,
    output [4:0] ID_RD,
    output [31:0] ID_Read_Data1,
    output [31:0] ID_Read_Data2,
    output [31:0] ID_imm,
    output [3:0] ID_funct,
    output rv32i_control_word ID_control,
    output PCWrite,
    output if_id_write
);

    /* Internal signals */
    rv32i_control_word control_out;
    logic HDU_out;
    logic [31:0] imm;
    logic [31:0] Instruction;

    assign Instruction = ID_Instruction;
    assign ID_RS1 = Instruction[19:15];
    assign ID_RS2 = Instruction[24:20];
    assign ID_RD = Instruction[11:7];
    assign ID_funct = {Instruction[30], Instruction[14:12]};
    assign ID_imm = imm;

    /* Modules */
    control_rom control(
        .ID_Instruction(ID_Instruction),
        .ID_PC(ID_PC),
        .ctrl(control_out)
    );

    mux2to1 #(.width($size(rv32i_control_word))) control_mux(
        .out(ID_control),
        .sel(HDU_out),
        .a({$size(rv32i_control_word){1'b0}}),
        .b(control_out)
    );

    regfile regfile(
        .clk,
        .rst,
        .load(WB_control.RegWrite),
        .in(WB_mux_out),
        .src_a(ID_RS1), 
        .src_b(ID_RS2), 
        .dest(WB_RD),
        .reg_a(ID_Read_Data1), 
        .reg_b(ID_Read_Data2)
    );

    // hazard detection unit (HDU)
    hdu hdu(
        .*
    );

    always_comb begin : imm_gen
        // Finds the right immediate based off of the opcode
        case (rv32i_opcode'(Instruction[6:0]))
            op_lui: imm = {Instruction[31:12], 12'h000};
            op_auipc: imm = {Instruction[31:12], 12'h000};
            op_jal: imm = {{12{Instruction[31]}}, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
            op_jalr: imm = {{21{Instruction[31]}}, Instruction[30:20]};
            op_br: imm = {{20{Instruction[31]}}, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
            op_load: imm = {{21{Instruction[31]}}, Instruction[30:20]};
            op_store: imm = {{21{Instruction[31]}}, Instruction[30:25], Instruction[11:7]};
            op_imm: imm = {{21{Instruction[31]}}, Instruction[30:20]};
            op_reg: imm = 32'b0;
            op_csr: imm = {{21{Instruction[31]}}, Instruction[30:20]};
            default: imm = 32'b0;
        endcase
    end

endmodule : ID
