//------------------------------------------------------------------
//-- LED Nibble Display
//-- Displays a 32-bit value by cycling through 8 nibbles.
//-- Red LEDs (leds[3:0]) show nibble data.
//-- Green LED (led_pos) indicates position via PWM brightness.
//------------------------------------------------------------------

module led_nibble_display (
    input  logic        clk,      // 12MHz clock
    input  logic [31:0] value,    // 32-bit value to display
    output logic [3:0]  leds,     // LED0-LED3: current nibble data
    output logic        led_pos   // LED4: position indicator (PWM)
);

  // 0.5 second timing at 12MHz = 6,000,000 cycles
  localparam NIBBLE_CYCLES = 6_000_000;

  logic [22:0] counter = '0;
  logic [2:0] nibble_sel = '0;
  logic [3:0] current_nibble;
  logic [7:0] duty;

  // Flash duration: 0.1 second at 12MHz = 1,200,000 cycles
  localparam FLASH_CYCLES = 1_200_000;

  // Counter for 0.5s timing, separate nibble selector
  always_ff @(posedge clk) begin
    if (counter >= (NIBBLE_CYCLES - 1)) begin
      counter <= '0;
      nibble_sel <= nibble_sel + 1'd1;
    end else begin
      counter <= counter + 1'd1;
    end
  end

  // Flash indicator: high for first 0.1s of each nibble period
  logic flash_active;
  assign flash_active = (counter < FLASH_CYCLES);

  // Select nibble from value (MSB first: 7, 6, 5, 4, 3, 2, 1, 0)
  always_comb begin
    case (nibble_sel)
      3'd0: current_nibble = value[31:28];  // Nibble 7 (MSB)
      3'd1: current_nibble = value[27:24];  // Nibble 6
      3'd2: current_nibble = value[23:20];  // Nibble 5
      3'd3: current_nibble = value[19:16];  // Nibble 4
      3'd4: current_nibble = value[15:12];  // Nibble 3
      3'd5: current_nibble = value[11:8];   // Nibble 2
      3'd6: current_nibble = value[7:4];    // Nibble 1
      3'd7: current_nibble = value[3:0];    // Nibble 0 (LSB)
    endcase
  end

  // PWM duty cycle: exponential curve for perceptual distinction
  // MSB nibble = brightest, LSB nibble = off
  always_comb begin
    case (nibble_sel)
      3'd0: duty = 8'd255;  // 100% (MSB)
      3'd1: duty = 8'd180;  // 71%
      3'd2: duty = 8'd120;  // 47%
      3'd3: duty = 8'd75;   // 29%
      3'd4: duty = 8'd45;   // 18%
      3'd5: duty = 8'd25;   // 10%
      3'd6: duty = 8'd10;   // 4%
      3'd7: duty = 8'd0;    // 0% (LSB)
    endcase
  end

  // Output nibble data to LEDs
  assign leds = current_nibble;

  // PWM for position indicator (with flash override)
  logic [7:0] effective_duty;
  assign effective_duty = flash_active ? 8'd255 : duty;

  pwm #(.WIDTH(8)) pwm_inst (
      .clk(clk),
      .duty(effective_duty),
      .out(led_pos)
  );

endmodule
