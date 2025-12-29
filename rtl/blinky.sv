//------------------------------------------------------------------
//-- LED Nibble Display Test Wrapper
//------------------------------------------------------------------

module blinky (
    input  logic CLK,   // 12MHz clock
    output logic LED4,  // Green LED (position indicator)
    output logic LED3,  // Red LEDs (nibble data)
    output logic LED2,
    output logic LED1,
    output logic LED0
);

  // Test pattern: 0xC931
  // Nibble 3 (MSB): C = 1100
  // Nibble 2:       9 = 1001
  // Nibble 1:       3 = 0011
  // Nibble 0 (LSB): 1 = 0001
  localparam logic [15:0] TEST_VALUE = 16'hC931;

  led_nibble_display display_inst (
      .clk(CLK),
      .value(TEST_VALUE),
      .leds({LED3, LED2, LED1, LED0}),
      .led_pos(LED4)
  );

endmodule
