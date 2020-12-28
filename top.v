`default_nettype none

module top (
  input CLK,
  output PIN_1,
  output USBPU
);

  localparam PX_COUNT = 256;

  assign USBPU = 1'b0;
  
  reg [7:0] px_red = 0, px_blue = 0, px_green = 0;
  wire reset;
  wire px_valid, px_ready;
  
  wire bg_valid, bg_ready;
  wire [7:0] bg_red, bg_blue, bg_green;
  
  reg [9:0] index = 0;
  reg [9:0] index_mod = 0;
  wire [9:0] index_display;
  
  
  pixel_driver
    #(.CLK_HZ(16000000),
      .HZ(80),
      .LED(256))
    px (
    .clk(CLK),
    .red(px_red),
    .blue(px_blue),
    .green(px_green),
    .reset(reset),
    .valid(px_valid),
    .ready(px_ready),
    .clk_out(PIN_1)
  );
  
  panel_bg bg(
    .clk(CLK),
    .valid(bg_valid),
    .index(index_display),
    .ready(bg_ready),
    .red(bg_red),
    .blue(bg_blue),
    .green(bg_green),
    .alpha(),
    .blend()
  );
  
  assign bg_valid = px_ready;
  assign px_valid = px_ready;
  assign reset = (index == PX_COUNT);
  assign index_display = index + index_mod;
  
  always @(posedge CLK) begin
    if (px_ready) begin
      index <= index + 1;
      if (reset) begin
        index <= 0;
        index_mod <= index_mod - 1;
      end else begin
        px_red <= bg_red;
        px_blue <= bg_blue;
        px_green <= bg_green;
      end
    end
  end
  
endmodule // top