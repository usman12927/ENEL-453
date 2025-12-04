// File: adc_subsystem.sv
// Module: adc_subsystem
// Description:
//   Wrapper for the Xilinx XADC primitive with integrated averaging
//   and voltage scaling. Configured for 1024-sample averaging window
//   for fast synthesis while maintaining good noise rejection.
//   Outputs raw 12-bit codes, 16-bit averaged codes, and voltage
//   values scaled to millivolts (0-3300 mV range).

module adc_subsystem (
    input  logic        clk,
    input  logic        reset,
    input               vauxp15,
    input               vauxn15,
    

    // outputs to top-level / display
    output logic [15:0] raw_adc_data,        // 0x0000 .. 0x0FFF (12-bit result)
    output logic [15:0] averaged_adc_data,   // 0x0000 .. 0xFFF0 (16-bit result)
    output logic [15:0] scaled_voltage_data  // 0 .. 3300 mV
);

    // Internal signals
    localparam CHANNEL_ADDR = 7'h1f;      // VAUXP/N15 channel address

    logic [15:0] xadc_do;                 // raw 16-bit XADC word (0x0000..0xFFF0)
    logic [11:0] ave_data_12b;            // 12-bit averaged data
    logic [15:0] ave_data_16b;            // 16-bit left-justified averaged data

    logic        ready;                   // DRDY from XADC
    logic        enable;                  // EOC used as DEN
    logic        ready_r, ready_pulse;    // edge-detector for DRDY
    logic [31:0] scaled_temp;

    // XADC instantiation
    xadc_wiz_0 XADC_INST (
        .di_in     (16'h0000),
        .daddr_in  (CHANNEL_ADDR),
        .den_in    (enable),
        .dwe_in    (1'b0),
        .drdy_out  (ready),
        .do_out    (xadc_do),      // internal 16-bit result
        .dclk_in   (clk),
        .reset_in  (reset),
        .vp_in     (1'b0),
        .vn_in     (1'b0),
        .vauxp15   (vauxp15),
        .vauxn15   (vauxn15),
        .eoc_out   (enable)
    );

    // RAW output formatting
    // XADC full-scale code: xadc_do = 16'hFFF0
    // Display format: 0x0FFF (12 bits in the LSBs)
    wire [11:0] raw_12b = xadc_do[15:4];          // true 12-bit conversion result
    assign raw_adc_data = {4'b0000, raw_12b};     // 0x0000 .. 0x0FFF for display

    // Averager instantiation
    // 1024-sample window for quick synthesis (40ms window at 26kHz sample rate)
    averager #(
        .power(10),   // 2^10 = 1024 samples
        .N(12)        // 12-bit averaging
    ) AVERAGER (
        .clk   (clk),
        .reset (reset),
        .EN    (ready_pulse),
        .Din   (raw_12b),          // Feed 12-bit data
        .Q     (ave_data_12b)      // Get 12-bit averaged output
    );

    // AVERAGED output formatting
    // Convert 12-bit averaged data back to 16-bit left-justified format
    assign ave_data_16b = {ave_data_12b, 4'b0000};  // Left-justify
    assign averaged_adc_data = ave_data_16b;

    // DRDY edge detector
    always_ff @(posedge clk) begin
        if (reset)
            ready_r <= 1'b0;
        else
            ready_r <= ready;
    end

    // 1-clock pulse when DRDY goes 0 -> 1
    assign ready_pulse = (~ready_r) & ready;

    // Scaling to mV
    // ave_data_16b ranges approximately 0 .. 65520 (0xFFF0)
    // (ave_data_16b * 26406) >> 19 ≈ 0 .. 3300 mV
    always_ff @(posedge clk) begin
        if (reset) begin
            scaled_voltage_data <= 16'd0;
            scaled_temp         <= 32'd0;
        end else if (ready_pulse) begin
            scaled_temp         <= ave_data_16b * 32'd26406;
            scaled_voltage_data <= scaled_temp[31:19];
        end
    end


endmodule