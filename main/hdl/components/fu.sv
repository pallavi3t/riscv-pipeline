import rv32i_types::*;

module fu (

    input clk, 
    input rst,
    input rv32i_control_word MEM_control,
    input rv32i_control_word WB_control,
    input [4:0] EX_RS1,
    input [4:0] EX_RS2,
    input [4:0] MEM_RD,
    input [4:0] WB_RD,
    output logic [1:0] ForwardA,
    output logic [1:0] ForwardB

);

always_comb begin : forwardA_logic 
    if (WB_control.RegWrite && WB_RD && WB_RD == EX_RS1 && !(MEM_control.RegWrite && MEM_RD && MEM_RD == EX_RS1)) 
        ForwardA = 2'b10;
    else if (MEM_control.RegWrite && MEM_RD && MEM_RD == EX_RS1) 
        ForwardA = 2'b01;
    else 
        ForwardA = 2'b00;
end

always_comb begin: forwardB_logic
    if (WB_control.RegWrite && WB_RD && WB_RD == EX_RS2 && !(MEM_control.RegWrite && MEM_RD && MEM_RD == EX_RS2)) 
        ForwardB = 2'b01; 
    else if (MEM_control.RegWrite && MEM_RD && MEM_RD == EX_RS2) 
        ForwardB = 2'b10;
    else 
        ForwardB = 2'b00;
end

endmodule : fu