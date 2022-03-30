import rv32i_types::*;

module cache_control #(
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
(
	input clk,
	input rst,

	/* CPU memory data signals */
	input  logic mem_read,
	input  logic mem_write,
	output logic mem_resp,

	/* Physical memory data signals */
	input  logic pmem_resp,
	output logic pmem_read,
	output logic pmem_write,

	/* Control signals */
	output logic [num_bits-1:0] lru_load,
	output logic [num_bits-1:0] lru_in,
	input logic [num_bits-1:0] lru_out,
	output logic [num_ways-1:0] tag_load,
	output logic [num_ways-1:0] valid_load,
	output logic [num_ways-1:0] dirty_load,
	output logic [num_ways-1:0] dirty_in,
	input logic [num_ways-1:0] dirty_out,

	input logic [num_ways-1:0] hit,
	output logic [1:0] writing,
	input [num_bits-1:0] way_index,

	input logic [num_ways-1:0] hit_next,
	input logic [num_bits-1:0] ewb_size,
	output logic ewb_access
);

/* Internal Signals */
logic [num_bits-1:0] accessed_way;
logic [31:0] num_hits;
logic [31:0] num_misses;
logic prefetching_on;
logic [num_ways-2:0] lru_tree;
logic [num_bits-1:0] index;
logic [127:0] random_num;
logic done;
logic [num_bits-1:0] fifo_order = '{default: '0};
logic second_chance_array[num_ways];
logic sc_load, sc_load_in;

/* State Enumeration */
enum int unsigned
{
	reset, 
	check_hit,
	read_mem,
	hit_state,
	evict
} state, next_state;

