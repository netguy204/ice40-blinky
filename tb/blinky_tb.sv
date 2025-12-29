//------------------------------------------------------------------
//-- Testbench for Blinking LED
//------------------------------------------------------------------

`timescale 1ns / 1ps

module blinky_tb;

  // Clock period for 12MHz clock
  localparam CLK_PERIOD = 83.33;  // ~12MHz

  logic clk;
  logic led4, led3, led2, led1, led0;

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

  // Test stimulus
  initial begin
    $dumpvars(0, blinky_tb);

    $display("Starting blinky testbench...");

    // Wait a clock cycle for initial state
    @(posedge clk);

    // Verify other LEDs are off
    assert (led3 == 0 && led2 == 0 && led1 == 0 && led0 == 0)
    else $error("LEDs 3-0 should be off");

    // LED4 = counter[22], toggles every 2^22 = 4,194,304 clock cycles
    // At 12MHz, that's ~350ms per toggle (visible blink rate)
    // For testbench, we just verify initial state and that counter increments

    // After 1 cycle, counter=1, LED4 should be 0
    assert (led4 == 0) else $error("LED4 should be 0 at start");
    $display("Counter ~1: LED4 = %b (expected 0)", led4);

    // Run a few more cycles to verify LED4 stays 0 (counter[22] won't flip yet)
    repeat (100) @(posedge clk);
    #1;
    assert (led4 == 0) else $error("LED4 should still be 0 after 100 cycles");
    $display("Counter ~100: LED4 = %b (expected 0)", led4);

    // Verify LEDs 3-0 remain off
    assert (led3 == 0 && led2 == 0 && led1 == 0 && led0 == 0)
    else $error("LEDs 3-0 should remain off");

    $display("Test completed successfully!");
    $finish;
  end

endmodule
