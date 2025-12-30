# IR Receiver Display Design

## Overview

Receive NEC IR protocol frames via the iCEstick's IR transceiver and display the 32-bit data on the LEDs using the nibble display module.

## Requirements

- Decode NEC IR protocol (38kHz carrier, pulse-distance encoding)
- Display full 32-bit frame (address + inverted address + command + inverted command)
- Reset display to 0x00000000 on invalid frames
- 0.5 second per nibble timing (4 second total cycle for 8 nibbles)

## NEC Protocol Timing

At 12MHz clock with ±25% tolerance:

| Element | Nominal | Min Cycles | Max Cycles |
|---------|---------|------------|------------|
| Leader pulse | 9ms | 81,000 | 135,000 |
| Leader space | 4.5ms | 40,500 | 67,500 |
| Bit pulse | 562.5µs | 5,062 | 8,437 |
| Bit 0 space | 562.5µs | - | - |
| Bit 1 space | 1687.5µs | - | - |
| Bit threshold | 1.125ms | 13,500 | - |
| Bit space max | 2.11ms | - | 25,312 |

## Module Structure

### nec_ir_decoder.sv (new)

```systemverilog
module nec_ir_decoder (
    input  logic        clk,      // 12MHz clock
    input  logic        ir_rx,    // IR receiver input (active-low)
    output logic [31:0] data,     // Decoded 32-bit frame
    output logic        valid     // Pulses high for one cycle on valid decode
);
```

State machine: IDLE → LEADER_PULSE → LEADER_SPACE → BIT_PULSE → BIT_SPACE (×32) → VALIDATE → IDLE

Validation: `data[31:24] == ~data[23:16]` and `data[15:8] == ~data[7:0]`

### led_nibble_display.sv (updated)

- Change `value` input from 16-bit to 32-bit
- Change `nibble_sel` from 2-bit to 3-bit
- Extend case statement to 8 nibbles (MSB first)

### blinky.sv (updated)

- Add `IR_RX` and `IR_SD` ports
- Drive `IR_SD` low to enable transceiver
- Instantiate `nec_ir_decoder`
- Hold 32-bit register, reset to 0 on invalid frame
- Feed register to `led_nibble_display`
