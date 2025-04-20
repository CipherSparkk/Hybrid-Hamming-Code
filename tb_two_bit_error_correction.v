`timescale 1ns/1ps

module tb_two_bit_error_correction();
    // Test parameters
    reg [43:0] original_data;
    wire [43:0] interleaved_data;
    wire [104:0] encoded_data;
    reg [104:0] corrupted_data;
    wire [43:0] decoded_data;
    
    // Instance connections
    interleaver ilv (.data_in(original_data), .data_out(interleaved_data));
    two_bit_encoder encoder (.data_in(original_data), .encoded_data(encoded_data));
    two_bit_decoder decoder (.encoded_data(corrupted_data), .data_out(decoded_data));
    
    // Test control variables
    integer i, j, test_count, pass_count, error_count;
    reg [7:0] test_case_id;
    reg [104:0] error_mask;
    
    // Basic test pattern function
    function [43:0] gen_test_pattern;
        input [3:0] pattern_type;
        begin
            case(pattern_type)
                0: gen_test_pattern = 44'h0;                    // All zeros
                1: gen_test_pattern = ~44'h0;                   // All ones
                2: gen_test_pattern = 44'h555555555;            // Alternating 0,1
                3: gen_test_pattern = 44'hAAAAAAAAAAA;          // Alternating 1,0
                4: gen_test_pattern = 44'h123456789A;           // Ascending pattern
                5: gen_test_pattern = 44'hFEDCBA9876;           // Descending pattern
                6: gen_test_pattern = 44'hFF00FF00FF;           // Blocks of 1s and 0s
                7: gen_test_pattern = 44'h00FF00FF00;           // Inverse blocks
                8: gen_test_pattern = {11{4'h5}};               // Repeated nibble
                9: gen_test_pattern = {11{4'hA}};               // Repeated nibble (inverse)
                10: gen_test_pattern = 44'h00000FFFFF;          // Half zeros, half ones
                11: gen_test_pattern = 44'hFFFFF00000;          // Half ones, half zeros
                12: gen_test_pattern = 44'h11222333444;         // Grouped digits
                13: gen_test_pattern = 44'h98765ABCDE;          // Mixed hex digits
                14: gen_test_pattern = 44'h10000000001;         // Edge bits set
                15: gen_test_pattern = 44'h7FFFFFFFFFE;         // Edge bits cleared
            endcase
        end
    endfunction
    
    // Initialize simulation
    initial begin
        test_count = 0;
        pass_count = 0;
        error_count = 0;
        
        $display("\n==== TWO-BIT ERROR CORRECTION COMPREHENSIVE TEST SUITE ====");
        
        // Part 1: Test with various data patterns (no errors)
        $display("\n--- PART 1: VARIOUS DATA PATTERNS (NO ERRORS) ---");
        for (i = 0; i < 16; i = i + 1) begin
            test_case_id = i;
            original_data = gen_test_pattern(i);
            error_mask = 105'h0;
            run_test("Data Pattern Test");
        end
        
        // ... [Keep existing Parts 2-4 unchanged] ...

        $display("\n--- PART 5: 4-6 BIT ERROR TESTS (BEYOND DESIGN SPEC) ---");
        // 4-bit errors
        test_case_id = test_count;
        original_data = 44'hDEADBEEF123;
        error_mask = 105'h0;
        error_mask[0] = 1'b1;  // Column 0, bits 0-6
        error_mask[1] = 1'b1;
        error_mask[2] = 1'b1;
        error_mask[3] = 1'b1;
        run_test("4-bit error in same column (0)");

        test_case_id = test_count;
        original_data = 44'hDEADBEEF123;
        error_mask = 105'h0;
        error_mask[0]  = 1'b1;   // Column 0
        error_mask[7]  = 1'b1;   // Column 1
        error_mask[14] = 1'b1;   // Column 2
        error_mask[21] = 1'b1;   // Column 3
        run_test("4-bit error in 4 different columns");

        // 5-bit errors
        test_case_id = test_count;
        original_data = 44'hCAFEBABE789;
        error_mask = 105'h0;
        error_mask[0] = 1'b1;   // Column 0: 3 errors
        error_mask[1] = 1'b1;
        error_mask[2] = 1'b1;
        error_mask[7] = 1'b1;   // Column 1: 2 errors
        error_mask[8] = 1'b1;
        run_test("5-bit error (3 in col0, 2 in col1)");

        test_case_id = test_count;
        original_data = 44'hCAFEBABE789;
        error_mask = 105'h0;
        error_mask[0]  = 1'b1;  // Column 0
        error_mask[7]  = 1'b1;  // Column 1
        error_mask[14] = 1'b1;  // Column 2
        error_mask[21] = 1'b1;  // Column 3
        error_mask[28] = 1'b1;  // Column 4
        run_test("5-bit error in 5 different columns");

        // 6-bit errors
        test_case_id = test_count;
        original_data = 44'h123456789AB;
        error_mask = 105'h0;
        error_mask[0] = 1'b1;   // Column 0 (6 bits flipped)
        error_mask[1] = 1'b1;
        error_mask[2] = 1'b1;
        error_mask[3] = 1'b1;
        error_mask[4] = 1'b1;
        error_mask[5] = 1'b1;
        run_test("6-bit error in same column (0)");

        test_case_id = test_count;
        original_data = 44'h123456789AB;
        error_mask = 105'h0;
        error_mask[0]  = 1'b1;  // Column 0
        error_mask[7]  = 1'b1;  // Column 1
        error_mask[14] = 1'b1;  // Column 2
        error_mask[21] = 1'b1;  // Column 3
        error_mask[28] = 1'b1;  // Column 4
        error_mask[35] = 1'b1;  // Column 5
        run_test("6-bit error in 6 different columns");

        // Report overall results
        $display("\n==== TEST SUMMARY ====");
        $display("Total Tests:  %0d", test_count);
        $display("Tests Passed: %0d (%0.2f%%)", pass_count, 100.0*pass_count/test_count);
        $display("Tests Failed: %0d (%0.2f%%)", error_count, 100.0*error_count/test_count);
        
        if (pass_count == test_count)
            $display("\n✅ ALL TESTS PASSED! The implementation meets specifications.");
        else
            $display("\n❌ SOME TESTS FAILED. Implementation needs improvement.");
        
        $finish;
    end
    
    // Main test task (unchanged)
    task run_test;
        input [200:0] test_name;
        begin
            test_count = test_count + 1;
            #5; // Small delay before applying error
            corrupted_data = encoded_data ^ error_mask;
            #5; // Small delay to allow for propagation
            
            $display("\n[Test #%0d] %s", test_case_id, test_name);
            $display("Original Data:  %h", original_data);
            if (|error_mask)
                $display("Error Mask:     %h", error_mask);
            $display("Decoded Data:   %h", decoded_data);
            
            if (decoded_data === original_data) begin
                $display("✅ PASS - Data successfully recovered");
                pass_count = pass_count + 1;
            end else begin
                $display("❌ FAIL - Error not corrected correctly");
                $display("   Expected: %h", original_data);
                $display("   Got:      %h", decoded_data);
                $display("   Diff:     %h", original_data ^ decoded_data);
                error_count = error_count + 1;
            end
            
            #10; // Delay between test cases
        end
    endtask

endmodule