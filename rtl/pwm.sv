//------------------------------------------------------------------
//-- PWM Generator
//------------------------------------------------------------------

module pwm #(
    parameter WIDTH = 8  // Counter width (freq = clk / 2^WIDTH)
)(
    input  logic             clk,
    input  logic [WIDTH-1:0] duty,  // 0 = off, max = fully on
    output logic             out
);

  logic [WIDTH-1:0] counter = '0;

  always_ff @(posedge clk) counter <= counter + 1'd1;

  assign out = (counter < duty);

endmodule
