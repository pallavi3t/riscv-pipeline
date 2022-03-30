import rv32i_types::*;

module MEM #(
    parameter l2_cache = 1'b1,
    parameter cache_cycle = 1,
    parameter enable_ewb = 1'b1
)
(
    input clk,
    input rst,

    input rv32i_control_word MEM_control,
    input rv32i_control_word WB_control,
    input MEM_ZERO,
    input [31:0] MEM_RESULT,
    input [31:0] MEM_ALU_IN1,
    input [31:0] MEM_ALU_IN2,
    input [4:0] MEM_RD,
    input [4:0] MEM_RS1,
    input [4:0] MEM_RS2,
    input [3:0] MEM_funct, 
    input logic [31:0] WB_Read_Data,
    input logic [31:0] MEM_Read_Data2,
    input [4:0] WB_RD,
    input [31:0] MEM_ADD,

    output logic PCSrc,
    output logic [31:0] MEM_Read_Data,
    output MEM_resp,
    
    input pmem_dresp,
    input [255:0] pmem_drdata,
    output [3:0] pmem_dmbe,
    output logic [31:0] pmem_daddress,
    output logic [255:0] pmem_dwdata,
    output logic pmem_dread,
    output logic pmem_dwrite,
    input logic pmem_iread,
    input logic pmem_iwrite,
    output logic d_miss,
    output logic [31:0] MEM_Forward
);
    /* Internal Signals */
    logic [31:0] Read_Data;
    logic cmp_out;
    logic l1_l2_resp;
    logic [255:0] l1_l2_rdata;
    logic [255:0] l1_l2_wdata;
    logic [31:0] l1_l2_address;
    logic l1_l2_read;
    logic l1_l2_write;
    logic l1_l2_miss;

    assign pmem_dmbe = MEM_control.mbe;

    /* Modules */ 
    cmp cmp (
        .cmpop(branch_funct3_t'(MEM_funct[2:0])),
        .a(MEM_ALU_IN1),
        .b(MEM_ALU_IN2),
        .f(cmp_out)
    );

    mux3to1 #(.width(32)) forward_mux(
        .out(MEM_Forward),
        .sel({MEM_control.opcode == op_auipc, MEM_control.opcode == op_load}),
        .a(MEM_RESULT),
        .b(MEM_Read_Data),
        .c(MEM_ADD)
    );

    generate 
        if (l2_cache) begin
            cache #(
                .num_ways(8), 
                .width(256), 
                .replacement_policy(plru),
                .num_cycles(cache_cycle),
                .s_offset(5),
                .s_index(3),
                .prefetching(1'b0),
                .eviction(enable_ewb)
            )
            dcache_l1(
                .pmem_resp(l1_l2_resp),
                .pmem_rdata(l1_l2_rdata),
                .pmem_address(l1_l2_address),
                .pmem_wdata(l1_l2_wdata),
                .pmem_read(l1_l2_read),
                .pmem_write(l1_l2_write),

                .mem_read(MEM_control.MEM_Read),
                .mem_write(MEM_control.MEM_Write),
                .mem_byte_enable_cpu(MEM_control.mbe),
                .mem_address(MEM_RESULT),
                .mem_wdata_cpu(MEM_ALU_IN2),
                .mem_resp(MEM_resp),
                .mem_rdata_cpu(Read_Data),
                .d_miss(l1_l2_miss),
                .*
            );

            l2_cache #(
                .num_ways(8), 
                .width(256), 
                .replacement_policy(plru),
                .num_cycles(cache_cycle),
                .s_offset(5),
                .s_index(3),
                .prefetching(1'b0),
                .eviction(enable_ewb)
            )
            dcache_l2(
                .pmem_resp(pmem_dresp),
                .pmem_rdata(pmem_drdata),
                .pmem_address(pmem_daddress),
                .pmem_wdata(pmem_dwdata),
                .pmem_read(pmem_dread),
                .pmem_write(pmem_dwrite),

                .mem_read(l1_l2_read),
                .mem_write(l1_l2_write),
                .mem_byte_enable_cpu(4'hF),
                .mem_address(l1_l2_address),
                .mem_wdata_cpu(l1_l2_wdata),
                .mem_resp(l1_l2_resp),
                .mem_rdata_cpu(l1_l2_rdata),
                .d_miss(d_miss),
                .opp_mem_read(pmem_iread),
                .opp_mem_write(pmem_iwrite),
                .*
            );
        end else begin
            cache #(
                .num_ways(8), 
                .width(256), 
                .replacement_policy(plru),
                .num_cycles(cache_cycle),
                .s_offset(5),
                .s_index(3),
                .prefetching(1'b0),
                .eviction(enable_ewb)
            )
            dcache(
                .pmem_resp(pmem_dresp),
                .pmem_rdata(pmem_drdata),
                .pmem_address(pmem_daddress),
                .pmem_wdata(pmem_dwdata),
                .pmem_read(pmem_dread),
                .pmem_write(pmem_dwrite),

                .mem_read(MEM_control.MEM_Read),
                .mem_write(MEM_control.MEM_Write),
                .mem_byte_enable_cpu(MEM_control.mbe),
                .mem_address(MEM_RESULT),
                .mem_wdata_cpu(MEM_ALU_IN2),
                .mem_resp(MEM_resp),
                .mem_rdata_cpu(Read_Data),
                .d_miss(d_miss),
                .*
            );
        end
    endgenerate

    always_comb begin
        MEM_Read_Data = 32'b0;
        case (MEM_control.mbe)
            4'b0001: begin
                if (MEM_RESULT[1]) MEM_Read_Data = (MEM_RESULT[0]) ? 32'(signed'(Read_Data[31:24])) : 32'(signed'(Read_Data[23:16]));
                else MEM_Read_Data = (MEM_RESULT[0]) ? 32'(signed'(Read_Data[15:8])) : 32'(signed'(Read_Data[7:0]));
            end
            4'b0011: MEM_Read_Data = (MEM_RESULT[1]) ? 32'(signed'(Read_Data[31:16])) : 32'(signed'(Read_Data[15:0]));
            4'hF: MEM_Read_Data = Read_Data;
            4'b1000: begin
                if (MEM_RESULT[1]) MEM_Read_Data = (MEM_RESULT[0]) ? {24'b0, Read_Data[31:24]} : {24'b0, Read_Data[23:16]};
                else MEM_Read_Data = (MEM_RESULT[0]) ? {24'b0, Read_Data[15:8]} : {24'b0, Read_Data[7:0]};
            end
            4'b1100: MEM_Read_Data = (MEM_RESULT[1]) ? {16'b0, Read_Data[31:16]} : {16'b0, Read_Data[15:0]};
            default: MEM_Read_Data = 32'b0;
        endcase

        PCSrc = 1'b0;
        if (MEM_control.MEM_BRANCH) PCSrc = '{cmp_out};
        else PCSrc = MEM_control.MEM_JAL;
    end

endmodule : MEM