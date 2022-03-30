import rv32i_types::*;

module control_rom
(
    input [31:0] ID_Instruction,
    input [31:0] ID_PC,
    output rv32i_control_word ctrl
);

always_comb
begin
    /* Default assignments */
    ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
    ctrl.PC = ID_PC;
    ctrl.aluop = alu_add;
    ctrl.alusrc = 1'b0;
    ctrl.RegWrite = 1'b0;
    ctrl.wb = 1'b0;
    ctrl.MEM_BRANCH = 1'b0;
    ctrl.MEM_JAL = 1'b0;
    ctrl.MEM_Read = 1'b0;
    ctrl.MEM_Write = 1'b0;
    ctrl.lui = 1'b0;
    ctrl.auipc = 1'b0;
    ctrl.mbe = 4'hF;

    /* Assign control signals based on opcode */
    case(ctrl.opcode)
        op_auipc: begin
            ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
            ctrl.PC = ID_PC;
            ctrl.aluop = alu_add;
            ctrl.alusrc = 1'b1;
            ctrl.RegWrite = 1'b1;
            ctrl.wb = 1'b0;
            ctrl.MEM_BRANCH = 1'b0;
            ctrl.MEM_Read = 1'b0;
            ctrl.MEM_Write = 1'b0;
            ctrl.lui = 1'b0;
            ctrl.auipc = 1'b1;
            ctrl.mbe = 4'hF;
        end

        op_lui: begin
            ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
            ctrl.PC = ID_PC;
            ctrl.aluop = alu_add;
            ctrl.alusrc = 1'b1;
            ctrl.RegWrite = 1'b1;
            ctrl.wb = 1'b0;
            ctrl.MEM_BRANCH = 1'b0;
            ctrl.MEM_Read = 1'b0;
            ctrl.MEM_Write = 1'b0;
            ctrl.lui = 1'b1;
            ctrl.auipc = 1'b0;
            ctrl.mbe = 4'hF;
        end
        
        op_jal: begin
            ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
            ctrl.PC = ID_PC;
            ctrl.aluop = alu_add;
            ctrl.alusrc = 1'b1;
            ctrl.RegWrite = 1'b1;
            ctrl.wb = 1'b0;
            ctrl.MEM_BRANCH = 1'b0;
            ctrl.MEM_JAL = 1'b1;
            ctrl.MEM_Read = 1'b0;
            ctrl.MEM_Write = 1'b0;
            ctrl.lui = 1'b0;
            ctrl.auipc = 1'b0;
            ctrl.mbe = 4'hF;
        end

        op_jalr: begin
            ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
            ctrl.PC = ID_PC;
            ctrl.aluop = alu_add;
            ctrl.alusrc = 1'b1;
            ctrl.RegWrite = 1'b1;
            ctrl.wb = 1'b0;
            ctrl.MEM_BRANCH = 1'b0;
            ctrl.MEM_JAL = 1'b1;
            ctrl.MEM_Read = 1'b0;
            ctrl.MEM_Write = 1'b0;
            ctrl.lui = 1'b0;
            ctrl.auipc = 1'b0;
            ctrl.mbe = 4'hF;
        end
        
        op_br: begin
            ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
            ctrl.PC = ID_PC;
            ctrl.aluop = alu_add;
            ctrl.alusrc = 1'b0;
            ctrl.RegWrite = 1'b0;
            ctrl.wb = 1'b0;
            ctrl.MEM_BRANCH = 1'b1;
            ctrl.MEM_Read = 1'b0;
            ctrl.MEM_Write = 1'b0;
            ctrl.lui = 1'b0;
            ctrl.auipc = 1'b0;
            ctrl.mbe = 4'hF;
        end

        op_load: begin
            ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
            ctrl.PC = ID_PC;
            ctrl.aluop = alu_add;
            ctrl.alusrc = 1'b1;
            ctrl.RegWrite = 1'b1;
            ctrl.wb = 1'b1;
            ctrl.MEM_BRANCH = 1'b0;
            ctrl.MEM_Read = 1'b1;
            ctrl.MEM_Write = 1'b0;
            ctrl.lui = 1'b0;
            ctrl.auipc = 1'b0;
            case (load_funct3_t'(ID_Instruction[14:12]))
                lb: ctrl.mbe = 4'b0001;
                lh: ctrl.mbe = 4'b0011;
                lw: ctrl.mbe = 4'hF;
                lbu: ctrl.mbe = 4'b1000;
                lhu: ctrl.mbe = 4'b1100;
                default: ctrl.mbe = 4'b0000;
            endcase
        end

        op_store: begin
            ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
            ctrl.PC = ID_PC;
            ctrl.aluop = alu_add;
            ctrl.alusrc = 1'b1;
            ctrl.RegWrite = 1'b0;
            ctrl.wb = 1'b0;
            ctrl.MEM_BRANCH = 1'b0;
            ctrl.MEM_Read = 1'b0;
            ctrl.MEM_Write = 1'b1;
            ctrl.lui = 1'b0;
            ctrl.auipc = 1'b0;
            case (store_funct3_t'(ID_Instruction[14:12]))
                sb: ctrl.mbe = 4'b0001;
                sh: ctrl.mbe = 4'b0011;
                sw: ctrl.mbe = 4'hF;
                default: ctrl.mbe = 4'b0;
            endcase
        end

        op_imm: begin
            ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
            ctrl.PC = ID_PC;

            if (arith_funct3_t'(ID_Instruction[14:12]) == add) begin
                if (ID_Instruction[30])
                    ctrl.aluop = alu_sub;
                else
                    ctrl.aluop = alu_add;
            end
            else 
                ctrl.aluop = alu_ops'({1'b0, ID_Instruction[14:12]});

            ctrl.aluop = alu_ops'(ID_Instruction[14:12]);
            ctrl.alusrc = 1'b1;
            ctrl.RegWrite = 1'b1;
            ctrl.wb = 1'b0;
            ctrl.MEM_BRANCH = 1'b0;
            ctrl.MEM_Read = 1'b0;
            ctrl.MEM_Write = 1'b0;
            ctrl.lui = 1'b0;
            ctrl.auipc = 1'b0;
            ctrl.mbe = 4'hF;
        end
        
        op_reg: begin
            ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
            ctrl.PC = ID_PC;

            if (ID_Instruction[25]) begin
                ctrl.aluop = alu_mul;
            end
            else if (arith_funct3_t'(ID_Instruction[14:12]) == sr) begin
                if (~ID_Instruction[31:25])
                    ctrl.aluop = alu_srl;
                else
                    ctrl.aluop = alu_sra;
            end
            else if (arith_funct3_t'(ID_Instruction[14:12]) == add) begin
                if (ID_Instruction[30])
                    ctrl.aluop = alu_sub;
                else
                    ctrl.aluop = alu_add;
            end
            else 
                ctrl.aluop = alu_ops'({1'b0, ID_Instruction[14:12]});

            ctrl.alusrc = 1'b0;
            ctrl.RegWrite = 1'b1;
            ctrl.wb = 1'b0;
            ctrl.MEM_BRANCH = 1'b0;
            ctrl.MEM_Read = 1'b0;
            ctrl.MEM_Write = 1'b0;
            ctrl.lui = 1'b0;
            ctrl.auipc = 1'b0;
            ctrl.mbe = 4'hF;
        end

        op_csr: begin
            ctrl.opcode = rv32i_opcode'(ID_Instruction[6:0]);
            ctrl.PC = ID_PC;
            ctrl.aluop = alu_add;
            ctrl.alusrc = 1'b1;
            ctrl.RegWrite = 1'b1;
            ctrl.wb = 1'b0;
            ctrl.MEM_BRANCH = 1'b0;
            ctrl.MEM_Read = 1'b0;
            ctrl.MEM_Write = 1'b0;
            ctrl.lui = 1'b0;
            ctrl.auipc = 1'b0;
            ctrl.mbe = 4'hF;
        end

        default: begin
            ctrl = 0;   /* Unknown opcode, set control word to zero */
        end
    endcase
end
endmodule : control_rom