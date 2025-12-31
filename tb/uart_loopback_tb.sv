//------------------------------------------------------------------
//-- UART Loopback Testbench
//-- Verifies that data transmitted by uart_tx is correctly received
//-- by uart_rx when wired in loopback configuration.
//------------------------------------------------------------------

`timescale 1ns / 1ps

module uart_loopback_tb;

  // Clock period for 12MHz clock
  localparam CLK_PERIOD = 83.33;  // ~12MHz
  localparam CLK_FREQ = 12_000_000;
  localparam BAUD_RATE = 115200;

  // Cycles per bit at this baud rate
  localparam CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
  // Total cycles for one UART frame: start + 8 data + stop = 10 bits
  localparam CYCLES_PER_FRAME = CYCLES_PER_BIT * 10;

  logic clk;
  logic [7:0] tx_data;
  logic tx_valid;
  logic tx_ready;
  logic serial_line;  // Loopback connection: TX -> RX
  logic [7:0] rx_data;
  logic rx_valid;

  // Instantiate transmitter
  uart_tx #(
      .CLK_FREQ (CLK_FREQ),
      .BAUD_RATE(BAUD_RATE)
  ) u_uart_tx (
      .clk  (clk),
      .data (tx_data),
      .valid(tx_valid),
      .tx   (serial_line),
      .ready(tx_ready)
  );

  // Instantiate receiver (connected to same serial line)
  uart_rx #(
      .CLK_FREQ (CLK_FREQ),
      .BAUD_RATE(BAUD_RATE)
  ) u_uart_rx (
      .clk  (clk),
      .rx   (serial_line),
      .data (rx_data),
      .valid(rx_valid)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // Task to transmit a byte and verify it's received correctly
  task automatic transmit_and_verify(input logic [7:0] test_byte);
    // Wait for transmitter to be ready
    while (!tx_ready) @(posedge clk);

    // Send the byte - hold valid for one full clock cycle
    @(posedge clk);
    tx_data  = test_byte;
    tx_valid = 1;
    @(posedge clk);
    tx_valid = 0;

    // Wait for reception (with timeout)
    // Frame is 10 bits (~1040 cycles), add margin for synchronizer delay
    begin
      int timeout_count;
      timeout_count = 0;
      while (!rx_valid && timeout_count < 3000) begin
        @(posedge clk);
        timeout_count++;
      end
      if (timeout_count >= 3000) begin
        $error("Timeout waiting for RX valid for byte 0x%02h", test_byte);
        $finish;
      end
    end

    // Verify received data matches transmitted data
    assert (rx_data == test_byte)
    else $error("Data mismatch: sent 0x%02h, received 0x%02h", test_byte, rx_data);

    $display("PASS: Sent 0x%02h, received 0x%02h", test_byte, rx_data);

    // Wait for transmitter to be ready again before next transmission
    while (!tx_ready) @(posedge clk);
  endtask

  // Test stimulus
  initial begin
    $dumpvars(0, uart_loopback_tb);

    $display("Starting UART loopback testbench...");
    $display("CLK_FREQ=%0d, BAUD_RATE=%0d, CYCLES_PER_BIT=%0d", CLK_FREQ, BAUD_RATE, CYCLES_PER_BIT);

    // Initialize signals
    tx_data  = 8'h00;
    tx_valid = 0;

    // Wait for initial state to settle (serial line should be idle high)
    repeat (100) @(posedge clk);
    assert (serial_line == 1'b1)
    else $error("Serial line should be idle high");
    assert (tx_ready == 1'b1)
    else $error("TX should be ready initially");

    $display("\n--- Test 1: Single byte 0x55 (alternating bits) ---");
    transmit_and_verify(8'h55);

    $display("\n--- Test 2: Single byte 0xAA (alternating bits, inverted) ---");
    transmit_and_verify(8'hAA);

    $display("\n--- Test 3: All zeros 0x00 ---");
    transmit_and_verify(8'h00);

    $display("\n--- Test 4: All ones 0xFF ---");
    transmit_and_verify(8'hFF);

    $display("\n--- Test 5: ASCII 'H' (0x48) ---");
    transmit_and_verify(8'h48);

    $display("\n--- Test 6: ASCII 'i' (0x69) ---");
    transmit_and_verify(8'h69);

    $display("\n--- Test 7: Byte with single bit set 0x01 ---");
    transmit_and_verify(8'h01);

    $display("\n--- Test 8: Byte with single bit set 0x80 ---");
    transmit_and_verify(8'h80);

    $display("\n--- Test 9: Random pattern 0xC3 ---");
    transmit_and_verify(8'hC3);

    $display("\n--- Test 10: Random pattern 0x3C ---");
    transmit_and_verify(8'h3C);

    $display("\n========================================");
    $display("All UART loopback tests passed!");
    $display("========================================");
    $finish;
  end

endmodule
