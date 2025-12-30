//------------------------------------------------------------------
//-- UART Echo Display
//-- Receives bytes over UART, echoes them back, and displays
//-- the last 4 bytes on LEDs.
//------------------------------------------------------------------

module blinky (
    input  logic CLK,    // 12MHz clock
    input  logic RX,     // UART receive (from FTDI)
    output logic TX,     // UART transmit (to FTDI)
    output logic LED4,   // Green LED (position indicator)
    output logic LED3,   // Red LEDs (nibble data)
    output logic LED2,
    output logic LED1,
    output logic LED0
);

  // UART received data
  logic [7:0] rx_data;
  logic       rx_valid;

  // UART transmit signals
  logic       tx_ready;

  // Shift register holding last 4 received bytes
  // New bytes shift in from the right (become LSB)
  logic [31:0] display_value = 32'h0000_0000;

  // UART receiver
  uart_rx uart_inst (
      .clk(CLK),
      .rx(RX),
      .data(rx_data),
      .valid(rx_valid)
  );

  // UART transmitter - echo received bytes
  uart_tx tx_inst (
      .clk(CLK),
      .data(rx_data),
      .valid(rx_valid),
      .tx(TX),
      .ready(tx_ready)
  );

  // Shift in new bytes when received
  always_ff @(posedge CLK) begin
    if (rx_valid) begin
      display_value <= {display_value[23:0], rx_data};
    end
  end

  // LED nibble display
  led_nibble_display display_inst (
      .clk(CLK),
      .value(display_value),
      .leds({LED3, LED2, LED1, LED0}),
      .led_pos(LED4)
  );

endmodule
