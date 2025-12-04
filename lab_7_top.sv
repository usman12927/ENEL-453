//
// File: lab_7_top.sv
// Module: lab_7_top
// Description:
//   Top-level module for Lab 7 ADC Comparison Project.
//   Integrates three ADC systems for analog voltage measurement:
//     - XADC (Xilinx built-in 12-bit ADC)
//     - PWM-based ramp ADC (8-bit)
//     - R2R ladder ramp ADC (8-bit)
//   Each system provides raw, averaged, and voltage-scaled outputs.
//   Display selection via slide switches SW0-SW8.
//   SW9 provides format override (0=default, 1= change to decimal value).
//

module lab_7_top (
    input  logic        clk,
    input  logic        reset,

    // Slide switches SW0..SW9
    input  logic [9:0]  sw,

    // XADC analog pins
    input               vauxp15,
    input               vauxn15,

    // Comparator outputs
    input               vcompare_raw,      // PWM comparator out
    input               vcompare_r2r_raw,  // R2R comparator out

    // Seven-seg display
    output logic        CA, CB, CC, CD, CE, CF, CG, DP,
    output logic        AN1, AN2, AN3, AN4,

    // LEDs
    output logic [15:0] led,

    // PWM analog output
    output logic        pwm_out,

    // R2R ladder outputs 
    output logic [7:0]  r2r_out
);

    
    // XADC subsystem
    logic [15:0] xadc_raw_16;
    logic [15:0] xadc_avg_16;
    logic [15:0] xadc_scaled_mV;

    adc_subsystem XADC_SUB (
        .clk                 (clk),
        .reset               (reset),
        .vauxp15             (vauxp15),
        .vauxn15             (vauxn15),
        .raw_adc_data        (xadc_raw_16),      // 0..0FFF
        .averaged_adc_data   (xadc_avg_16),      // 0..FFF0
        .scaled_voltage_data (xadc_scaled_mV)    // 0..3300 mV
    );

    
    // PWM ramp-compare ADC
    logic [7:0]  pwm_raw_code;    // 0..00FF
    logic [15:0] pwm_scaled_mV;   // 0..3300 mV

    pwm_ramp_adc #(.WIDTH(8)) PWM_ADC (
        .clk          (clk),
        .reset        (reset),
        .enable       (1'b1),
        .vcompare_raw (vcompare_raw),
        .pwm_out      (pwm_out),
        .raw_code     (pwm_raw_code),
        .scaled_mV    (pwm_scaled_mV)
    );
    logic [15:0] pwm_raw_16;
    assign pwm_raw_16 = {8'b0, pwm_raw_code};

  
    // R2R ramp-compare ADC
    logic [7:0]  r2r_raw_code;    // 0..00FF
    logic [15:0] r2r_scaled_mV;   // 0..3300 mV

    r2r_ramp_adc #(.WIDTH(8)) R2R_ADC (
        .clk          (clk),
        .reset        (reset),
        .enable       (1'b1),
        .vcompare_raw (vcompare_r2r_raw),
        .r2r_out      (r2r_out),
        .raw_code     (r2r_raw_code),
        .scaled_mV    (r2r_scaled_mV)
    );

    logic [15:0] r2r_raw_16;
    assign r2r_raw_16 = {8'b0, r2r_raw_code};

    // PWM averaged
    logic [7:0]  pwm_avg_8;
    logic [15:0] pwm_avg_16;

    averager #(
        .power(8),   // 2^8 = 256-sample moving average
        .N(8)
    ) PWM_AVG (
        .clk   (clk),
        .reset (reset),
        .EN    (1'b1),           // always enabled; averages continuously
        .Din   (pwm_raw_code),
        .Q     (pwm_avg_8)
    );

    assign pwm_avg_16 = {8'b0, pwm_avg_8};   // 0..00FF

    // R2R averaged
    logic [7:0]  r2r_avg_8;
    logic [15:0] r2r_avg_16;

    averager #(
        .power(8),  
        .N(8)
    ) R2R_AVG (
        .clk   (clk),
        .reset (reset),
        .EN    (1'b1),
        .Din   (r2r_raw_code),
        .Q     (r2r_avg_8)
    );

    assign r2r_avg_16 = {8'b0, r2r_avg_8};   // 0..00FF

    // Display controller: chooses which of the 9 values to show
    display_controller DISP (
        .clk            (clk),
        .reset          (reset),
        .sw             (sw),
        .xadc_raw_16    (xadc_raw_16),
        .xadc_scaled_mV (xadc_scaled_mV),
        .xadc_avg_16    (xadc_avg_16),
        .pwm_raw_16     (pwm_raw_16),
        .pwm_scaled_mV  (pwm_scaled_mV),
        .pwm_avg_16     (pwm_avg_16),
        .r2r_raw_16     (r2r_raw_16),
        .r2r_scaled_mV  (r2r_scaled_mV),
        .r2r_avg_16     (r2r_avg_16),
        .led            (led),
        .CA             (CA), .CB(CB), .CC(CC), .CD(CD),
        .CE             (CE), .CF(CF), .CG(CG), .DP(DP),
        .AN1            (AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );

endmodule