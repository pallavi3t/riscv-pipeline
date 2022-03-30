module arbiter (
    input clk,
    input logic [31:0] pmem_iaddress,
    input logic [31:0] pmem_daddress,
    input logic [255:0] pmem_dwdata,
    input logic pmem_dwrite,
    input logic pmem_iread,
    input logic pmem_dread,
    input logic d_miss,
    input logic cache_resp,
    input logic [255:0] cache_rdata,

    output logic [31:0] cache_addr,
    output logic [255:0] cache_wdata,
    output logic cache_write,
    output logic cache_read,
    output logic pmem_iresp,
    output logic pmem_dresp,
    output logic [255:0] pmem_irdata,
    output logic [255:0] pmem_drdata
);

mux2to1 #(.width(32)) cache_addr_mux(
    .out(cache_addr),
    .sel(d_miss),
    .a(pmem_iaddress),
    .b(pmem_daddress)
);

mux2to1 #(.width(256)) cache_wdata_mux(
    .out(cache_wdata),
    .sel(d_miss),
    .a(256'b0),
    .b(pmem_dwdata)
);

mux2to1 #(.width(1)) cache_write_mux(
    .out(cache_write),
    .sel(d_miss),
    .a(1'b0),
    .b(pmem_dwrite)
);


mux2to1 #(.width(1)) cache_read_mux(
    .out(cache_read),
    .sel(d_miss),
    .a(pmem_iread),
    .b(pmem_dread)
);

demux1to2 #(.width(1)) cache_resp_dmux(
    .out0(pmem_iresp),
    .out1(pmem_dresp),
    .sel(d_miss),
    .clk(clk),
    .in(cache_resp)
);

demux1to2 #(.width(256)) cache_rdata_dmux(
    .out0(pmem_irdata),
    .out1(pmem_drdata),
    .sel(d_miss),
    .clk(clk),
    .in(cache_rdata)
);

endmodule : arbiter