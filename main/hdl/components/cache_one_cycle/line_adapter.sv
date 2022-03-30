module line_adapter #(
  parameter width = 256, 
  parameter s_mbe = 4,
  parameter s_offset = 5,
  parameter s_index = 3
)
(
  output logic [width-1:0] mem_wdata_line,
  input logic [width-1:0] mem_rdata_line,
  input logic [31:0] mem_wdata,
  output logic [31:0] mem_rdata,
  input logic [s_mbe-1:0] mem_byte_enable,
  output logic [31:0] mem_byte_enable_line,
  input logic [31:0] address
);

assign mem_wdata_line = {8{mem_wdata}};
assign mem_rdata = mem_rdata_line[((2**s_offset)*address[s_offset-1:2]) +: (2**s_offset)];
assign mem_byte_enable_line = {28'h0, mem_byte_enable} << (address[s_offset-1:2]*4);

endmodule : line_adapter