import rv32i_types::*;

module hdu (
    input clk,
    input rst,
    input rv32i_control_word EX_control,
    input rv32i_control_word MEM_control,
    input rv32i_control_word WB_control,
    input [4:0] EX_RD,
    input [4:0] ID_RS1,
    input [4:0] ID_RS2,
    input [4:0] EX_RS1,
    input [4:0] EX_RS2,
    input [4:0] WB_RD,
    input [4:0] MEM_RD,
    input IF_resp,
    input MEM_resp,
    input EX_ALU_resp,
    input PCSrc,
    output PCWrite,
    output HDU_out,
    output if_id_write
);  

/* 
Load-use hazard when
◦ ID/EX.MemRead and
((ID/EX.RegisterRd = IF/ID.RegisterRs1) or
(ID/EX.RegisterRd = IF/ID.RegisterRs2))
*/

    assign PCWrite = (!(WB_control.MEM_JAL & WB_RD & (WB_RD == ID_RS1)) & !(WB_control.RegWrite & WB_RD & (WB_RD == ID_RS1 | WB_RD == ID_RS2)) &
        !(EX_control.MEM_Read & ((EX_RD == ID_RS1) | (EX_RD == ID_RS2))) & IF_resp & MEM_resp & EX_ALU_resp) | PCSrc;
    /* & IF_resp & MEM_resp &
        //(!(WB_control.RegWrite & WB_RD & (WB_RD == ID_RS1 | WB_RD == ID_RS2))  
        & !(WB_control.RegWrite & WB_RD & (WB_RD == EX_RS1 | WB_RD == EX_RS2)) & 
        !(MEM_control.RegWrite & MEM_RD & (MEM_RD == EX_RS1 | MEM_RD == EX_RS2));*/
    assign HDU_out = PCWrite;
    assign if_id_write = PCWrite;

endmodule : hdu
