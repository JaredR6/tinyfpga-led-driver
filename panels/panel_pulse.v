`default_nettype none

module panel_pulse (
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
  
  reg [7:0] offset = 0;
  
  assign ready = 1;
  
  always @(posedge clk) begin
    if (ack)
      validOut <= 0;
    if (valid) begin
      if (tick) begin
        offset <= offset + 1;
      end else begin
        validOut <= 1;
        red <= 8'h00;
        if (x[3:0] == offset[5:2]) begin
          blue <= 8'h10;
        end else begin
          blue <= 8'h00;
        end
        green <= 8'h00;
        alpha <= 8'hFF;
      end
    end
  end

endmodule // panel_bg