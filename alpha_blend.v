`default_nettype none

module alpha_blend (
  input  clk,
  input     [23:0] colorTop, colorBot,
  input     [7:0]  alphaTop,
  input            valid,
  input            ack,
  output reg       validOut,
  output           ready,
  output reg [23:0] colorOut
);
  
  localparam STATE_WAIT = 2'b00;
  localparam STATE_MULT = 2'b01;
  localparam STATE_ADD = 2'b10;
  reg [1:0] state=STATE_WAIT, nextState;
  
  
  wire [15:0] redSum, greenSum, blueSum;
  
  assign ready = (state == STATE_WAIT);
  assign redSum = (redTop + redBot + 15'h00FF);
  assign greenSum = (greenTop + greenBot + 15'h00FF);
  assign blueSum = (blueTop + blueBot + 15'h00FF);
  
  always @(*) begin
    case (state)
    STATE_WAIT: begin
      nextState = (valid ? STATE_MULT : STATE_WAIT);
    end
    STATE_MULT: nextState = STATE_ADD;
    STATE_ADD: nextState = STATE_WAIT;
    default: nextState = STATE_WAIT;
    endcase
  end
  
  reg [15:0] redTop, greenTop, blueTop, 
             redBot, greenBot, blueBot,
             redMult, greenMult, blueMult;
  reg [7:0] alpha;
  
  
  always @(posedge clk) begin
    state <= nextState;
    if (ack)
      validOut <= 0;
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
      redBot <= redBot * (16'hFF - {8'h00, alpha});
      greenBot <= greenBot * (16'hFF - {8'h00, alpha});
      blueBot <= blueBot * (16'hFF - {8'h00, alpha});
    end
    STATE_ADD: begin
      colorOut[23:16] <= redSum[15:8];
      colorOut[15:8] <= greenSum[15:8];
      colorOut[7:0] <= blueSum[15:8];
      validOut <= 1;
    end
    default: begin end
    endcase
  end
  
  
  
endmodule // alpha_blend