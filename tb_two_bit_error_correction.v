`timescale 1ns/1ps
module tb_two_bit_error_correction();

reg [43:0] original_data;
wire [43:0] interleaved_data;
wire [104:0] encoded_data;
reg [104:0] corrupted_data; 
wire [43:0] decoded_data;

interleaver ilv (.data_in(original_data), .data_out(interleaved_data));
two_bit_encoder encoder (.data_in(original_data), .encoded_data(encoded_data));
two_bit_decoder decoder (.encoded_data(corrupted_data), .data_out(decoded_data)); // Use corrupted_data

// Error injection parameters
reg inject_error;
reg [6:0] error_bit;

// Test procedure
initial begin
    // Test Case 1: Single-bit error in column 0 (correctable)
    $display("===== TEST CASE 1: SINGLE-BIT ERROR (COLUMN 0) =====");
    original_data = 44'h123456789AB;
    inject_error = 1'b1;
    error_bit = 0; // Flip bit 0 of column 0
    #10;
    verify();

    // Test Case 2: Two-bit error in column 5 (uncorrectable)
    $display("\n\n===== TEST CASE 2: TWO-BIT ERROR (COLUMN 5) =====");
    original_data = 44'hAAAAAAAAAAA;
    inject_error = 1'b1;
    error_bit = 5; // Flip bits 5 and 6 of column 5
    #10;
    verify();

    $finish;
end

// Error injection logic
always @(*) begin
    if (inject_error) begin
        corrupted_data = encoded_data;
        // Flip bits based on test case
        case (error_bit)
            0: corrupted_data[0] = ~encoded_data[0]; // Single-bit flip
            5: begin
                corrupted_data[5*7 + 5] = ~encoded_data[5*7 + 5]; // Bit 5
                corrupted_data[5*7 + 6] = ~encoded_data[5*7 + 6]; // Bit 6
            end
        endcase
    end else begin
        corrupted_data = encoded_data;
    end
end

task verify;
    begin
        $display("=== STAGE 1: INTERLEAVING ===");
        $display("Original:    %h", original_data);
        $display("Interleaved: %h", interleaved_data);

        $display("\n=== STAGE 2: ENCODING ===");
        $display("Encoded:     %h", encoded_data);
        $display("Corrupted:   %h", corrupted_data);

        $display("\n=== STAGE 3: DECODING ===");
        $display("Decoded:     %h", decoded_data);

        $display("\n=== VERIFICATION ===");
        if (decoded_data === original_data) begin
            $display("PASS: Error corrected");
        end else begin
            $display("FAIL: Error not corrected");
        end
    end
endtask

endmodule
