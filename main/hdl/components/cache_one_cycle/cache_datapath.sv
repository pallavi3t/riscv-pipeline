import rv32i_types::*;

module cache_datapath #(
  parameter num_ways = 2, 
  parameter width = 256, 
  parameter replacement_policy_t replacement_policy = plru,
  parameter num_cycles = 1,
  parameter s_offset = 5,
  parameter s_index = 3,
  parameter num_bits = 1,
  parameter logic prefetching = 1'b0,
  parameter logic eviction = 1'b0
)
( // parameterize
  input clk,
  input rst,

  /* CPU memory data signals */
  input logic  [31:0]  mem_byte_enable,
  input logic  [31:0]  mem_address,
  input logic  [width-1:0] mem_wdata,
  output logic [width-1:0] mem_rdata,
  input logic mem_read,
  input logic mem_write,

  /* Physical memory data signals */
  input  logic [width-1:0] pmem_rdata,
  output logic [width-1:0] pmem_wdata,
  output logic [31:0]  pmem_address,

  /* Control signals */
  input logic [num_ways-1:0] tag_load,
  input logic [num_ways-1:0] valid_load,
  input logic [num_ways-1:0] dirty_load,
  input logic [num_ways-1:0] dirty_in,
  output logic [num_ways-1:0] dirty_out,
  input [num_bits-1:0] lru_load,
  input [num_bits-1:0] lru_in,
  output [num_bits-1:0] lru_out,
 
  output logic [num_ways-1:0] hit,
  input logic [1:0] writing,
  output logic [num_bits-1:0] way_index,
  output logic [num_ways-1:0] hit_next,
  output logic [num_bits-1:0] ewb_size,
  input logic ewb_access
);

logic [width-1:0] line_in[num_ways], line_out[num_ways];
logic [31-s_offset-s_index:0] address_tag, tag_out[num_ways];
logic [s_index-1:0] index;
logic [31:0] mask[num_ways];
logic [num_ways-1:0] valid_out;
logic [31:0] ewb_address_out = '{default: '0};

assign address_tag = mem_address[31:s_offset+s_index];
assign index = mem_address[s_offset+s_index-1:s_offset];
assign mem_rdata = line_out[way_index];

genvar i;
int size = 0;
generate
  if (prefetching & !eviction) begin
    logic [31-s_offset-s_index:0] address_next_tag;
    logic [31:0] next_address;
    assign next_address = mem_address + 4;
    assign address_next_tag = next_address[31:s_offset+s_index];
    for (i = 0; i < num_ways; i++) begin : hit_next_block
      assign hit_next[i] = valid_out[i] & (tag_out[i] == address_next_tag);
    end
    always_comb begin
      pmem_address = mem_address;
      if (hit & !hit_next) pmem_address = next_address;
      else if (dirty_out[way_index]) pmem_address = {tag_out[way_index], mem_address[s_offset+s_index-1:0]};
    end
  end else begin
    if (eviction & !prefetching) begin
      always_comb begin
        pmem_address = mem_address;
        if (hit & dirty_out[way_index] & (ewb_size == num_ways - 1)) pmem_address = ewb_address_out;
        else if (ewb_size & !(mem_read | mem_write)) pmem_address = ewb_address_out;
      end
    end
    else assign pmem_address = (dirty_out[way_index]) ? {tag_out[way_index], mem_address[s_offset+s_index-1:0]} : mem_address;
    assign hit_next = 1'b0;
  end

  if (eviction & !prefetching) begin
    logic [width-1:0] ewb[num_ways] = '{default: '0};
    logic [31:0] ewb_address[num_ways] = '{default: '0};
    logic [width-1:0] ewb_out;
    logic [num_bits-1:0] head = '{default: '0}, tail = '{default: '0};
    assign pmem_wdata = ewb_out;
    always_ff @(posedge clk) begin
      if (rst) begin
        ewb_out <= '{'0};
        ewb_size <= '{'0};
        tail <= '{'0};
        head <= '{'0};
      end else begin
        if (ewb_access) begin
          ewb_out <= ewb[head];
          ewb_address_out <= ewb_address[head];
          head <= (head + 1) % num_ways;
          ewb_size <= ewb_size - 1;
        end
        if (!hit & dirty_out[way_index] & valid_out[way_index]) begin
          ewb[tail] <= line_out[way_index];
          ewb_address[tail] <= {tag_out[way_index], mem_address[s_offset+s_index-1:0]};
          ewb_size <= (ewb_size + 1) % num_ways;
          tail <= (tail + 1) % num_ways;
        end
      end
    end
	end else begin
    assign pmem_wdata = line_out[way_index];
    assign ewb_size = 1'b0;
  end

  for (i = 0; i < num_ways; i++) begin : hit_block
    assign hit[i] = valid_out[i] & (tag_out[i] == address_tag);
  end
  always_comb begin
    for (int j = 0; j < num_ways; j++) begin : mask_block
      mask[j] = 32'b0;
      line_in[j] = mem_wdata;   
    end  
    if (rst) begin
    end else begin
      case(writing)
        2'b00: begin // load from memory
          mask[way_index] = 32'hFFFFFFFF;
          line_in[way_index] = pmem_rdata;
        end
        2'b01: begin // write from cpu
          mask[way_index] = mem_byte_enable;
          line_in[way_index] = mem_wdata;
        end
        default: begin // don't change data
          mask[way_index] = 32'b0;
          line_in[way_index] = mem_wdata;
        end
      endcase
    end
  end
  always_comb begin
    way_index = {num_bits{1'b0}};
	 size = hit;
    if (!hit) begin
		way_index = lru_out;
	 end else begin
      for (int it = 1, size = hit; size > 0; it = it << 1, size = size >> 1) begin : way_index_block
        way_index += it * size[0];
      end
    end
  end
endgenerate

generate
  for (i = 0; i < num_ways; i++) begin : array_block
    data_array #(.width(width), .s_offset(s_offset), .s_index(s_index), .num_cycles(num_cycles)) DM_cache_i (
      clk, rst, mask[i], index, index, line_in[i], line_out[i]
    );
    array #(.width(32-s_index-s_offset), .s_offset(s_offset), .s_index(s_index), .num_cycles(num_cycles)) tag_i (
      clk, rst, tag_load[i], index, index, address_tag, tag_out[i]
    );
    array #(.width(1), .s_offset(s_offset), .s_index(s_index), .num_cycles(num_cycles)) valid_i (
      clk, rst, valid_load[i], index, index, 1'b1, valid_out[i]
    );
    array #(.width(1), .s_offset(s_offset), .s_index(s_index), .num_cycles(num_cycles)) dirty_i (
      clk, rst, dirty_load[i], index, index, dirty_in[i], dirty_out[i]
    );
  end
  for (i = 0; i < num_bits; i++) begin : lru_block
    array #(.width(1), .s_offset(s_offset), .s_index(s_index), .num_cycles(num_cycles)) lru_i (
      clk, rst, lru_load[i], index, index, lru_in[i], lru_out[i]
    );
  end
endgenerate

endmodule : cache_datapath