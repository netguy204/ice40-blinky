//------------------------------------------------------------------
//-- UART Transmitter
//-- 115200 baud, 8N1 (8 data bits, no parity, 1 stop bit)
//------------------------------------------------------------------

module uart_tx #(
    parameter CLK_FREQ = 12_000_000,
    parameter BAUD_RATE = 115200
) (
    input  logic       clk,
    input  logic [7:0] data,      // Byte to transmit
    input  logic       valid,     // Start transmission (pulse)
    output logic       tx,        // Serial output
    output logic       ready      // High when ready to accept data
);

  // Cycles per bit (rounded)
  localparam CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;  // ~104 for 12MHz/115200

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
  logic [7:0] shift_reg = '0;        // Outgoing data shift register

  assign ready = (state == IDLE);

  // Main state machine
  always_ff @(posedge clk) begin
    case (state)
      IDLE: begin
        tx <= 1'b1;  // Idle high
        cycle_count <= '0;
        bit_index <= '0;
        if (valid) begin
          shift_reg <= data;
          state <= START;
        end
      end

      START: begin
        tx <= 1'b0;  // Start bit (low)
        if (cycle_count == CYCLES_PER_BIT - 1) begin
          cycle_count <= '0;
          state <= DATA;
        end else begin
          cycle_count <= cycle_count + 1'd1;
        end
      end

      DATA: begin
        tx <= shift_reg[0];  // LSB first
        if (cycle_count == CYCLES_PER_BIT - 1) begin
          cycle_count <= '0;
          shift_reg <= {1'b0, shift_reg[7:1]};  // Shift right
          if (bit_index == 3'd7) begin
            state <= STOP;
          end else begin
            bit_index <= bit_index + 1'd1;
          end
        end else begin
          cycle_count <= cycle_count + 1'd1;
        end
      end

      STOP: begin
        tx <= 1'b1;  // Stop bit (high)
        if (cycle_count == CYCLES_PER_BIT - 1) begin
          state <= IDLE;
        end else begin
          cycle_count <= cycle_count + 1'd1;
        end
      end
    endcase
  end

endmodule
