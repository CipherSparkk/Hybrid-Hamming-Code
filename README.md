System Architecture

  1. Encoder (two_bit_encoder.v):
    
      a. Interleaving: Rearranges the 44-bit input into a 4×11 matrix to spread burst errors.
      b. Row Encoding: Each row is encoded using Hamming(15,11), adding 4 parity bits per row (total 60 bits).
      c. Transposition: Converts the 4×15 matrix to 15 columns of 4 bits each.
      d. Column Encoding: Each column is encoded using Hamming(7,4), adding 3 parity bits per column (total 105 bits).


  2. Decoder (two_bit_decoder.v):

      a. Column Decoding: Corrects single-bit errors in each 7-bit column using Hamming(7,4).
      b. Transposition: Reconstructs the 4×15 row matrix.
      c. Row Decoding: Corrects residual errors in each 15-bit row using Hamming(15,11).
      d. Deinterleaving: Reverses the interleaving to recover the original 44-bit data.


  3. Error Correction Mechanism

      a. Single-Bit Errors: Detected and corrected by column/row decoders using syndrome calculations.
      b. Two-Bit Errors:
          Same Column: Corrected by row decoders after deinterleaving (errors spread to different rows).
          Different Columns: Corrected by column decoders.
          Limitations: Fails for ≥3 errors in the same column/row due to Hamming code constraints.

     
  4. Testbench Validation

       a. Error Mask: A 105-bit vector used only in simulation to inject errors into the encoded data (e.g., flipping bits 0 and 3).
       b. Validation: Compares decoded_data with original_data to verify correction. Tests include:
                      No errors (baseline).
                      Single-bit, two-bit, and multi-bit errors (up to 6 bits).
       c. Strategic placements (same/different rows/columns).


  5. Key Features

      a. Redundancy: 44-bit input → 105-bit encoded output (138% overhead for reliability).
      b. Automatic Correction: No user input needed; decoders use parity bits to detect/correct errors.
      c. Real-World Use: Suitable for noisy channels (e.g., wireless communication, storage systems).


  6. Strengths & Limitations

      a. Strengths: Corrects one and two errors and even multiple bit errors under most configurations.
      b. Low complexity compared to advanced codes like LDPC/Reed-Solomon.
   
      Limitations: High redundancy.
