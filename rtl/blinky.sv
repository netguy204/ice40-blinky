//------------------------------------------------------------------
//-- Blinking LED
//------------------------------------------------------------------

module blinky (
    input  logic CLK,   // 12MHz clock
    output logic LED4,  // LED to blink
    // The rest of the LEDs are turned off.
    output logic LED3,
    output logic LED2,
    output logic LED1,
    output logic LED0
);

  logic [27:0] counter = '0;

  always_ff @(posedge CLK) counter <= counter + 1'd1;

  assign {LED4, LED3, LED2, LED1, LED0} = counter[26:21];

endmodule
