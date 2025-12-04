// File: averager.sv
// Module: averager
// Description:
//   Implements a moving average filter using a shift register approach.
//   Maintains a sliding window of 2^power samples and outputs the
//   averaged value. Useful for noise reduction in ADC data streams.
//   The output updates continuously as new samples arrive when enabled.

module averager
    #(parameter int
        power = 8, //  2^8 = 256 samples
        N = 12)    // number of bits per sample
    (
        input logic clk,
        reset,
        EN,
        input logic [N-1:0] Din,   // input to averager
        output logic [N-1:0] Q     // N-bit moving average
    );

    logic [N-1:0] REG_ARRAY [2**power:1];
    logic [power+N-1:0] sum;
    assign Q = sum[power+N-1:power];

    always_ff @(posedge clk) begin
        if (reset) begin
            sum <= 0;
            for (int j = 1; j <= 2**power; j++) begin
                REG_ARRAY[j] <= 0;
            end
        end
        else if (EN) begin
            sum <= sum + Din - REG_ARRAY[2**power];
            for (int j = 2**power; j > 1; j--) begin
                REG_ARRAY[j] <= REG_ARRAY[j-1];
            end
            REG_ARRAY[1] <= Din;
        end
    end
endmodule