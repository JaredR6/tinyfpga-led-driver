`default_nettype none

module panel_bg (
  input            clk,
  input            valid,
  input            tick,
  input      [9:0] x, y,
  input            ack,
  output reg       validOut,
  output           ready,
  output reg [7:0] red, green, blue,
  output reg [7:0] alpha
);
  
  reg [10:0] offset = 0;
  wire [9:0] x_pos, y_pos;
  
  assign x_pos = x;
  assign y_pos = y + {6'h00, offset[4:1]};
  
  assign ready = 1;
  
  always @(posedge clk) begin
    if (ack)
      validOut <= 0;
    if (valid) begin
      if (tick) begin
        offset <= offset + 1;
      end else begin
        red <= {5'h00, x_pos[2:0]};
        green <= {2'h0, x_pos[7:3], 1'b0};
        blue <= 8'h00;
        alpha <= 8'hFF;
        validOut <= 1;
      end
    end
  end

endmodule // panel_bg