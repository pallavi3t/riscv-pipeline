module mp4_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// For local simulation, add signal for Modelsim to display by default
// Note that this signal does nothing and is not used for anything
bit f;

/****************************** End do not touch *****************************/

/************************ Signals necessary for monitor **********************/
// This section not required until CP2

/*assign rvfi.commit = dut.datapath.PCWrite | dut.datapath.WB_control.RegWrite; // Set high when a valid instruction is modifying regfile or PC
assign rvfi.halt = dut.datapath.PCWrite & (dut.datapath.if_stage.IF_PC == dut.datapath.if_stage.mux_out);   // Set high when you detect an infinite loop
*/initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO


// The following signals need to be set:
// Instruction and trap:
    /*assign rvfi.inst = dut.datapath.id_stage.ID_Instruction;
    assign rvfi.trap = 0;

// Regfile:
    assign rvfi.rs1_addr = dut.datapath.id_stage.ID_RS1;
    assign rvfi.rs2_addr = dut.datapath.id_stage.ID_RS2;
    assign rvfi.rs1_rdata = dut.datapath.id_stage.ID_Read_Data1;
    assign rvfi.rs2_rdata = dut.datapath.id_stage.ID_Read_Data2;
    assign rvfi.load_regfile = dut.datapath.ID_control.RegWrite;
    assign rvfi.rd_addr = dut.datapath.id_stage.WB_RD;
    assign rvfi.rd_wdata = dut.mem_rdata;//dut.datapath.if_stage.IF_PC;//dut.datapath.id_stage.WB_mux_out;

// PC:
    assign rvfi.pc_rdata = dut.datapath.ex_stage.EX_PC;
    assign rvfi.pc_wdata = dut.datapath.if_stage.MEM_ADD;

// Memory:
    assign rvfi.mem_addr = dut.datapath.mem_stage.MEM_RESULT;
    assign rvfi.mem_rmask = dut.pmem_dmbe;
    assign rvfi.mem_wmask = 0;//dut.datapath.mem_stage.MEM_control.mbe;
    assign rvfi.mem_rdata = dut.mem_rdata;
    assign rvfi.mem_wdata = dut.datapath.mem_stage.MEM_ALU_IN2;*/

// Please refer to rvfi_itf.sv for more information.

/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
/*
The following signals need to be set:
icache signals:
    itf.inst_read
    itf.inst_addr
    itf.inst_resp
    itf.inst_rdata

dcache signals:
    itf.data_read
    itf.data_write
    itf.data_mbe
    itf.data_addr
    itf.data_wdata
    itf.data_resp
    itf.data_rdata

Please refer to tb_itf.sv for more information.
*/

/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers = '{default: '0};//dut.datapath.id_stage.regfile.data;

/*********************** Instantiate your design here ************************/
/*
The following signals need to be connected to your top level:
Clock and reset signals:
    itf.clk
    itf.rst

Burst Memory Ports:
    itf.mem_read
    itf.mem_write
    itf.mem_wdata
    itf.mem_rdata
    itf.mem_addr
    itf.mem_resp

Please refer to tb_itf.sv for more information.
*/

mp4 #(.l2_cache(1'b1), .enable_prefetching(1'b0), .enable_ewb(1'b0)) dut(
    .clk(itf.clk),
    .rst(itf.rst),
    .mem_read(itf.mem_read),
    .mem_write(itf.mem_write),
    .mem_wdata(itf.mem_wdata),
    .mem_rdata(itf.mem_rdata),
    .mem_addr(itf.mem_addr),
    .mem_resp(itf.mem_resp)
);

// mp4 dut(
//     .clk(itf.clk),
//     .rst(itf.rst),
//     .inst_resp(itf.inst_resp),
//     .inst_rdata(itf.inst_rdata),
//     .inst_read(itf.inst_read),
//     .inst_addr(itf.inst_addr),

//     .data_resp(itf.data_resp),
//     .data_rdata(itf.data_rdata),
//     .data_mbe(itf.data_mbe),
//     .data_read(itf.data_read),
//     .data_write(itf.data_write),
//     .data_addr(itf.data_addr),
//     .data_wdata(itf.data_wdata)
// );
/***************************** End Instantiation *****************************/

endmodule
