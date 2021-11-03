`default_nettype none

module panel_pixel (
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
  
  reg [7:0] offset = 0;
  wire [9:0] x_pos, y_pos;
  
  assign x_pos = x + offset;
  assign y_pos = y;
  
  wire [2:0] x_pos_off;
  assign x_pos_off = x_pos[2:0];
  
  assign ready = 1;
  
  always @(posedge clk) begin
    if (ack)
      validOut <= 0;
    if (valid) begin
      if (tick) begin
        if ((offset + 8'd1) == 8'h08) begin
          offset <= 0;
        end else begin
          offset <= offset + 1;
        end
      end else begin
        validOut <= 1;
        if (offset[2:0] == x_pos_off) begin
          red <= {1'b1, 7'b0};
          green <= 0;
          blue <= 0;
          alpha <= 0;
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