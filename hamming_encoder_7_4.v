module hamming_encoder_7_4(
    input [3:0] data_in,
    output [6:0] codeword_out
);
    // Internal signals
    wire [2:0] parity;
    
    // Place data bits
    assign codeword_out[0] = data_in[0];
    assign codeword_out[1] = data_in[1];
    assign codeword_out[2] = data_in[2];
    assign codeword_out[3] = data_in[3];
    // Calculate parity bits
    assign parity[0] = codeword_out[0] ^ codeword_out[1] ^ codeword_out[3];
    
    assign parity[1] = codeword_out[0] ^ codeword_out[2] ^ codeword_out[3];
    
    assign parity[2] = codeword_out[1] ^ codeword_out[2] ^ codeword_out[3];
    
    // Place parity bits
    assign codeword_out[4] = parity[0];  // p1
    assign codeword_out[5] = parity[1];  // p2
    assign codeword_out[6] = parity[2];  // p4
    
    
    
endmodule