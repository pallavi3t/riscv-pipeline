import rv32i_types::*;

module WB
(
    input clk,
    input rst,
    
    input [31:0] WB_RESULT,
    input [31:0] WB_Read_Data,
    input rv32i_control_word WB_control,
    input [31:0] WB_lui,
    input [31:0] WB_auipc,

    output [31:0] WB_mux_out
);

    logic [31:0] WB_mux_imm_out;

    mux3to1 #(.width(32)) mux_imm(
        .out(WB_mux_imm_out), 
        .sel({WB_control.auipc, WB_control.lui}),
        .a(WB_RESULT),
        .b(WB_lui),
        .c(WB_auipc)
    );

    mux2to1 #(.width(32)) mux(
        .out(WB_mux_out), 
        .sel(WB_control.wb),
        .a(WB_mux_imm_out),
        .b(WB_Read_Data)
    );

endmodule : WB
