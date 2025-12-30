//------------------------------------------------------------------
//-- UART Receiver
//-- 115200 baud, 8N1 (8 data bits, no parity, 1 stop bit)
//-- Active-high valid pulse when byte received
//------------------------------------------------------------------

module uart_rx #(
    parameter CLK_FREQ = 12_000_000,
    parameter BAUD_RATE = 115200
) (
    input  logic       clk,
    input  logic       rx,        // Serial input (active-high data)
    output logic [7:0] data,      // Received byte
    output logic       valid      // High for one cycle when byte ready
);

  // Cycles per bit (rounded)
  localparam logic [6:0] CYCLES_PER_BIT = 7'(CLK_FREQ / BAUD_RATE);  // ~104 for 12MHz/115200

  // States
  typedef enum logic [1:0] {
    IDLE,
    START,
    DATA,
    STOP
  } state_t;

  state_t state = IDLE;
  logic [6:0] cycle_count = '0;      // Counter within bit period
  logic [2:0] bit_index = '0;        // Current bit (0-7)
  logic [7:0] shift_reg = '0;        // Incoming data shift register

  // Synchronize RX input to avoid metastability
  logic rx_sync1 = 1'b1;
  logic rx_sync2 = 1'b1;

  always_ff @(posedge clk) begin
    rx_sync1 <= rx;
    rx_sync2 <= rx_sync1;
  end

  // Main state machine
  always_ff @(posedge clk) begin
    valid <= 1'b0;  // Default: no valid output

    case (state)
      IDLE: begin
        cycle_count <= '0;
        bit_index <= '0;
        if (rx_sync2 == 1'b0) begin
          // Start bit detected, move to START state
          state <= START;
        end
      end

      START: begin
        // Sample at middle of start bit to confirm it's valid
        if (cycle_count == (CYCLES_PER_BIT / 2) - 1) begin
          if (rx_sync2 == 1'b0) begin
            // Valid start bit, proceed to data
            cycle_count <= '0;
            state <= DATA;
          end else begin
            // False start, return to idle
            state <= IDLE;
          end
        end else begin
          cycle_count <= cycle_count + 1'd1;
        end
      end

      DATA: begin
        if (cycle_count == CYCLES_PER_BIT - 1) begin
          // Sample data bit (LSB first)
          shift_reg <= {rx_sync2, shift_reg[7:1]};
          cycle_count <= '0;
          if (bit_index == 3'd7) begin
            // All 8 bits received
            state <= STOP;
          end else begin
            bit_index <= bit_index + 1'd1;
          end
        end else begin
          cycle_count <= cycle_count + 1'd1;
        end
      end

      STOP: begin
        if (cycle_count == CYCLES_PER_BIT - 1) begin
          // Stop bit complete, output data
          if (rx_sync2 == 1'b1) begin
            // Valid stop bit
            data <= shift_reg;
            valid <= 1'b1;
          end
          // Return to idle regardless (ignore framing errors)
          state <= IDLE;
        end else begin
          cycle_count <= cycle_count + 1'd1;
        end
      end
    endcase
  end

endmodule
