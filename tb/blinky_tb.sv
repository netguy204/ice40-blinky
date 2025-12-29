//------------------------------------------------------------------
//-- Testbench for LED Nibble Display
//------------------------------------------------------------------

`timescale 1ns / 1ps

module blinky_tb;

  // Clock period for 12MHz clock
  localparam CLK_PERIOD = 83.33;  // ~12MHz
  // Nibble duration: 6,000,000 cycles at 12MHz = 0.5 seconds
  localparam NIBBLE_CYCLES = 6_000_000;

  // Test pattern: 0xC931
  // Nibble 3 (MSB): C = 4'b1100
  // Nibble 2:       9 = 4'b1001
  // Nibble 1:       3 = 4'b0011
  // Nibble 0 (LSB): 1 = 4'b0001
  localparam logic [3:0] NIBBLE_3 = 4'hC;
  localparam logic [3:0] NIBBLE_2 = 4'h9;
  localparam logic [3:0] NIBBLE_1 = 4'h3;
  localparam logic [3:0] NIBBLE_0 = 4'h1;

  logic clk;
  logic led4, led3, led2, led1, led0;
  logic [3:0] leds;

  assign leds = {led3, led2, led1, led0};

  // Instantiate DUT
  blinky dut (
      .CLK (clk),
      .LED4(led4),
      .LED3(led3),
      .LED2(led2),
      .LED1(led1),
      .LED0(led0)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // Helper task to measure PWM duty cycle over a window
  task automatic measure_pwm_duty(
    input int sample_cycles,
    output int high_count
  );
    high_count = 0;
    repeat (sample_cycles) begin
      @(posedge clk);
      if (led4) high_count++;
    end
  endtask

  // Test stimulus
  initial begin
    $dumpvars(0, blinky_tb);

    $display("Starting LED nibble display testbench...");
    $display("Test pattern: 0xC931");

    // Wait for initial state to settle
    repeat (100) @(posedge clk);

    // Nibble 3 (MSB): C = 1100, LED4 at 100% duty
    $display("\n--- Nibble 3 (MSB): expecting 0xC = 4'b1100, LED4 at 100%% ---");
    assert (leds == NIBBLE_3)
    else $error("Nibble 3: expected %b, got %b", NIBBLE_3, leds);
    $display("LEDs = %b (expected %b)", leds, NIBBLE_3);

    // Sample LED4 over 512 cycles (2 PWM periods) - should be 100% high
    begin
      int high_count;
      measure_pwm_duty(512, high_count);
      $display("LED4 duty: %0d/512 cycles high", high_count);
      assert (high_count >= 510)
      else $error("Nibble 3: LED4 should be ~100%% on");
    end

    // Advance to middle of nibble 2 window
    $display("\nAdvancing to nibble 2...");
    repeat (NIBBLE_CYCLES) @(posedge clk);

    // Nibble 2: 9 = 1001, LED4 at 25% duty
    $display("\n--- Nibble 2: expecting 0x9 = 4'b1001, LED4 at 25%% ---");
    assert (leds == NIBBLE_2)
    else $error("Nibble 2: expected %b, got %b", NIBBLE_2, leds);
    $display("LEDs = %b (expected %b)", leds, NIBBLE_2);

    // Sample LED4 - should be ~25% (64/256)
    begin
      int high_count;
      measure_pwm_duty(512, high_count);
      $display("LED4 duty: %0d/512 cycles high (expected ~128)", high_count);
      assert (high_count > 100 && high_count < 160)
      else $error("Nibble 2: LED4 should be ~25%% on");
    end

    // Advance to nibble 1
    $display("\nAdvancing to nibble 1...");
    repeat (NIBBLE_CYCLES - 512) @(posedge clk);

    // Nibble 1: 3 = 0011, LED4 at 6% duty
    $display("\n--- Nibble 1: expecting 0x3 = 4'b0011, LED4 at 6%% ---");
    assert (leds == NIBBLE_1)
    else $error("Nibble 1: expected %b, got %b", NIBBLE_1, leds);
    $display("LEDs = %b (expected %b)", leds, NIBBLE_1);

    // Sample LED4 - should be ~6% (16/256)
    begin
      int high_count;
      measure_pwm_duty(512, high_count);
      $display("LED4 duty: %0d/512 cycles high (expected ~32)", high_count);
      assert (high_count > 20 && high_count < 50)
      else $error("Nibble 1: LED4 should be ~6%% on");
    end

    // Advance to nibble 0
    $display("\nAdvancing to nibble 0...");
    repeat (NIBBLE_CYCLES - 512) @(posedge clk);

    // Nibble 0 (LSB): 1 = 0001, LED4 at 0% duty
    $display("\n--- Nibble 0 (LSB): expecting 0x1 = 4'b0001, LED4 at 0%% ---");
    assert (leds == NIBBLE_0)
    else $error("Nibble 0: expected %b, got %b", NIBBLE_0, leds);
    $display("LEDs = %b (expected %b)", leds, NIBBLE_0);

    // Sample LED4 - should be 0%
    begin
      int high_count;
      measure_pwm_duty(512, high_count);
      $display("LED4 duty: %0d/512 cycles high (expected 0)", high_count);
      assert (high_count == 0)
      else $error("Nibble 0: LED4 should be 0%% (off)");
    end

    // Advance back to nibble 3 to verify wrap-around
    $display("\nAdvancing to nibble 3 (wrap-around)...");
    repeat (NIBBLE_CYCLES - 512) @(posedge clk);

    $display("\n--- Nibble 3 (wrap): expecting 0xC = 4'b1100 ---");
    assert (leds == NIBBLE_3)
    else $error("Nibble 3 wrap: expected %b, got %b", NIBBLE_3, leds);
    $display("LEDs = %b (expected %b)", leds, NIBBLE_3);

    $display("\n========================================");
    $display("Test completed successfully!");
    $display("========================================");
    $finish;
  end

endmodule
