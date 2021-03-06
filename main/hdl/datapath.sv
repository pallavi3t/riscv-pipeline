import rv32i_types::*;

module datapath 
#(
    parameter l2_cache = 1'b1,
    parameter cache_cycle = 1,
    parameter enable_prefetching = 1'b1,
    parameter enable_ewb = 1'b1
)
(
    input clk,
    input rst,

    // I Cache
    input logic pmem_iresp,
    input logic [255:0] pmem_irdata,
    output logic [31:0] pmem_iaddress,
    output logic [255:0] pmem_iwdata,
    output logic pmem_iread,
    output logic pmem_iwrite,

    // D Cache
    input logic pmem_dresp,
    input logic [255:0] pmem_drdata,
    output logic [3:0] pmem_dmbe,
    output logic [31:0] pmem_daddress,
    output logic [255:0] pmem_dwdata,
    output logic pmem_dread,
    output logic pmem_dwrite,
    output logic d_miss
);

    /* Internal signals */
    // Internal signals: Global
    logic IF_resp;
    logic MEM_resp;
    logic EX_ALU_resp;
    logic stage_register_reset;
    logic PCSrc;
    logic PCWrite;
    logic [31:0] clock_cycle_count;
    logic [31:0] cache_stall_count;

    assign stage_register_reset = rst | PCSrc;

    // Internal signals: IF Stage
    logic [31:0] IF_PC;
    logic [31:0] IF_Instruction;
    logic if_id_load;
    logic if_id_write;

    assign if_id_load = ~stage_register_reset & if_id_write & IF_resp & MEM_resp & EX_ALU_resp;

    // Internal signals: ID Stage
    logic [31:0] ID_Instruction;
    logic [4:0] ID_RS1;
    logic [4:0] ID_RS2;
    logic [4:0] ID_RD;
    logic [31:0] ID_PC;
    logic [31:0] ID_Read_Data1;
    logic [31:0] ID_Read_Data2;
    logic [31:0] ID_imm;
    logic [3:0] ID_funct;
    rv32i_control_word ID_control;
    logic id_ex_load;

    assign id_ex_load = ~stage_register_reset & IF_resp & MEM_resp & EX_ALU_resp;

    // Internal signals: EX Stage
    logic [31:0] EX_PC;
    logic [31:0] EX_Read_Data1;
    logic [31:0] EX_Read_Data2;
    logic [31:0] EX_imm;
    logic [31:0] EX_ADD;
    logic EX_ZERO;
    logic [31:0] EX_RESULT;
    logic [31:0] EX_ALU_IN1;
    logic [31:0] EX_ALU_IN2;
    logic [4:0] EX_RS1;
    logic [4:0] EX_RS2;
    logic [4:0] EX_RD;
    logic [3:0] EX_funct;
    rv32i_control_word EX_control;
    logic ex_mem_load;
    
    assign ex_mem_load = ~stage_register_reset & IF_resp & MEM_resp & EX_ALU_resp;

    // Internal signals: MEM Stage
    rv32i_control_word MEM_control;
    
    logic MEM_ZERO;   
    logic [31:0] MEM_RESULT;
    logic [31:0] MEM_ADD;
    logic [31:0] MEM_ALU_IN1;
    logic [31:0] MEM_ALU_IN2;
    logic [4:0] MEM_RD;
    logic [4:0] MEM_RS1;
    logic [4:0] MEM_RS2;
    logic [31:0] MEM_Read_Data;
    logic [31:0] MEM_Read_Data2;
    logic mem_wb_load;
    logic [3:0] MEM_funct;
    logic [31:0] MEM_lui;
    logic [31:0] MEM_Forward;

    assign mem_wb_load = IF_resp & MEM_resp & EX_ALU_resp;

    // Internal signals: WB Stage
    logic [31:0] WB_RESULT;
    logic [4:0] WB_RD;
    logic [31:0] WB_mux_out;
    logic [31:0] WB_Read_Data;
    logic [31:0] WB_lui;
    logic [31:0] WB_auipc;
    rv32i_control_word WB_control;

    /* Modules */
    IF #(.l2_cache(l2_cache), .cache_cycle(cache_cycle), .enable_prefetching(enable_prefetching)) if_stage(.*);
    if_id_register if_id(.rst(stage_register_reset), .*);
    ID id_stage(.*);
    id_ex_register id_ex(.rst(stage_register_reset), .*);
    EX ex_stage(.*);
    ex_mem_register ex_mem(.rst(stage_register_reset), .*);
    MEM #(.l2_cache(l2_cache), .cache_cycle(cache_cycle), .enable_ewb(enable_ewb)) mem_stage(.*);
    mem_wb_register mem_wb(.*);
    WB wb_stage(.*);

    always_ff @(posedge clk) begin : performanceCounter
        if (rst) begin
            clock_cycle_count <= 0;
            cache_stall_count <= 0;
        end else begin
            clock_cycle_count <= clock_cycle_count + 1;
            if (!(IF_resp & MEM_resp)) cache_stall_count <= cache_stall_count + 1;
        end
    end

endmodule : datapath