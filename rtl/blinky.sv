//------------------------------------------------------------------
//-- Blinking LED
//------------------------------------------------------------------

module blinky (
    input  logic CLK,   // 12MHz clock
    output logic LED7,  // LED to blink
    // The rest of the LEDs are turned off.
    output logic LED6,
    output logic LED5,
    output logic LED4,
    output logic LED3,
    output logic LED2,
    output logic LED1,
    output logic LED0
);

  logic [23:0] counter = '0;

  always_ff @(posedge CLK) counter <= counter + 1'd1;

  assign LED7 = counter[6];

  //-- Turn off the other LEDs
  assign {LED6, LED5, LED4} = 3'b0;
  assign {LED3, LED2, LED1, LED0} = 4'b0;

endmodule
