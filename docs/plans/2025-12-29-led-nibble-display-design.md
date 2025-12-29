# LED Nibble Display Module Design

## Overview

A module that displays a 16-bit value on the iCEStick's 5 LEDs by cycling through 4 nibbles. The 4 red LEDs (LED0-LED3) show the current nibble's bits, while the green LED (LED4) indicates position via PWM brightness.

## Hardware

- **Target**: iCEStick (iCE40HX1K)
- **Clock**: 12MHz
- **LED0-LED3**: Red, active-high, display nibble data
- **LED4**: Green, active-high, position indicator with PWM

## Timing

- **Nibble duration**: 0.5 seconds (6,000,000 clock cycles)
- **Full cycle**: 2 seconds for all 4 nibbles
- **Order**: MSB first (nibble 3 → 2 → 1 → 0)

## PWM Brightness

Exponential duty cycles for perceptually linear brightness:

| Nibble | Bits  | Duty Cycle | Perceived Brightness |
|--------|-------|------------|----------------------|
| 3 (MSB)| 15:12 | 100% (255) | Full                 |
| 2      | 11:8  | 50% (128)  | ~75%                 |
| 1      | 7:4   | 25% (64)   | ~50%                 |
| 0 (LSB)| 3:0   | 0% (0)     | Off                  |

## Module Interfaces

### pwm

Reusable PWM generator.

```systemverilog
module pwm #(
    parameter WIDTH = 8  // Counter width (freq = clk / 2^WIDTH)
)(
    input  logic             clk,
    input  logic [WIDTH-1:0] duty,  // 0 = off, max = fully on
    output logic             out
);
```

Implementation: free-running counter, `out = (counter < duty)`.

### led_nibble_display

Main display module.

```systemverilog
module led_nibble_display (
    input  logic        clk,
    input  logic [15:0] value,
    output logic [3:0]  leds,     // LED0-LED3: nibble data
    output logic        led_pos   // LED4: position indicator
);
```

Internals:
- 23-bit counter for 0.5s timing (top 2 bits select nibble)
- Mux to select nibble from value based on position
- Mux to select duty cycle (255, 128, 64, 0) based on position
- Instantiates `pwm` module for led_pos output

### blinky (top module)

Test wrapper.

```systemverilog
module blinky (
    input  logic CLK,
    output logic LED4, LED3, LED2, LED1, LED0
);
```

Instantiates `led_nibble_display` with hardcoded value `16'hC931`.

## Test Pattern

`16'hC931` provides distinct visual patterns:

| Nibble | Hex | Binary | LEDs (3-0) |
|--------|-----|--------|------------|
| 3 (MSB)| C   | 1100   | on-on-off-off |
| 2      | 9   | 1001   | on-off-off-on |
| 1      | 3   | 0011   | off-off-on-on |
| 0 (LSB)| 1   | 0001   | off-off-off-on |

## File Structure

```
rtl/
  pwm.sv              # Reusable PWM module
  led_nibble_display.sv  # Display module
  blinky.sv           # Top module (test wrapper)
```
