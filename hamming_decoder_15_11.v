module hamming_decoder_15_11(
    input [14:0] codeword_in,
    output [10:0] data_out,
    output error_detected,
    output [3:0] error_position
);
    // Calculate syndrome bits
    wire [3:0] syndrome;
    
    // Calculating syndrome matching the encoder parity generation
    assign syndrome[0] = codeword_in[0] ^ codeword_in[2] ^ codeword_in[4] ^ codeword_in[6] ^ 
                        codeword_in[8] ^ codeword_in[10] ^ codeword_in[12] ^ codeword_in[14];
    assign syndrome[1] = codeword_in[1] ^ codeword_in[2] ^ codeword_in[5] ^ codeword_in[6] ^ 
                        codeword_in[9] ^ codeword_in[10] ^ codeword_in[13] ^ codeword_in[14];
    assign syndrome[2] = codeword_in[3] ^ codeword_in[4] ^ codeword_in[5] ^ codeword_in[6] ^ 
                        codeword_in[11] ^ codeword_in[12] ^ codeword_in[13] ^ codeword_in[14];
    assign syndrome[3] = codeword_in[7] ^ codeword_in[8] ^ codeword_in[9] ^ codeword_in[10] ^ 
                        codeword_in[11] ^ codeword_in[12] ^ codeword_in[13] ^ codeword_in[14];

    // Error detection
    assign error_detected = |syndrome;
    
    // Map syndrome to bit position (0-14)
    reg [3:0] bit_position;
    always @(*) begin
        case(syndrome)
            4'b0001: bit_position = 4'd0;  // P1
            4'b0010: bit_position = 4'd1;  // P2
            4'b0011: bit_position = 4'd2;  // D1
            4'b0100: bit_position = 4'd3;  // P4
            4'b0101: bit_position = 4'd4;  // D2
            4'b0110: bit_position = 4'd5;  // D3
            4'b0111: bit_position = 4'd6;  // D4
            4'b1000: bit_position = 4'd7;  // P8
            4'b1001: bit_position = 4'd8;  // D5
            4'b1010: bit_position = 4'd9;  // D6
            4'b1011: bit_position = 4'd10; // D7
            4'b1100: bit_position = 4'd11; // D8
            4'b1101: bit_position = 4'd12; // D9
            4'b1110: bit_position = 4'd13; // D10
            4'b1111: bit_position = 4'd14; // D11
            default: bit_position = 4'd0;  // No error
        endcase
    end
    
    assign error_position = bit_position;
    
    // Correct single-bit errors
    wire [14:0] corrected_codeword = error_detected ? 
                                    (codeword_in ^ (15'b1 << bit_position)) : codeword_in;
    
    // Extract data bits in the correct order
    assign data_out = {
        corrected_codeword[14], // D11
        corrected_codeword[13], // D10
        corrected_codeword[12], // D9
        corrected_codeword[11], // D8
        corrected_codeword[10], // D7
        corrected_codeword[9],  // D6
        corrected_codeword[8],  // D5
        corrected_codeword[6],  // D4
        corrected_codeword[5],  // D3
        corrected_codeword[4],  // D2
        corrected_codeword[2]   // D1
    };
endmodule