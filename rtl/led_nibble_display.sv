//------------------------------------------------------------------
//-- LED Nibble Display
//-- Displays a 16-bit value by cycling through 4 nibbles.
//-- Red LEDs (leds[3:0]) show nibble data.
//-- Green LED (led_pos) indicates position via PWM brightness.
//------------------------------------------------------------------

module led_nibble_display (
    input  logic        clk,      // 12MHz clock
    input  logic [15:0] value,    // 16-bit value to display
    output logic [3:0]  leds,     // LED0-LED3: current nibble data
    output logic        led_pos   // LED4: position indicator (PWM)
);

  // 0.5 second timing at 12MHz = 6,000,000 cycles
  localparam NIBBLE_CYCLES = 6_000_000;

  logic [22:0] counter = '0;
  logic [1:0] nibble_sel = '0;
  logic [3:0] current_nibble;
  logic [7:0] duty;

  // Counter for 0.5s timing, separate nibble selector
  always_ff @(posedge clk) begin
    if (counter >= (NIBBLE_CYCLES - 1)) begin
      counter <= '0;
      nibble_sel <= nibble_sel + 1'd1;
    end else begin
      counter <= counter + 1'd1;
    end
  end

  // Select nibble from value (MSB first: 3, 2, 1, 0)
  always_comb begin
    case (nibble_sel)
      2'd0: current_nibble = value[15:12];  // Nibble 3 (MSB)
      2'd1: current_nibble = value[11:8];   // Nibble 2
      2'd2: current_nibble = value[7:4];    // Nibble 1
      2'd3: current_nibble = value[3:0];    // Nibble 0 (LSB)
    endcase
  end

  // PWM duty cycle: steeper exponential curve for perceptual distinction
  // Nibble 3 (MSB) = 100%, Nibble 2 = 25%, Nibble 1 = 6%, Nibble 0 = 0%
  always_comb begin
    case (nibble_sel)
      2'd0: duty = 8'd255;  // 100%
      2'd1: duty = 8'd64;   // 25%
      2'd2: duty = 8'd16;   // 6%
      2'd3: duty = 8'd0;    // 0%
    endcase
  end

  // Output nibble data to LEDs
  assign leds = current_nibble;

  // PWM for position indicator
  pwm #(.WIDTH(8)) pwm_inst (
      .clk(clk),
      .duty(duty),
      .out(led_pos)
  );

endmodule
