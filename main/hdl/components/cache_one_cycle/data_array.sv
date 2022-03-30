module data_array #(
  parameter width = 256,
  parameter s_offset = 5,
  parameter s_index = 3,
  parameter num_cycles = 1
)
(
  input clk,
  input rst,
  input logic [31:0] write_en,
  input logic [s_index-1:0] rindex,
  input logic [s_index-1:0] windex,
  input logic [width-1:0] datain,
  output logic [width-1:0] dataout
);

localparam s_mask   = 2**s_offset;
localparam s_line   = 8*s_mask;
localparam num_sets = 2**s_index;

generate
  if (num_cycles == 1) begin
    logic [width-1:0] data [num_sets] = '{default: '0};

    always_comb begin
      for (int i = 0; i < width / num_sets; i++) begin
          dataout[num_sets*i +: num_sets] = (write_en[i] & (rindex == windex)) ? datain[num_sets*i +: num_sets] : data[rindex][num_sets*i +: num_sets];
      end
    end

    always_ff @(posedge clk) begin
      if (rst) begin
            for (int i = 0; i < num_sets; ++i)
                data[i] <= '0;
        end else begin
          for (int i = 0; i < width / num_sets; i++) begin
            data[windex][num_sets*i +: num_sets] <= write_en[i] ? datain[num_sets*i +: num_sets] : data[windex][num_sets*i +: num_sets];
          end
        end
    end
  end else begin
    logic read;
    logic [s_line-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;
    logic [s_line-1:0] _dataout;
    assign dataout = _dataout;
    assign read = 1'b1;

    always_ff @(posedge clk)
    begin
        if (rst) begin
            for (int i = 0; i < num_sets; ++i)
                data[i] <= '0;
        end
        else begin
            if (read)
                for (int i = 0; i < s_mask; i++)
                    _dataout[num_sets*i +: num_sets] <= (write_en[i] & (rindex == windex)) ?
                                          datain[num_sets*i +: num_sets] : data[rindex][num_sets*i +: num_sets];

            for (int i = 0; i < s_mask; i++)
            begin
                data[windex][num_sets*i +: num_sets] <= write_en[i] ? datain[num_sets*i +: num_sets] :
                                                        data[windex][num_sets*i +: num_sets];
            end
        end
    end
  end
endgenerate
endmodule : data_array