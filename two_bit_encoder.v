// Modified two_bit_encoder.v
module two_bit_encoder (
    input [43:0] data_in,
    output [104:0] encoded_data
);
    // First interleave the data
    wire [43:0] interleaved_data;
    interleaver ilv (.data_in(data_in), .data_out(interleaved_data));

    // Extract rows from interleaved_data (4 rows of 11 bits each)
    wire [10:0] row0, row1, row2, row3;
    
    // Correct row extraction - each row is 11 bits
    assign row0 = interleaved_data[43:33]; // Most significant 11 bits
    assign row1 = interleaved_data[32:22];
    assign row2 = interleaved_data[21:11];
    assign row3 = interleaved_data[10:0];  // Least significant 11 bits

    // Encode each row with Hamming(15,11)
    wire [14:0] encoded_row0, encoded_row1, encoded_row2, encoded_row3;
    hamming_encoder_15_11 row0_enc (.data_in(row0), .codeword_out(encoded_row0));
    hamming_encoder_15_11 row1_enc (.data_in(row1), .codeword_out(encoded_row1));
    hamming_encoder_15_11 row2_enc (.data_in(row2), .codeword_out(encoded_row2));
    hamming_encoder_15_11 row3_enc (.data_in(row3), .codeword_out(encoded_row3));

    // Transpose 4x15 matrix to 15 columns of 4 bits each and encode
    genvar i;
    generate
        for (i = 0; i < 15; i = i + 1) begin : column_encoding
            wire [3:0] col_data;
            // Put bits from each encoded row into one column
            assign col_data = {
                encoded_row0[14-i],  // Reverse bit order for proper column alignment
                encoded_row1[14-i],
                encoded_row2[14-i],
                encoded_row3[14-i]   
            };
            wire [6:0] encoded_col;
            hamming_encoder_7_4 col_enc (
                .data_in(col_data),
                .codeword_out(encoded_col)
            );
            assign encoded_data[i*7 +: 7] = encoded_col;
        end
    endgenerate
endmodule