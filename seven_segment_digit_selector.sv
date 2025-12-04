///////////////////////////////////////////////////////////////////
// File: seven_segment_digit_selector.sv
// Module: seven_segment_digit_selector
// Description:
//   Generates time-multiplexed anode enable signals for the four-digit
//   seven-segment display. Implements a rotating one-hot pattern at
//   approximately 763 Hz refresh rate (100 MHz / 2^17), cycling through
//   each digit fast enough to eliminate visible flicker.
///////////////////////////////////////////////////////////////////

module seven_segment_digit_selector (
    input logic        clk,
    input logic        reset,
    output logic [3:0] digit_select,
    output logic [3:0] an_outputs
);

    logic [3:0] d, q;
    logic [16:0] count;

    // Clock divider: 100MHz / 2^17 = 762.9 Hz
    always_ff @(posedge clk) begin
        if (reset) begin
            count <= 17'b0;
        end else begin
            count <= count + 1;
        end
    end

    // Digit rotation flip-flops
    always_ff @(posedge clk) begin
        if (reset) begin
            q <= 4'b1111;
        end else if (count == 17'b0) begin
            if (q[0] && q[1]) begin
                q <= 4'b1000;
            end else begin
                q <= d;
            end
        end
    end

    // Rotate the digit select pattern
    assign d[0] = q[3];
    assign d[1] = q[0];
    assign d[2] = q[1];
    assign d[3] = q[2];

    // Output assignments
    assign digit_select = q;
    assign an_outputs = ~q;  // Invert because anodes are active-low

endmodule