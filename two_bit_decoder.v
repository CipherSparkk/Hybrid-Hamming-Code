module two_bit_decoder (
    input [104:0] encoded_data,  // 105-bit input (15 columns × 7 bits)
    output [43:0] data_out       // 44-bit decoded output
);
    // Split into 15 columns of 7 bits each
    wire [6:0] columns [14:0];
    wire [2:0] error_pos [14:0]; // Track error positions
    genvar j;
    generate
        for (j = 0; j < 15; j = j + 1) begin : split_columns
            assign columns[j] = encoded_data[j*7 +: 7];  // Extract 7-bit columns
        end
    endgenerate

    // Decode each column with Hamming(7,4)
    wire [3:0] decoded_columns [14:0];      // Decoded 4-bit data per column
    wire column_error [14:0];               // Column error flags
    generate
        for (j = 0; j < 15; j = j + 1) begin : column_decoding
            hamming_decoder_7_4 col_dec (
                .codeword_in(columns[j]),
                .data_out(decoded_columns[j]),
                .error_detected(column_error[j]),
                .error_position(error_pos[j])
            );
        end
    endgenerate

    // Reconstruct rows from decoded columns (4 rows × 15 bits)
    wire [14:0] decoded_rows [3:0];  // Rows 0-3, each 15 bits wide
    generate
        for (j = 0; j < 15; j = j + 1) begin : row_reconstruction
            // Make sure bit ordering matches encoder transposition
            assign decoded_rows[0][j] = decoded_columns[14-j][0];  // Row 0
            assign decoded_rows[1][j] = decoded_columns[14-j][1];  // Row 1
            assign decoded_rows[2][j] = decoded_columns[14-j][2];  // Row 2
            assign decoded_rows[3][j] = decoded_columns[14-j][3];  // Row 3
        end
    endgenerate

    // Decode each row with Hamming(15,11)
    wire [10:0] row_data [3:0];      // Decoded 11-bit data per row
    wire row_error [3:0];            // Row error flags
    wire [3:0] row_error_pos [3:0];  // Row error positions
    generate
        for (j = 0; j < 4; j = j + 1) begin : row_decoding
            hamming_decoder_15_11 row_dec (
                .codeword_in(decoded_rows[j]),
                .data_out(row_data[j]),
                .error_detected(row_error[j]),
                .error_position(row_error_pos[j])
            );
        end
    endgenerate

    // Concatenate rows into a 44-bit output
    wire [43:0] row_reconstructed;
    assign row_reconstructed = {row_data[0], row_data[1], row_data[2], row_data[3]};
    
    // Use the deinterleaver to get the correct final output order
    deinterleaver deintlv (.data_in(row_reconstructed), .data_out(data_out));
endmodule