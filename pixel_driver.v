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

  // pixel buffer storage
  reg [22:0] stored;
  
  // counters
  reg [`CNT_BITS-1:0] count = 0;
  reg [`TCK_BITS-1:0] tick = 0;
  reg [`TCK_BITS-1:0] tick_on = 0;
  
  // State machine init
  localparam STATE_WAIT=0, STATE_RESET=1, STATE_COLOR=2;
  reg  [1:0] state=STATE_WAIT;
  reg  [1:0] nextState;
  
  // output signals determined by zero states
  assign ready = (state == STATE_WAIT);
  assign clk_out = ~(tick_on == 0);
  
  /*
   * I favor back-to-back signal chains, so I added this signal
   * to return to STATE_WAIT right as all counters become zero.
   * Coupled with the 'ready' assign, this achieves the task.
   * I hope this solution isn't looked down upon since it only
   * saves a single clock cycle.
   */
  wire next_ready;
  assign next_ready = (count == 0 && tick == 1);
  
  // STATE_WAIT: No command received.
  // STATE_COLOR: Consume stored buffer and translate to PWM output.
  // STATE_RESET: Hold clock low for a while to indicate new output chain.
  
  always @(*) begin
    case (state)
      STATE_WAIT: begin // ready hi
        if (valid && reset)
          nextState = STATE_RESET;
        else if (valid)
          nextState = STATE_COLOR;
        else
          nextState = STATE_WAIT;
      end
      STATE_RESET,STATE_COLOR: begin
        if (next_ready)
          nextState = STATE_WAIT;
        else
          nextState = state;
      end
      default: nextState = STATE_WAIT;
    endcase
  end
  
  always @(posedge clk) begin
    state <= nextState;
    // mealy bois
    case (state)
    STATE_WAIT: begin
      case (nextState)
      STATE_COLOR: begin
        stored <= color[22:0]; // MSB -> LSB, R->B->G
        count <= `CNT_COLOR-1;
        tick <= `TCK_CYCLE-1;
        tick_on <= (color[23] ? `TCK_ON_HI : `TCK_ZR_HI); 
      end
      STATE_RESET: begin
        count <= `CNT_RESET-1;
        tick <= `TCK_CYCLE-1;
        tick_on <= 0;
      end
      default: begin
        count <= 0;
        tick <= 0;
        tick_on <= 0;
      end
      endcase
    end
    STATE_RESET: begin
      case (nextState)
      STATE_RESET: begin
        if (tick == 0) begin
          count <= count-1;
          tick <= `TCK_CYCLE-1;
        end else begin
          tick <= tick-1;
        end
      end
      STATE_WAIT: begin
        count <= 0;
        tick <= 0;
      end
      default: begin end
      endcase
    end
    STATE_COLOR: begin
      case (nextState)
      STATE_COLOR: begin
        if (tick == 0) begin
          stored <= {stored[21:0], 1'b0};
          count <= count-1;
          tick <= `TCK_CYCLE-1;
          tick_on <= (stored[22] ? `TCK_ON_HI : `TCK_ZR_HI);
        end else begin
          tick <= tick-1;
          if (tick_on > 0)
            tick_on <= tick_on-1;
        end
      end
      STATE_WAIT: begin
        count <= 0;
        tick <= 0;
        tick_on <= 0;
      end
      default: begin end
      endcase
    end
    default: begin end
    endcase
  end

endmodule // pixel_driver