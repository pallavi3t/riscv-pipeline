import rv32i_types::*;

module multiplier
(
    input logic [31:0] a, b,
    output logic [63:0] f
);
// Internal Signal
logic partial_product[31:0][31:0];
logic triangle[8][31:0][62:0];
logic C[8][63][9];
logic C_0[63];

assign f[0] = triangle[0][0][0];

genvar i, j;
generate
    for (i = 0; i < 32; i++) begin : partial_product_outer
        for (j = 0; j < 32; j++) begin : partial_product_inner
            assign partial_product[7][i][j] = a[i] & b[j];
        end
    end
    for (i = 0; i < 32; i++) begin : triangle_outer
        for (j = 0; j < 63; j++) begin : triangle_outer
            assign triangle[7][i][j] = (j < 33) ? partial_product[i][j - i] : partial_product[j + i - 32][32 - i];
        end
    end
endgenerate

int stage[9];
initial begin
    stage[0] = 2;
    stage[1] = 3;
    stage[2] = 4;
    stage[3] = 6;
    stage[4] = 9;
    stage[5] = 13;
    stage[6] = 19;
    stage[7] = 28;
    stage[8] = 32;
end

genvar k, l;
int layers, num_bits, total_bits, num_carry, num_carry_left;
logic is_top_fa;
generate
    for (j = 7; j > -1; j--) begin : stage_block
        layers = stage[j + 1] - stage[j];
        for (k = 0; k < stage[j]; k++) begin : layer_block
            num_bits = (k < stage[j]) ? 63 - (2 * k) : 63 - (2 * stage[j]) - (k - stage[j]);
            for (i = 0; i < num_bits; i++) begin : column_block
                num_carry = i - stage[j];
                num_carry_left = (63 - stage[j]) - i;
                if (i > stage[j] & i < 63 - stage[j]) begin
                    if (num_carry <= layers & num_carry > k) // Columns where number of adders is increasing
                        for (l = 0; l < num_carry; l++) begin : row_block
                            assign C[j][i][l] = (!l) ? triangle[j + 1][k][i] & triangle[j + 1][k + stage[j]][i] : 
                              (triangle[j + 1][k][i] & triangle[j + 1][k + stage[j]][i]) | (C[j][i - 1][l - 1] &
                              (triangle[j + 1][k][i] ^ triangle[j + 1][k + stage[j]][i]));
                            assign triangle[j][k][i] = (!l) ? (triangle[j + 1][k][i] ^ triangle[j + 1][k + stage[j]][i]) :
                              (triangle[j + 1][k][i] ^ triangle[j + 1][k + stage[j]][i]) ^ C[j][i - 1][l - 1];
                        end
                    else if (num_carry > layers & i < 64 - stage[j] - layers & layers > k) begin // Columns where number of adders is constant
                        is_top_fa = j != 7;
                        for (l = 0; l < layers; l++) begin : row_block_1
                            assign C[j][i][l] = (!l & !is_top_fa) ? triangle[j + 1][k][i] & triangle[j + 1][k + stage[j]][i] : 
                              (triangle[j + 1][k][i] & triangle[j + 1][k + stage[j]][i]) | (C[j][i - 1][l - 1] &
                              (triangle[j + 1][k][i] ^ triangle[j + 1][k + stage[j]][i]));
                            assign triangle[j][k][i] = (!l & !is_top_fa) ? (triangle[j + 1][k][i] ^ triangle[j + 1][k + stage[j]][i]) :
                              (triangle[j + 1][k][i] ^ triangle[j + 1][k + stage[j]][i]) ^ C[j][i - 1][l - 1];
                        end
                    end else if (i >= 64 - stage[j] - layers & num_carry_left < layers) // Columns where number of adders is decreasing
                        for (l = 0; l < num_carry_left; l++) begin : row_block_2
                            assign C[j][i][l] = (triangle[j + 1][k][i] & triangle[j + 1][k + stage[j]][i]) | (C[j][i - 1][l - 1] &
                              (triangle[j + 1][k][i] ^ triangle[j + 1][k + stage[j]][i]));
                            assign triangle[j][k][i] = triangle[j + 1][k][i] ^ triangle[j + 1][k + stage[j]][i] ^ C[j][i - 1][l - 1];
                        end
                    else
                        assign triangle[j][k][i] = triangle[j+1][k][i];
                end
                else
                    assign triangle[j][k][i] = triangle[j+1][k][i];
            end
        end
    end
    for (i = 0; i < 62; i++) begin : output_block
        assign C_0 = (!i) ? (triangle[0][0][i] & triangle[0][1][i]) | (C_0[i - 1] & (triangle[0][0][i] ^ triangle[0][1][i])) 
            : (triangle[0][0][i] & triangle[0][1][i]);
        assign f[1 + i] = (!i) ? (C_0[i - 1] ^ triangle[0][0][i] ^ triangle[0][1][i]) : triangle[0][0][i] ^ triangle[0][1][i];
    end
    assign f[63] = C_0[62];
endgenerate

endmodule multiplier
