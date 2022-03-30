/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER. */

import rv32i_types::*;

module alu
(
    input clk,
    input rst,
    input alu_ops aluop,
    input [31:0] a, b,
    input [2:0] funct3, 
    output logic [31:0] f,
    output logic done
);

logic [63:0] multiplier_out;
logic [31:0] a_in, b_in;
logic mult_done;
logic mult_start;
logic mult_ready;

enum int unsigned
{
	idle,
    wait_state
} state, next_state;

always_comb begin
    f = 0;
    a_in = 0;
    b_in = 0;
    case (aluop)
        alu_add:  f = a + b;
        alu_sll:  f = a << b[4:0];
        alu_sra:  f = $signed(a) >>> b[4:0];
        alu_sub:  f = a - b;
        alu_xor:  f = a ^ b;
        alu_srl:  f = a >> b[4:0];
        alu_or:   f = a | b;
        alu_and:  f = a & b;
        alu_mul: begin
            unique case (mul_funct3_t'(funct3))
                mul: begin
                    if (a[31]) a_in = (~a) + 1;
                    else a_in = a;
                    if (b[31]) b_in = (~b) + 1;
                    else b_in = b;

                    if (a[31] ^ b[31]) f = (~multiplier_out[31:0]) + 1;
                    else f = multiplier_out[31:0];            
                end
                mulh:begin
                    if (a[31]) a_in = (~a) + 1;
                    else a_in = a;
                    if (b[31]) b_in = (~b) + 1;
                    else b_in = b;
                    
                    if (a[31] ^ b[31]) f = (~multiplier_out[63:32]) + 1;
                    else f = multiplier_out[63:32];
                end
                mulhsu: begin
                    if (a[31]) a_in = (~a) + 1;
                    else a_in = a;
                    b_in = b;
                    if (a[31]) f = (~multiplier_out[63:32]) + 1;
                    else f = multiplier_out[63:32];
                end
                mulhu: begin
                    a_in = a;
                    b_in = b;
                    f = multiplier_out[63:32];
                end
                div: begin
                    f = $signed(a) / $signed(b);
                end
                divu: begin
                    f = a / b;
                end
                rem: begin
                    f = $signed(a) % $signed(b);
                end
                remu: begin
                    f = a % b;
                end
            endcase
        end
        default: ;
    endcase
end

always_ff @(posedge clk) begin
    state <= (rst) ? idle : next_state;
end

always_comb begin
    done = 1'b0;
    next_state = state;
    mult_start = 1'b0;
    
    case(state)
        idle: begin
            if (aluop == alu_mul) begin
                case (mul_funct3_t'(funct3))
                    mul: begin
                        mult_start = mult_ready;
                        next_state = (mult_ready) ? wait_state : idle;
                    end
                    mulh: begin
                        mult_start = mult_ready;
                        next_state = (mult_ready) ? wait_state : idle;
                    end
                    mulhsu: begin
                        mult_start = mult_ready;
                        next_state = (mult_ready) ? wait_state : idle;
                    end
                    mulhu: begin
                        mult_start = mult_ready;
                        next_state = (mult_ready) ? wait_state : idle;
                    end
                    default: begin
                        done = 1'b1;
                    end
                endcase
            end else done = 1'b1;
        end
        wait_state: begin
            done = mult_done;
            next_state = (!mult_done) ? wait_state : idle;
        end
    endcase
end

add_shift_multiplier multiplier (
    .clk_i(clk), 
    .reset_n_i(~rst), 
    .multiplicand_i(a_in),
    .multiplier_i(b_in),
    .start_i(mult_start),
    .ready_o(mult_ready),
    .product_o(multiplier_out),
    .done_o(mult_done)
);

endmodule : alu