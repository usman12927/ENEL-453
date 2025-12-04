#/////////////////////////////////////////////////////////////////
# File: Basys3_Lab7_Full.xdc
# Description:
#   Constraints file for the Lab 7 MVP design on the Basys3 board.
#   Defines pin locations and I/O standards for clock, reset, slide
#   switches, LEDs, seven-segment display, XADC analog pins, the
#   comparator digital output, and the PWM output used by the discrete
#   ramp-compare ADC.
#////////////////////////////////////////////////////////////////////

## Clock: 100 MHz system clock (W5)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk -waveform {0 5} [get_ports clk]

## Reset button: center button BTNC (U18)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## Slide switches SW0-SW9
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]

set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]

set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]

set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]

set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]

set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]

set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]

set_property PACKAGE_PIN W13 [get_ports {sw[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]

set_property PACKAGE_PIN V2 [get_ports {sw[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]

set_property PACKAGE_PIN T3 [get_ports {sw[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]


set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]

set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]

set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]

set_property PACKAGE_PIN V13 [get_ports {led[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]

set_property PACKAGE_PIN V3 [get_ports {led[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]

set_property PACKAGE_PIN W3 [get_ports {led[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]

set_property PACKAGE_PIN U3 [get_ports {led[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]

set_property PACKAGE_PIN P3 [get_ports {led[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]

set_property PACKAGE_PIN N3 [get_ports {led[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]

set_property PACKAGE_PIN P1 [get_ports {led[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]

set_property PACKAGE_PIN L1 [get_ports {led[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]

## Segments
set_property PACKAGE_PIN W7 [get_ports CA]   ; ## seg[0]
set_property IOSTANDARD LVCMOS33 [get_ports CA]

set_property PACKAGE_PIN W6 [get_ports CB]   ; ## seg[1]
set_property IOSTANDARD LVCMOS33 [get_ports CB]

set_property PACKAGE_PIN U8 [get_ports CC]   ; ## seg[2]
set_property IOSTANDARD LVCMOS33 [get_ports CC]

set_property PACKAGE_PIN V8 [get_ports CD]   ; ## seg[3]
set_property IOSTANDARD LVCMOS33 [get_ports CD]

set_property PACKAGE_PIN U5 [get_ports CE]   ; ## seg[4]
set_property IOSTANDARD LVCMOS33 [get_ports CE]

set_property PACKAGE_PIN V5 [get_ports CF]   ; ## seg[5]
set_property IOSTANDARD LVCMOS33 [get_ports CF]

set_property PACKAGE_PIN U7 [get_ports CG]   ; ## seg[6]
set_property IOSTANDARD LVCMOS33 [get_ports CG]

## Decimal point
set_property PACKAGE_PIN V7 [get_ports DP]   ; ## dp
set_property IOSTANDARD LVCMOS33 [get_ports DP]

## Digit enables (anodes)
set_property PACKAGE_PIN U2 [get_ports AN1]  ; ## an[0]
set_property IOSTANDARD LVCMOS33 [get_ports AN1]

set_property PACKAGE_PIN U4 [get_ports AN2]  ; ## an[1]
set_property IOSTANDARD LVCMOS33 [get_ports AN2]

set_property PACKAGE_PIN V4 [get_ports AN3]  ; ## an[2]
set_property IOSTANDARD LVCMOS33 [get_ports AN3]

set_property PACKAGE_PIN W4 [get_ports AN4]  ; ## an[3]
set_property IOSTANDARD LVCMOS33 [get_ports AN4]



## These go to the JXADC header pins
set_property PACKAGE_PIN N2 [get_ports vauxp15]  ; ## VAUXP15
set_property IOSTANDARD LVCMOS33 [get_ports vauxp15]

set_property PACKAGE_PIN N1 [get_ports vauxn15]  ; ## VAUXN15
set_property IOSTANDARD LVCMOS33 [get_ports vauxn15]


## Comparator digital output (TLV3701)
## We use Pmod JB1 (K3) for vcompare_raw
set_property PACKAGE_PIN K3 [get_ports vcompare_raw]
set_property IOSTANDARD LVCMOS33 [get_ports vcompare_raw]
set_property PULLUP true [get_ports vcompare_raw]


## PWM output to RC / R2R DAC
## We use Pmod JB2 (J3) for pwm_out
set_property PACKAGE_PIN J3 [get_ports pwm_out]
set_property IOSTANDARD LVCMOS33 [get_ports pwm_out]




## R-2R ladder digital outputs on Pmod JA (MSB..LSB)
## JA10..JA1 are used for r2r_out[7:0]
## R-2R ladder outputs (MSB..LSB) on JA10..JA1
set_property PACKAGE_PIN M3 [get_ports {vcompare_r2r_raw}]
set_property IOSTANDARD LVCMOS33 [get_ports {vcompare_r2r_raw}]

set_property PACKAGE_PIN G3 [get_ports {r2r_out[7]}] ; ## JA10 (MSB)
set_property IOSTANDARD LVCMOS33 [get_ports {r2r_out[7]}]

set_property PACKAGE_PIN H2 [get_ports {r2r_out[6]}] ; ## JA9
set_property IOSTANDARD LVCMOS33 [get_ports {r2r_out[6]}]

set_property PACKAGE_PIN K2 [get_ports {r2r_out[5]}] ; ## JA8
set_property IOSTANDARD LVCMOS33 [get_ports {r2r_out[5]}]

set_property PACKAGE_PIN H1 [get_ports {r2r_out[4]}] ; ## JA7
set_property IOSTANDARD LVCMOS33 [get_ports {r2r_out[4]}]

set_property PACKAGE_PIN G2 [get_ports {r2r_out[3]}] ; ## JA4
set_property IOSTANDARD LVCMOS33 [get_ports {r2r_out[3]}]

set_property PACKAGE_PIN J2 [get_ports {r2r_out[2]}] ; ## JA3
set_property IOSTANDARD LVCMOS33 [get_ports {r2r_out[2]}]

set_property PACKAGE_PIN L2 [get_ports {r2r_out[1]}] ; ## JA2
set_property IOSTANDARD LVCMOS33 [get_ports {r2r_out[1]}]

set_property PACKAGE_PIN J1 [get_ports {r2r_out[0]}] ; ## JA1 (LSB)
set_property IOSTANDARD LVCMOS33 [get_ports {r2r_out[0]}]

