///////////////////////////////////////////////////////////////////
// File: display_controller.sv
// Module: display_controller
// Description:
//   Controls the seven-segment display based on slide switch inputs.
//   Selects one of nine ADC measurement modes (XADC, PWM, R2R - each
//   with raw, scaled, and averaged variants). SW9 overrides the display
//   format: when SW9=1, forces decimal display; when SW9=0, uses the
//   default format for each mode. Multiple mode switches active shows
//   an error pattern. Values are mirrored on LEDs.
///////////////////////////////////////////////////////////////////

module display_controller (
    input  logic        clk,
    input  logic        reset,

    input  logic [9:0]  sw,   // SW0..SW9

    // XADC values (16-bit)
    input  logic [15:0] xadc_raw_16,
    input  logic [15:0] xadc_scaled_mV,
    input  logic [15:0] xadc_avg_16,

    // PWM values (16-bit)
    input  logic [15:0] pwm_raw_16,
    input  logic [15:0] pwm_scaled_mV,
    input  logic [15:0] pwm_avg_16,

    // R2R values (16-bit)
    input  logic [15:0] r2r_raw_16,
    input  logic [15:0] r2r_scaled_mV,
    input  logic [15:0] r2r_avg_16,

    // LEDs
    output logic [15:0] led,

    // Seven-seg
    output logic        CA, CB, CC, CD, CE, CF, CG, DP,
    output logic        AN1, AN2, AN3, AN4
);

    // Count how many mode switches (SW0-SW8) are ON
    logic [3:0] sw_count;

    always_comb begin
        sw_count = '0;
        for (int i = 0; i < 9; i++) begin
            sw_count = sw_count + sw[i];
        end
    end

    logic [15:0] selected_value;
    logic        default_format;   // Default format for each mode (0=hex, 1=decimal)
    logic        use_decimal;      // Final format (0=hex, 1=decimal)
    logic        is_voltage_mode;  // True for scaled voltage modes (SW1, SW4, SW7)

    localparam logic [15:0] ERR_CODE = 16'hEEEE;

    // Selection logic
    always_comb begin
        selected_value = 16'h0000;
        default_format = 1'b0;
        is_voltage_mode = 1'b0;

        if (sw_count == 0) begin
            // All switches off -> show 0000
            selected_value = 16'h0000;
            default_format = 1'b0;
            is_voltage_mode = 1'b0;
        end
        else if (sw_count > 1) begin
            // Invalid combo -> error pattern
            selected_value = ERR_CODE;
            default_format = 1'b0;
            is_voltage_mode = 1'b0;
        end
        else begin
            // Exactly one switch is ON
            unique case (sw[8:0])
                9'b000000001: begin
                    // SW0: XADC RAW (0..0FFF), default hex
                    selected_value = xadc_raw_16;
                    default_format = 1'b0;
                    is_voltage_mode = 1'b0;
                end
                9'b000000010: begin
                    // SW1: XADC SCALED (0..3.3 V), default decimal mV with DP
                    selected_value = xadc_scaled_mV;
                    default_format = 1'b1;
                    is_voltage_mode = 1'b1;  // Voltage - keep decimal point
                end
                9'b000000100: begin
                    // SW2: XADC AVERAGED (0..0FFF), default hex
                    selected_value = xadc_avg_16;
                    default_format = 1'b0;
                    is_voltage_mode = 1'b0;
                end
                9'b000001000: begin
                    // SW3: PWM RAW (0..00FF), default hex
                    selected_value = pwm_raw_16;
                    default_format = 1'b0;
                    is_voltage_mode = 1'b0;
                end
                9'b000010000: begin
                    // SW4: PWM SCALED (0..3.3 V), default decimal mV with DP
                    selected_value = pwm_scaled_mV;
                    default_format = 1'b1;
                    is_voltage_mode = 1'b1;  // Voltage - keep decimal point
                end
                9'b000100000: begin
                    // SW5: PWM AVERAGED (0..00FF), default hex
                    selected_value = pwm_avg_16;
                    default_format = 1'b0;
                    is_voltage_mode = 1'b0;
                end
                9'b001000000: begin
                    // SW6: R2R RAW (0..00FF), default hex
                    selected_value = r2r_raw_16;
                    default_format = 1'b0;
                    is_voltage_mode = 1'b0;
                end
                9'b010000000: begin
                    // SW7: R2R SCALED (0..3.3 V), default decimal mV with DP
                    selected_value = r2r_scaled_mV;
                    default_format = 1'b1;
                    is_voltage_mode = 1'b1;  // Voltage - keep decimal point
                end
                9'b100000000: begin
                    // SW8: R2R AVERAGED (0..00FF), default hex
                    selected_value = r2r_avg_16;
                    default_format = 1'b0;
                    is_voltage_mode = 1'b0;
                end
                default: begin
                    selected_value = 16'h0000;
                    default_format = 1'b0;
                    is_voltage_mode = 1'b0;
                end
            endcase
        end
    end

    // SW9 overrides format: SW9=1 forces decimal, SW9=0 uses default
    assign use_decimal = sw[9] ? 1'b1 : default_format;

    // LEDs reflect the selected value
    assign led = selected_value;

    // Convert to BCD when in decimal mode
    logic [15:0] bcd_value;

    bin_to_bcd BIN2BCD (
        .clk     (clk),
        .reset   (reset),
        .bin_in  (selected_value),
        .bcd_out (bcd_value)
    );

    logic [15:0] mux_out;
    logic [3:0]  decimal_point;

    // Hex vs decimal select
    mux4_16_bits DISP_MUX (
        .in0    (selected_value),          // hex mode
        .in1    (bcd_value),               // decimal mode
        .in2    (16'h0000),
        .in3    (16'h0000),
        .select ({1'b0, use_decimal}),     // 00=hex, 01=decimal
        .mux_out(mux_out),
        .decimal_point()                   // Not used, controlled below
    );

    // Decimal point only for voltage modes (SW1, SW4, SW7)
    // These show actual voltage in mV with X.XXX format
    assign decimal_point = is_voltage_mode ? 4'b1000 : 4'b0000;

    // Seven-seg subsystem
    seven_segment_display_subsystem SEVEN_SEG (
        .clk           (clk),
        .reset         (reset),
        .sec_dig1      (mux_out[3:0]),
        .sec_dig2      (mux_out[7:4]),
        .min_dig1      (mux_out[11:8]),
        .min_dig2      (mux_out[15:12]),
        .decimal_point (decimal_point),
        .CA            (CA), .CB(CB), .CC(CC), .CD(CD),
        .CE            (CE), .CF(CF), .CG(CG), .DP(DP),
        .AN1           (AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );

endmodule