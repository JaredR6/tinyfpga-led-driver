`default_nettype none
//
// WS2811 Driver
//

module top (
  input CLK, // 16 MHz
  output LED,
  output PIN_1,
  output USBPU
);

  // LED Sample code

  reg [25:0] clk_1hz_divider = 26'b0;
  reg        clk_1hz = 1'b0;
  
  always @(posedge CLK) begin
    if (clk_1hz_divider < 26'd47_999_999) // 
      clk_1hz_divider <= clk_1hz_divider + 1;
    else begin
      clk_1hz_divider <= 0;
      clk_1hz <= ~clk_1hz;
    end
  end
  
  assign LED = clk_1hz;
  assign USBPU = 1'b0;

  // Pixel driver
  
  reg reset=0, valid=0;
  reg [23:0] color;
  wire ready;
  reg [1:0] counter=0;
  reg [71:0] colors = 72'hff0000_00ff00_0000ff;
  reg [8:0] px_count = 0;
  
  pixel_driver px(
    .clk(CLK),
    .color(color),
    .reset(reset),
    .valid(valid),
    .ready(ready),
    .clk_out(PIN_1)
  );
  
  always @(*) begin
    valid = (reset || (counter < 3 && ready));
    reset = clk_1hz;
    color = (counter < 150 ? 24'hffffff : colors[71:48]);
  
  end
  
  always @(posedge CLK) begin
    if (ready) begin
      if (~clk_1hz) begin
        counter <= counter + 1;
        if (counter < 150)
          colors <= {colors[47:0], colors[71:48]};
      end else
        counter <= 0;
    end
  end
  
endmodule // top