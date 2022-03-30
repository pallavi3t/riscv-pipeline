module array #(
  parameter width = 1,
  parameter s_offset = 5,
  parameter s_index = 3,
  parameter num_cycles = 1
)
(
  input clk,
  input rst,
  input logic load,
  input logic [s_index-1:0] rindex,
  input logic [s_index-1:0] windex,
  input logic [width-1:0] datain,
  output logic [width-1:0] dataout
);

localparam num_sets = 2**s_index;

//logic [width-1:0] data [2:0] = '{default: '0};
generate 
  if(num_cycles == 1) begin
    logic [width-1:0] data [num_sets];
    initial begin
      for (int i = 0; i < num_sets; i++) begin
        data[i] = 0;
      end
    end

    always_comb begin
      dataout = (load  & (rindex == windex)) ? datain : data[rindex];
    end

    always_ff @(posedge clk)
    begin
        if (rst) begin
            for (int i = 0; i < num_sets; ++i)
                data[i] <= '0;
        end else begin
          if(load)
              data[windex] <= datain;
        end
    end   
  end else begin
    logic [width-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;
    logic [width-1:0] _dataout;
    logic read;
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
                _dataout <= (load  & (rindex == windex)) ? datain : data[rindex];

            if(load)
                data[windex] <= datain;
        end
    end
  end
  endgenerate

endmodule : array