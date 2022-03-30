import rv32i_types::*;

module IF #(
    parameter l2_cache = 1'b1,
    parameter cache_cycle = 1'b1,
    parameter enable_prefetching = 1'b1
)
(
    input clk,
    input rst,

    input PCSrc, 
    input [31:0] MEM_ADD, 
    input PCWrite,

    output [31:0] IF_PC,
    output [31:0] IF_Instruction,
    output IF_resp,

    input logic pmem_iresp,
    input logic [255:0] pmem_irdata,
    output logic [31:0] pmem_iaddress,
    output logic [255:0] pmem_iwdata,
    output logic pmem_iread,
    output logic pmem_iwrite
); 
    /* Internal signals */
    logic [31:0] alu_out;
    logic [31:0] mux_out;
    logic i_miss;
    logic l1_l2_resp;
    logic [255:0] l1_l2_rdata;
    logic [255:0] l1_l2_wdata;
    logic [31:0] l1_l2_address;
    logic l1_l2_read;
    logic l1_l2_write;
    logic l1_l2_miss;
    logic pc_alu_done;

    /* Modules */
    alu alu (
        .aluop(alu_add), 
        .a(IF_PC), 
        .b(4), 
        .f(alu_out),
        .funct3(3'b0),
        .done(pc_alu_done),
        .*
    ); 

    pc_register pc_reg(
        .clk, 
        .rst, 
        .load(PCWrite),
        .in(mux_out),
        .out(IF_PC)
    );

    mux2to1 #(.width(32)) mux(
        .out(mux_out),
        .sel(PCSrc),
        .a(alu_out),
        .b(MEM_ADD)
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
                .prefetching(enable_prefetching),
                .eviction(1'b0)
            )
            icache_l1(
                .pmem_resp(l1_l2_resp),
                .pmem_rdata(l1_l2_rdata),
                .pmem_address(l1_l2_address),
                .pmem_wdata(l1_l2_wdata),
                .pmem_read(l1_l2_read),
                .pmem_write(l1_l2_write),

                .mem_read(1'b1),
                .mem_write(1'b0),
                .mem_byte_enable_cpu(4'hF),
                .mem_address(IF_PC),
                .mem_wdata_cpu(32'b0),
                .mem_resp(IF_resp),
                .mem_rdata_cpu(IF_Instruction),
                .d_miss(l1_l2_miss),
                .*
            );

            l2_cache#(
                .num_ways(8), 
                .width(256), 
                .replacement_policy(plru),
                .num_cycles(cache_cycle),
                .s_offset(5),
                .s_index(3),
                .prefetching(enable_prefetching),
                .eviction(1'b0)
            )
            icache_l2 (
                .pmem_resp(pmem_iresp),
                .pmem_rdata(pmem_irdata),
                .pmem_address(pmem_iaddress),
                .pmem_wdata(pmem_iwdata),
                .pmem_read(pmem_iread),
                .pmem_write(pmem_iwrite),

                .mem_read(l1_l2_read),
                .mem_write(l1_l2_write),
                .mem_byte_enable_cpu(4'hF),
                .mem_address(l1_l2_address),
                .mem_wdata_cpu(256'b0),
                .mem_resp(l1_l2_resp),
                .mem_rdata_cpu(l1_l2_rdata),
                .d_miss(i_miss),
                .opp_mem_read(1'b0),
                .opp_mem_write(1'b0),
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
                .prefetching(enable_prefetching),
                .eviction(1'b0)
            )
            icache(
                .pmem_resp(pmem_iresp),
                .pmem_rdata(pmem_irdata),
                .pmem_address(pmem_iaddress),
                .pmem_wdata(pmem_iwdata),
                .pmem_read(pmem_iread),
                .pmem_write(pmem_iwrite),

                .mem_read(1'b1),
                .mem_write(1'b0),
                .mem_byte_enable_cpu(4'h0),
                .mem_address(IF_PC),
                .mem_wdata_cpu(32'b0),
                .mem_resp(IF_resp),
                .mem_rdata_cpu(IF_Instruction),
                .d_miss(i_miss),
                .*
            );
        end
    endgenerate

endmodule : IF
