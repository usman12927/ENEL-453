///////////////////////////////////////////////////////////////////
// File: mux4_16_bits.sv
// Module: mux4_16_bits
// Description:
//   4-to-1 multiplexer for 16-bit data buses with decimal point
//   control. Selects between hexadecimal and BCD-formatted values
//   (or future data sources) for the seven-segment display.
//   The decimal point output varies based on the selected input
//   to properly format voltage readings in millivolts.
///////////////////////////////////////////////////////////////////

module mux4_16_bits(
    input  logic [15:0] in0,  
    input  logic [15:0] in1,  
    input  logic [15:0] in2, 
    input  logic [15:0] in3,  
    input  logic  [1:0] select,  
    output logic [15:0] mux_out,
    output logic  [3:0] decimal_point  
    );

    always_comb begin
        case(select)
            2'b00: mux_out = in0;  
            2'b01: mux_out = in1;  
            2'b10: mux_out = in2;
            2'b11: mux_out = in3;
            default: mux_out = 16'h0000;
        endcase
    end    

   always_comb begin
     // Decimal point control moved to display_controller
     // Always output no decimal point - controller will add it for voltage modes
     decimal_point = 4'b0000;
   end    
    

endmodule