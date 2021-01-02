`default_nettype none

module alpha_blend (
  input  clk,
  input  [23:0] colorTop, colorBot,
  input  [7:0]  alphaTop,
  input  valid,
  output ready,
  output [23:0] colorOut);
  
  localparam STATE_WAIT = 2'b0;
  localparam STATE_MULT = 2'b1;
  localparam STATE_ADD = 2'b2;
  reg [1:0] state, nextState;
  
  assign ready = (nextState == STATE_WAIT);
  
  always @(*) begin
    case (state)
    STATE_WAIT: begin
      nextState = (valid ? STATE_MULT : STATE_WAIT);
    end
    STATE_MULT: nextState = STATE_ADD;
    STATE_ADD: nextState = STATE_WAIT;
    default: nextState = state_WAIT;
    endcase
  end
  
  reg [15:0] redTop, greenTop, blueTop, 
             redBot, greenBot, blueBot,
             redMult, greenMult, blueMult;
  reg [7:0] alpha;
  
  
  always @(posedge clk) begin
    state <= nextState;
    ready <= 0;
    case (state)
    STATE_WAIT: begin
      case (nextState)
      STATE_MULT: begin
        redTop <= {8'b0, colorTop[23:16]};
        greenTop <= {8'b0, colorTop[15:8]};
        blueTop <= {8'b0, colorTop[7:0]};
        redBot <= {8'b0, colorBot[23:16]};
        greenBot <= {8'b0, colorBot[15:8]};
        blueBot <= {8'b0, colorBot[7:0]};
        alpha <= alphaTop;
      end
      default: begin end
      endcase
    end
    STATE_MULT: begin
      redTop <= redTop * alpha;
      greenTop <= greenTop * alpha;
      blueTop <= blueTop * alpha;
      redBot <= redBot * (255 - alpha);
      greenBot <= greenBot * (255 - alpha);
      blueBot <= blueBot * (255 - alpha);
    end
    STATE_ADD: begin
      colorOut[23:16] <= (redTop + redBot + 15'h00FF)[15:8];
      colorOut[15:8] <= (greenTop + greenBot + 15'h00FF)[15:8];
      colorOut[7:0] <= (blueTop + blueBot + 15'h00FF)[15:8];
      ready <= 1;
    end
    default: begin end
    endcase
  end
  
  
  
endmodule // alpha_blend