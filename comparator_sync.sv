///////////////////////////////////////////////////////////////////
// File: comparator_sync.sv
// Module: comparator_sync
// Description:
//   Synchronizes asynchronous external comparator output to the FPGA
//   clock domain using a two-flip-flop synchronizer. Generates
//   single-clock pulses on rising and falling edges. These pulses
//   are used by ramp-compare ADC modules to latch conversion results
//   at the precise moment the analog ramp crosses the input voltage.
///////////////////////////////////////////////////////////////////

module comparator_sync (
    input  logic clk,
    input  logic reset,          // synchronous, active high
    input  logic vcompare_raw,   // from comparator output pin
    output logic vcompare_sync,  // synchronized version
    output logic high_to_low_pulse,
    output logic low_to_high_pulse
);

    logic sync_ff1, sync_ff2;
    logic vcompare_prev;

    // 2-FF synchronizer and previous-state register
    always_ff @(posedge clk) begin
        if (reset) begin
            sync_ff1      <= 1'b0;
            sync_ff2      <= 1'b0;
            vcompare_prev <= 1'b0;
        end else begin
            sync_ff1      <= vcompare_raw;
            sync_ff2      <= sync_ff1;
            vcompare_prev <= sync_ff2;
        end
    end

    assign vcompare_sync     = sync_ff2;
    assign high_to_low_pulse = (vcompare_prev == 1'b1) && (sync_ff2 == 1'b0);
    assign low_to_high_pulse = (vcompare_prev == 1'b0) && (sync_ff2 == 1'b1);

endmodule