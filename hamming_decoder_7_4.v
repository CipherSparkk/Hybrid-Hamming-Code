module hamming_decoder_7_4(
    input [6:0] codeword_in,
    output [3:0] data_out,
    output error_detected,
    output [2:0] error_position
);
    // Internal signals
    wire [2:0] syndrome;
    wire [6:0] corrected_codeword;
    
    // Calculate syndrome bits - matching the encoder pattern exactly
    assign syndrome[0] = codeword_in[0] ^ codeword_in[1] ^ codeword_in[3] ^ codeword_in[4];
    assign syndrome[1] = codeword_in[0] ^ codeword_in[2] ^ codeword_in[3] ^ codeword_in[5];
    assign syndrome[2] = codeword_in[1] ^ codeword_in[2] ^ codeword_in[3] ^ codeword_in[6];
    
    // Error detection and position identification
    assign error_detected = |syndrome;
    
    // Map syndrome to bit position (0-6)
    // Careful mapping based on parity equations
    reg [2:0] bit_position;
    always @(*) begin
        if (syndrome == 3'b001) bit_position = 3'd4;      // Parity bit 1
        else if (syndrome == 3'b010) bit_position = 3'd5; // Parity bit 2
        else if (syndrome == 3'b011) bit_position = 3'd0; // Data bit 0
        else if (syndrome == 3'b100) bit_position = 3'd6; // Parity bit 3
        else if (syndrome == 3'b101) bit_position = 3'd1; // Data bit 1
        else if (syndrome == 3'b110) bit_position = 3'd2; // Data bit 2
        else if (syndrome == 3'b111) bit_position = 3'd3; // Data bit 3
        else bit_position = 3'd0;                        // No error
    end
    
    assign error_position = bit_position;
    
    // Apply error correction
    assign corrected_codeword = error_detected ? 
                               (codeword_in ^ (7'b1 << bit_position)) : codeword_in;
    
    // Extract data bits from corrected codeword
    assign data_out[0] = corrected_codeword[0];
    assign data_out[1] = corrected_codeword[1];
    assign data_out[2] = corrected_codeword[2];
    assign data_out[3] = corrected_codeword[3];
endmodule