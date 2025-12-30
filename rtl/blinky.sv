//------------------------------------------------------------------
//-- LED Nibble Display Test
//-- Displays a 32-bit test value on LEDs using nibble cycling.
//------------------------------------------------------------------

module blinky (
    input  logic CLK,    // 12MHz clock
    output logic LED4,   // Green LED (position indicator)
    output logic LED3,   // Red LEDs (nibble data)
    output logic LED2,
    output logic LED1,
    output logic LED0
);

  // Test value: 0xDEADBEEF
  localparam logic [31:0] TEST_VALUE = 32'hDEAD_BEEF;

  // LED nibble display
  led_nibble_display display_inst (
      .clk(CLK),
      .value(TEST_VALUE),
      .leds({LED3, LED2, LED1, LED0}),
      .led_pos(LED4)
  );

endmodule
