`default_nettype none

//
// WS2812B Driver
//
 
module pixel_driver 
  #(parameter CLK_HZ=16000000,
    parameter HZ=80,
    parameter LED=256,
    parameter TCK_ZR_HI=6,
    parameter TCK_ON_HI=11,
    parameter TCK_COLOR=18,
    parameter CNT_COLOR=24,
    parameter RESET_VERIFY=800) (
  input        clk,
  input  [7:0] red, green, blue,
  input        reset,
  input        valid,
  output       ready,
  output       clk_out
);

  localparam TCK_RESET = (CLK_HZ / HZ) - (LED * TCK_COLOR * CNT_COLOR);
  localparam TIMING_FAILURE = (RESET_VERIFY <= TCK_RESET);
  
  localparam CNT_BITS = $clog2(CNT_COLOR);
  localparam TCK_BITS = 32;

  // pixel buffer storage
  reg [22:0] stored;
  
  // counters
  reg [CNT_BITS-1:0] count = 0;
  reg [TCK_BITS-1:0] tick = 0;
  reg [TCK_BITS-1:0] tick_on = 0;
  
  // State machine init
  localparam STATE_WAIT=0, STATE_RESET=1, STATE_COLOR=2;
  reg  [1:0] state=STATE_WAIT, nextState;
  
  assign ready = (state == STATE_WAIT);
  assign clk_out = ~(tick_on == 0);
  
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
        if (count == 0 && tick == 1)
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
        stored <= {green[6:0], red, blue}; // MSB -> LSB, G->R->B
        count <= CNT_COLOR-1;
        tick <= TCK_COLOR-1;
        tick_on <= (green[7] ? TCK_ON_HI : TCK_ZR_HI); 
      end
      STATE_RESET: begin
        count <= 0;
        tick <= TCK_RESET-1;
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
          tick <= TCK_COLOR-1;
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
          tick <= TCK_COLOR-1;
          tick_on <= (stored[22] ? TCK_ON_HI : TCK_ZR_HI);
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