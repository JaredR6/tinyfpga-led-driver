`default_nettype none

module panel_cube (
  input            clk,
  input            valid,
  input            tick,
  input      [9:0] x, y,
  input            ack,
  output reg       validOut,
  output           ready,
  output reg [7:0] red, blue, green,
  output reg [7:0] alpha
);
  
  reg [9:0] offset = 0;
  wire [9:0] x_pos, y_pos;
  
  assign x_pos = x + offset;
  assign y_pos = y;
  
  wire [2:0] x_pos_off;
  assign x_pos_off = x_pos[2:0] - 3'd2;
  
  assign ready = 1;
  
  always @(posedge clk) begin
    if (ack)
      validOut <= 0;
    if (valid) begin
      if (tick) begin
        offset <= offset + 1;
      end else begin
        validOut <= 1;
        if (x_pos[2:0] > 1 && x_pos[2:0] < 6
            && y_pos[2:0] > 1 && y_pos[2:0] < 6) begin
          red <= 0;
          green <= 0;
          blue <= 8'h3F;
          alpha <= {x_pos_off[1:0], 6'h3F};
        end else begin
          red <= 0;
          green <= 0;
          blue <= 0;
          alpha <= 0;
        end
      end
    end
  end

endmodule // panel_cube