// module mux
//  #( parameter int unsigned inputs = 3,
//     parameter int unsigned width = 32 )
//   ( output logic [width-1:0] out,
//     input logic sel[inputs],
//     input logic [width-1:0] in[inputs] );

//     always_comb
//     begin
//         out = {width{1'b0}};
//         for (int unsigned index = 0; index < inputs; index++)
//         begin
//             out |= {width{sel[index]}} & in[index];
//         end
//     end
// endmodule

module mux2to1 #(parameter int unsigned width = 32)
(
    output logic [width-1:0] out,
    input logic sel,
    input logic [width-1:0] a,
    input logic [width-1:0] b
);

    always_comb begin : mux2to1_logic
        out = (sel) ? b : a;
    end

endmodule: mux2to1


module mux3to1 #(parameter int unsigned width = 32)
(
    output logic [width-1:0] out, 
    input logic [1:0] sel, 
    input logic [width-1:0] a, b, c
);

    always_comb begin : mux3to1_logic
        case (sel) 
            2'b00: out = a;
            2'b01: out = b;
            2'b10: out = c;
            2'b11: out = 32'hZ;
            default: out = a;
        endcase
    end

endmodule: mux3to1


module demux1to2 #(parameter int unsigned width = 256)
(
    output logic [width-1:0] out0,
    output logic [width-1:0] out1,
    input logic sel,
    input logic clk,
    input logic [width-1:0] in
);
    logic [width-1:0] data0;
    logic [width-1:0] data1;

    assign out0 = data0;
    assign out1 = data1;

    /*always_comb begin : demux1to2_logic 
        data0 = data0;
        data1 = data1;

    end*/

    always_ff @(clk) begin  
        case(sel)
            1'b0: begin
                data0 <= in;
                data1 <= data1;
            end
            1'b1: begin
                data0 <= data0;
                data1 <= in;
            end
        endcase
    end

endmodule : demux1to2