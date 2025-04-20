module hamming_encoder_15_11 (
    input  [10:0] data_in,    // 11-bit input
    output [14:0] codeword_out    // 15-bit Hamming encoded output
);

wire p1, p2, p4, p8;

assign codeword_out[2]  = data_in[10];  // D1
assign codeword_out[4]  = data_in[9];  // D2
assign codeword_out[5]  = data_in[8];  // D3
assign codeword_out[6]  = data_in[7];  // D4
assign codeword_out[8]  = data_in[6];  // D5
assign codeword_out[9]  = data_in[5];  // D6
assign codeword_out[10] = data_in[4];  // D7
assign codeword_out[11] = data_in[3];  // D8
assign codeword_out[12] = data_in[2];  // D9
assign codeword_out[13] = data_in[1];  // D10
assign codeword_out[14] = data_in[0]; // D11

// Calculate parity bits (even parity)
assign p1 = codeword_out[2] ^ codeword_out[4] ^ codeword_out[6] ^ codeword_out[8] ^ codeword_out[10] ^ codeword_out[12] ^ codeword_out[14];

assign p2 = codeword_out[2] ^ codeword_out[5] ^ codeword_out[6] ^ codeword_out[9] ^ codeword_out[10] ^ codeword_out[13] ^ codeword_out[14];

assign p4 = codeword_out[4] ^ codeword_out[5] ^ codeword_out[6] ^ codeword_out[11] ^ codeword_out[12] ^ codeword_out[13] ^ codeword_out[14];

assign p8 = codeword_out[8] ^ codeword_out[9] ^ codeword_out[10] ^ codeword_out[11] ^ codeword_out[12] ^ codeword_out[13] ^ codeword_out[14];

// Assign parity bits to respective positions
assign codeword_out[0] = p1; // P1
assign codeword_out[1] = p2; // P2
assign codeword_out[3] = p4; // P4
assign codeword_out[7] = p8; // P8

endmodule