/* Functions */
genvar i;
generate
	initial begin
		random_num <= 128'h6F4F2F0F60402F0F674F20036F4F2F0F;
		lru_tree <= {num_ways-1{1'b1}};
	end

	case (replacement_policy)
		random: begin
			always_ff @(posedge clk) begin : new_random_number
				random_num <= (random_num << 1) | (random_num[127] ^ random_num[125] ^ random_num[100] ^ random_num[98]);	
			end
		end
		fifo: begin
			always_ff @(posedge clk) begin : fifo_queue
				if (sc_load) fifo_order <= (fifo_order + 1) % num_ways;
				sc_load <= sc_load_in;
			end
		end
		second_chance: begin
			always_ff @(posedge clk) begin : second_chance_queue
				for (int j = 0; j < num_ways; j++) begin
					if (second_chance_array[(fifo_order + j) % num_ways]) begin
						if (sc_load) second_chance_array[(fifo_order + j) % num_ways] <= 1'b0;
					end else if (!second_chance_array[(fifo_order + j) % num_ways]) begin
						if (sc_load) second_chance_array[(fifo_order + j) % num_ways] <= 1'b1;
						if (sc_load) second_chance_array[(fifo_order + j + 1) % num_ways] <= 1'b1;
						if (sc_load) fifo_order <= (fifo_order + j) % num_ways;
						break;
					end
					sc_load <= sc_load_in;
				end
			end
		end
		default: ;
	endcase

	function void update_tree();
		case (replacement_policy)
			plru: begin
				if (hit) begin
					index = way_index;
					lru_in = way_index;
				end else begin
					index = 0;
					for (int j = 0; j < num_bits; j++) begin
						lru_in[num_bits - 1 - j] = lru_tree[index];
						index += 2**{num_bits{j}} + lru_tree[index];
					end
				end
				for (int j = num_ways; j > 1; j /= 2) begin
					lru_tree[index] = ~lru_tree[index];
					index /= 2;
				end
			end
			random: begin
				if (!hit) begin
					lru_in = random_num[num_bits-1:0];
				end else lru_in = way_index;
			end
			fifo: begin
				if (!hit) begin
					lru_in = fifo_order;
					sc_load_in = 1'b1;
				end else lru_in = way_index;
			end
			second_chance: begin  
				if (!hit) begin
					lru_in = fifo_order;
					sc_load_in = 1'b1;
				end else lru_in = way_index;
			end 
		endcase
	endfunction

	/* State Control Signals */
	always_comb begin : state_actions
		/* Defaults */
		tag_load = 0;
		valid_load = 0;
		dirty_load = 0;
		dirty_in = 0;
		writing = 2'b11;
		lru_load = 0;
		lru_in = 0;
		sc_load_in = 1'b0;

		mem_resp = 1'b0;
		pmem_write = 1'b0;
		pmem_read = 1'b0;
		ewb_access = 1'b0;
		done = 1'b0;

		case(state)
			reset: ;
			check_hit: begin
				if (mem_read || mem_write) begin
					if (hit) begin
						if (num_cycles == 1) mem_resp = 1'b1;
						update_tree();
						lru_load = {num_bits{1'b1}};
						if (mem_write) begin
							dirty_load[way_index] = 1'b1;
							dirty_in[way_index] = 1'b1;
							writing = 2'b01;
						end
					end else if (dirty_out & !eviction) begin
						pmem_write = 1'b1;
					end else if (dirty_out & (ewb_size == num_ways - 1)) begin
						pmem_write = 1'b1;
						ewb_access = 1'b1;
					end
				end else if (eviction & !prefetching & !(mem_read || mem_write) & ewb_size) begin
					ewb_access = 1'b1;
					pmem_write = 1'b1;
				end else mem_resp = 1'b1;
			end

			read_mem: begin
				pmem_read = 1'b1;
				writing = 2'b00;
				if (pmem_resp) begin
					tag_load[accessed_way] = 1'b1;
					valid_load[accessed_way] = 1'b1;
					update_tree();
					lru_load = {num_bits{1'b1}};
				end
				dirty_load[accessed_way] = 1'b1;
				dirty_in[accessed_way] = 1'b0;
			end

			hit_state: begin
				mem_resp = 1'b1;
			end

			evict: begin 
				pmem_write = 1'b1;
			end

		endcase
	end

	/* Next State Logic */
	always_comb begin : next_state_logic
		/* Default state transition */
		next_state = state;

		case(state)
			reset: next_state = check_hit;
			check_hit: begin
				if ((mem_read || mem_write) && !hit) begin
					if (dirty_out & !eviction) begin
						if (pmem_resp) next_state = read_mem;
					end else if (dirty_out & eviction & (ewb_size == num_ways - 1)) begin
						next_state = evict;
					end else next_state = read_mem;
				end else if (prefetching & hit & num_cycles == 1 & (mem_read || mem_write)) begin
					next_state = (!hit_next) ? read_mem : check_hit;
				end else if (hit & num_cycles == 2 & (mem_read || mem_write)) 
					next_state = hit_state;
				else if (!prefetching & eviction & ewb_size & !(mem_read || mem_write)) 
					next_state = evict;
				else next_state = check_hit;
			end
			hit_state: begin
				next_state = (!hit_next & prefetching) ? read_mem : check_hit;
			end
			read_mem: if (pmem_resp) next_state = check_hit;
			evict: if (pmem_resp) next_state = ((mem_read | mem_write) & !hit) ? read_mem : check_hit;
		endcase
	end
endgenerate

/* Next State Assignment */
always_ff @(posedge clk) begin: next_state_assignment
	if (rst) begin
		state <= reset;
		num_hits <= 0;
		num_misses <= 0;
		prefetching_on <= 1'b0;
		accessed_way <= {num_ways{1'b0}};
	end else begin
		case (state)
			check_hit: begin
				if (mem_read || mem_write) begin
					if (hit) num_hits <= num_hits + 1;
					else num_misses <= num_misses + 1;
					if (hit & !hit_next & num_cycles == 1) prefetching_on <= 1'b1;
					else prefetching_on <= 1'b0;
				end
			end
			hit_state: begin
				if (hit & !hit_next) prefetching_on <= 1'b1;
				else prefetching_on <= 1'b0;
			end
			default: ;
		endcase
		state <= next_state;
		accessed_way <= lru_out;
	end
end

endmodule : cache_control