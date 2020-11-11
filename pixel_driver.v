`define TCK_ZR_HI 8  // .5 ns
`define TCK_ON_HI 20 // 1.25 ns (within 1.2 ns +- 150us)
`define TCK_CYCLE 40 // 2.5 ns
`define TCK_BITS 10
`define CNT_COLOR 24
`define CNT_RESET 20 // 50 ns (2.5 * 20)
`define CNT_BITS 5



module pixel_driver (
  input         clk,
  input  [23:0] color,
  input         reset,
  input         valid,
  output        ready,
  output        clk_out
);

  reg [23:0] stored;
  reg [CNT_BITS-1:0] count;
  reg [TCK_BITS-1:0] tick;
  reg on;
  reg hold_rst;
  
  reg [1:0] state, nextState;
  localparam STATE_READY=0, STATE_RESET=1, STATE_COLOR=2;
  
  assign ready = (nextState == STATE_READY);
  
  // inputs on valid hi
  // reset hi: lo output for 50 ns
  // reset lo on hi: hi output for 1.25 ns, lo for 1.25 ns
  // reset lo on lo: hi output for .5 ns, lo for 2 ns
  
  always @(state) begin
    case (state)
      STATE_READY:
        if (valid && reset)
          nextState = STATE_RESET;
        else if (valid)
          nextState = STATE_COLOR;
        else
          nextState = state;
      STATE_RESET:
        if (count == 0 && tick == 0)
          nextState = STATE_READY;
        else
          state = STATE_RESET;
      STATE_COLOR:
        if (count == 0 && tick == 0)
          nextState = STATE_READY;
        else
          state = STATE_COLOR;
      default: nextState = STATE_READY;
    endcase
  end
  
  // TODO: write state logic

endmodule // pixel_driver