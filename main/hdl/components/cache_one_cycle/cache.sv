import rv32i_types::*;

module cache #(
  parameter num_ways = 2, 
  parameter width = 256, 
  parameter replacement_policy_t replacement_policy = plru,
  parameter num_cycles = 1,
  parameter s_offset = 5,
  parameter s_index = 3,
  parameter logic prefetching = 1'b0,
  parameter logic eviction = 1'b0
)
(
  input clk,
  input rst,

  /* Physical memory signals */
  input logic pmem_resp,
  input logic [width-1:0] pmem_rdata,
  output logic [31:0] pmem_address,
  output logic [width-1:0] pmem_wdata,
  output logic pmem_read,
  output logic pmem_write,

  /* CPU memory signals */
  input logic mem_read,
  input logic mem_write,
  input logic [3:0] mem_byte_enable_cpu,
  input logic [31:0] mem_address,
  input logic [31:0] mem_wdata_cpu,
  output logic mem_resp,
  output logic [31:0] mem_rdata_cpu,
  output logic d_miss
);
/* Internal Signals */
logic [num_ways-1:0] tag_load;
logic [num_ways-1:0] valid_load;
logic [num_ways-1:0] dirty_load;
logic [num_ways-1:0] dirty_in;
logic [num_ways-1:0] dirty_out;
logic [1:0] writing;
logic [width-1:0] mem_wdata;
logic [width-1:0] mem_rdata;
logic [31:0] mem_byte_enable;
logic [num_ways-1:0] hit;
logic ewb_access;
logic [num_ways-1:0] hit_next;

localparam s_mbe = 4;
localparam num_bits = (num_ways > 1) ? $clog2(num_ways) : 1;

generate 
  logic [num_bits-1:0] lru_load;
  logic [num_bits-1:0] lru_in;
  logic [num_bits-1:0] lru_out;
  logic [num_bits-1:0] way_index;
  logic [num_bits-1:0] ewb_size;

  cache_datapath #(num_ways, width, replacement_policy, num_cycles, s_offset, s_index, num_bits, prefetching, eviction) datapath(.*);
  cache_control #(num_ways, width, replacement_policy, num_cycles, s_offset, s_index, num_bits, prefetching, eviction) control(.*);
endgenerate

assign d_miss = ((pmem_read | pmem_write) & (mem_read | mem_write)) | (ewb_size & !(mem_read | mem_write));

line_adapter #(width, s_mbe, s_offset, s_index) bus (
    .mem_wdata_line(mem_wdata),
    .mem_rdata_line(mem_rdata),
    .mem_wdata(mem_wdata_cpu),
    .mem_rdata(mem_rdata_cpu),
    .mem_byte_enable(mem_byte_enable_cpu),
    .mem_byte_enable_line(mem_byte_enable),
    .address(mem_address)
);

endmodule : cache