///////////////////////////////////////////////////////////////////
// File: seven_segment_display_subsystem.sv
// Module: seven_segment_display_subsystem
// Description:
//   Top-level wrapper for seven-segment display control. Integrates
//   the digit selector, multiplexor, and decoder modules to drive
//   the Basys3 four-digit display. Accepts four 4-bit digit values
//   and decimal point controls, then time-multiplexes them across
//   the display segments and anodes.
///////////////////////////////////////////////////////////////////

module seven_segment_display_subsystem (
    input  logic        clk,
    input  logic        reset,
    input  logic [3:0]  sec_dig1, // seconds digit 
    input  logic [3:0]  sec_dig2, // tens of seconds
    input  logic [3:0]  min_dig1, // minutes digit 
    input  logic [3:0]  min_dig2, // tens of minutes
    input  logic [3:0] decimal_point, 
    output logic        CA, CB, CC, CD, CE, CF, CG, DP, // segment outputs 
    output logic        AN1, AN2, AN3, AN4 // anode outputs for digit selection 
);

    // Internal signals
    logic [3:0] digit_to_display;
    logic [3:0] digit_select;
    logic [3:0] an_outputs;
    logic       in_DP, out_DP;

    // Digit multiplexor
    digit_multiplexor DIGIT_MUX (
        .sec_dig1(  sec_dig1),  // input for seconds digit (units)
        .sec_dig2(  sec_dig2),  // input for tens of seconds digit
        .min_dig1(  min_dig1),  // input for minutes digit (units)
        .min_dig2(  min_dig2),  // input for tens of minutes digit
        .selector(  digit_select), // one-hot selector for the digit
        .decimal_point(decimal_point),
        .time_digit(digit_to_display),  // 4-bit digit output to display
        .dp_in(in_DP)
    );

    // Digit selector
    seven_segment_digit_selector DIGIT_SELECTOR (
        .clk(         clk),
        .reset(       reset),
        .digit_select(digit_select), // one-hot encoded digit select
        .an_outputs(  an_outputs)    // active-low anode controls
    );

    // Seven segment decoder
    seven_segment_decoder SEG_DECODER (
        .data( digit_to_display), // 4-bit BCD digit to display
        .dp_in( in_DP),           // Decimal point control
        .CA( CA), .CB( CB), .CC( CC), .CD( CD), .CE( CE), .CF( CF), .CG( CG),
        .DP( out_DP)
    );

    // Connect anodes
    assign AN1 = an_outputs[0];
    assign AN2 = an_outputs[1];
    assign AN3 = an_outputs[2];
    assign AN4 = an_outputs[3];

    assign DP = out_DP;

endmodule