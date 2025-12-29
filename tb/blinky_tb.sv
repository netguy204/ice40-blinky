//------------------------------------------------------------------
//-- Testbench for Blinking LED
//------------------------------------------------------------------

`timescale 1ns / 1ps

module blinky_tb;

  // Clock period for 12MHz clock
  localparam CLK_PERIOD = 83.33;  // ~12MHz

  logic clk;
  logic led7, led6, led5, led4, led3, led2, led1, led0;

  // Instantiate DUT
  blinky dut (
      .CLK (clk),
      .LED7(led7),
      .LED6(led6),
      .LED5(led5),
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
    assert (led6 == 0 && led5 == 0 && led4 == 0)
    else $error("LEDs 6-4 should be off");
    assert (led3 == 0 && led2 == 0 && led1 == 0 && led0 == 0)
    else $error("LEDs 3-0 should be off");

    // LED7 = counter[6], toggles every 64 clock cycles
    // Counter starts at 0 and increments on posedge
    // LED7 = 1 when counter[6] = 1, i.e., counter in [64-127], [192-255], etc.

    // After 1 cycle, counter=1, LED7 should be 0
    assert (led7 == 0) else $error("LED7 should be 0 at start");
    $display("Counter ~1: LED7 = %b (expected 0)", led7);

    // Run 63 more cycles, counter=64, LED7 should become 1
    repeat (63) @(posedge clk);
    #1;  // Small delay to let combinational logic settle
    assert (led7 == 1) else $error("LED7 should be 1 when counter=64");
    $display("Counter ~64: LED7 = %b (expected 1)", led7);

    // Run 64 more cycles, counter=128, LED7 should become 0
    repeat (64) @(posedge clk);
    #1;
    assert (led7 == 0) else $error("LED7 should be 0 when counter=128");
    $display("Counter ~128: LED7 = %b (expected 0)", led7);

    // Run 64 more cycles, counter=192, LED7 should become 1
    repeat (64) @(posedge clk);
    #1;
    assert (led7 == 1) else $error("LED7 should be 1 when counter=192");
    $display("Counter ~192: LED7 = %b (expected 1)", led7);

    $display("Test completed successfully!");
    $finish;
  end

endmodule
