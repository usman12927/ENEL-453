///////////////////////////////////////////////////////////////////
// File: r2r_ramp_adc.sv
// Module: r2r_ramp_adc
// Description:
//   Implements an 8-bit ramp-compare ADC using an R-2R ladder DAC.
//   Generates a digital ramp that directly drives the R-2R ladder
//   bits. An external comparator monitors when the analog output
//   crosses the input voltage. The module latches the ramp code on
//   the high-to-low edge and scales the result to 0-3300 mV.
///////////////////////////////////////////////////////////////////

module r2r_ramp_adc #(parameter int WIDTH = 8) (
    input  logic             clk,          // 100 MHz system clock
    input  logic             reset,        // synchronous, active-high
    input  logic             enable,       // enable conversions
    input  logic             vcompare_raw, // comparator OUT for R-2R ADC

    output logic [WIDTH-1:0] r2r_out,      // to R-2R ladder (JA10..JA1)
    output logic [WIDTH-1:0] raw_code,     // latched ADC code (0..255)
    output logic [15:0]      scaled_mV     // scaled 0-3300 mV
);

    // Synchronize comparator and detect high->low edge
    logic sync_ff1, sync_ff2;
    logic vcompare_prev;

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

    logic vcompare_sync     = sync_ff2;
    logic high_to_low_pulse = (vcompare_prev == 1'b1) && (vcompare_sync == 1'b0);

    // Digital ramp generator
    // ramp_code steps once per period: 0,1,2,...255,0,1,2,...
    logic [WIDTH-1:0] step_counter;
    logic [WIDTH-1:0] ramp_code;

    always_ff @(posedge clk) begin
        if (reset) begin
            step_counter <= '0;
            ramp_code    <= '0;
        end else if (enable) begin
            step_counter <= step_counter + 1;

            if (step_counter == {WIDTH{1'b1}})
                ramp_code <= ramp_code + 1;
        end else begin
            step_counter <= '0;
            ramp_code    <= '0;
        end
    end

    // Drive the R-2R ladder with the current ramp code
    assign r2r_out = ramp_code;

    // Latch ADC result when comparator falls (V_DAC crosses Vin)
    logic [WIDTH-1:0] code_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            code_reg <= '0;
        end else if (enable && high_to_low_pulse) begin
            code_reg <= ramp_code;
        end
    end

    assign raw_code = code_reg;

    // Scale raw_code to 0-3300 mV
    logic [15:0] raw_code_16;
    logic [31:0] mult_temp;
    logic        ready_pulse;

    assign raw_code_16 = {code_reg, 8'b0};   // *256 -> 0..65280
    assign ready_pulse = high_to_low_pulse;

    always_ff @(posedge clk) begin
        if (reset) begin
            scaled_mV <= 16'd0;
        end else if (ready_pulse) begin
            // (value * 26406) >> 19 ≈ 0..3300 mV
            mult_temp = raw_code_16 * 16'd26406;
            scaled_mV <= mult_temp[31:19];
        end
    end

endmodule