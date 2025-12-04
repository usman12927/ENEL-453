///////////////////////////////////////////////////////////////////
// File: pwm_ramp_adc.sv
// Module: pwm_ramp_adc
// Description:
//   Implements an 8-bit ramp-compare ADC using PWM-based DAC.
//   Generates a digital ramp that drives a PWM output for an RC
//   filter or R-2R network. An external comparator monitors when
//   the analog ramp crosses the input voltage. The module captures
//   the ramp code at this crossing point and outputs both raw
//   (0-255) and voltage-scaled (0-3300 mV) results.
///////////////////////////////////////////////////////////////////

module pwm_ramp_adc #( parameter int WIDTH = 8) (
    input  logic             clk,          // 100 MHz system clock
    input  logic             reset,        // synchronous, active-high
    input  logic             enable,       // enable conversions
    input  logic             vcompare_raw, // comparator OUT 

    output logic             pwm_out,      // PWM drive to RC filter
    output logic [WIDTH-1:0] raw_code,     // latched ADC code (0 to 255)
    output logic [15:0]      scaled_mV     // scaled 0 to 3300 mV
);

    // Synchronize comparator and detect edges
    
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

    logic vcompare_sync      = sync_ff2;
    logic high_to_low_pulse  = (vcompare_prev == 1'b1) && (vcompare_sync == 1'b0);
  

    // Digital ramp and PWM generator
    // pwm_counter runs at clk/2^WIDTH (~390 kHz for WIDTH=8)
    // ramp_code increments once per PWM period: 0,1,2,...,255,0,1,2,...
   
    logic [WIDTH-1:0] pwm_counter;
    logic [WIDTH-1:0] ramp_code;

    always_ff @(posedge clk) begin
        if (reset) begin
            pwm_counter <= '0;
            ramp_code   <= '0;
        end else if (enable) begin
            pwm_counter <= pwm_counter + 1;

            // When pwm_counter wraps, step the ramp forward
            if (pwm_counter == {WIDTH{1'b1}})
                ramp_code <= ramp_code + 1;
        end else begin
            pwm_counter <= '0;
            ramp_code   <= '0;
        end
    end

    // PWM with duty proportional to ramp_code
    always_comb begin
        if (!enable) begin
            pwm_out = 1'b0;
        end else if (ramp_code == {WIDTH{1'b1}}) begin
            pwm_out = 1'b1;
        end else begin
            pwm_out = (pwm_counter < ramp_code);
        end
    end

   
    // Latch ADC code when comparator falls
    // When sawtooth rises past Vin, comparator switches from high to low
 
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
    // raw_code_16 = raw_code * 256 (range 0-65280)
    // Then (value * 26406) >> 19 gives ~0-3300 mV
    
    logic [15:0] raw_code_16;
    logic [31:0] mult_temp;
    logic        ready_pulse;

    assign raw_code_16 = {code_reg, 8'b0};    // 0..65280
    assign ready_pulse = high_to_low_pulse;   

    always_ff @(posedge clk) begin
        if (reset) begin
            scaled_mV <= 16'd0;
        end else if (ready_pulse) begin
            mult_temp = raw_code_16 * 16'd26406;
            scaled_mV <= mult_temp[31:19];
        end
    end

endmodule