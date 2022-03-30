import rv32i_types::*;

module mp4 #(
    parameter l2_cache = 1'b1,
    parameter cache_cycle = 1,
    parameter enable_prefetching = 1'b1,
    parameter enable_ewb = 1'b1
)
(
    input clk,
    input rst,

    // Burst Memeory
    input mem_resp,
    input [63:0] mem_rdata,
    output [63:0] mem_wdata,
    output[31:0] mem_addr,
    output mem_read,
    output mem_write

);

/* Internal signals */
logic pmem_iresp;
logic [255:0] pmem_irdata;
logic [31:0] pmem_iaddress;
logic [255:0] pmem_iwdata;
logic pmem_iread;
logic pmem_iwrite;
logic pmem_dresp;
logic [255:0] pmem_drdata;
logic [3:0] pmem_dmbe;
logic [31:0] pmem_daddress;
logic [255:0] pmem_dwdata;
logic pmem_dread;
logic pmem_dwrite;
logic [255:0] cache_wdata;
logic [255:0] cache_rdata;
logic [31:0] cache_addr;
logic cache_read;
logic cache_write;
logic cache_resp;
logic d_miss;
logic reset_n;

assign reset_n = ~rst;

/* Modules */
cacheline_adapter cacheline_adapter(
    .line_i(cache_wdata),
    .line_o(cache_rdata),
    .address_i(cache_addr),
    .read_i(cache_read),
    .write_i(cache_write),
    .resp_o(cache_resp),
    .burst_i(mem_rdata),
    .burst_o(mem_wdata),
    .address_o(mem_addr),
    .read_o(mem_read),
    .write_o(mem_write),
    .resp_i(mem_resp),
    .*
);
datapath #(.l2_cache(l2_cache), .cache_cycle(cache_cycle), .enable_prefetching(enable_prefetching), .enable_ewb(enable_ewb)) datapath(.*);
arbiter arbiter(.*);

endmodule : mp4