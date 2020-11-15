`default_nettype none

module top (
  input CLK, // 16 MHz
  output LED,
  output PIN_1,
  output USBPU
);

  // LED Sample code

  reg [25:0] clk_4hz_divider = 26'b0;
  reg  [1:0] clk_4hz = 2'b0;
  
  always @(posedge CLK) begin
    if (clk_4hz_divider < 26'd7_999_999) // 
      clk_4hz_divider <= clk_4hz_divider + 1;
    else begin
      clk_4hz_divider <= 0;
      clk_4hz <= clk_4hz + 1;
    end
  end
  
  assign LED = (clk_4hz[1] == 1'b1);
  assign USBPU = 1'b0;

  // Pixel driver
  
  wire reset, valid, active;
  wire [23:0] color;
  wire ready;
  reg [7:0] counter = 0;
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
  
  localparam pxcount = 3;
  
  assign active = (counter < pxcount);
  assign reset = (counter == pxcount);
  assign valid = ((active || reset) && ready);
  assign color = (active ? colors[71:48] : 24'hxxxxxx );
  
  always @(posedge CLK) begin
    if (ready) begin
      if (LED) begin
        counter <= 0;
      end else begin
        if (active || reset) begin
          counter <= counter + 1;
          if (active)
            colors <= {colors[47:0], colors[71:48]};
        end
      end
    end
  end
  
endmodule // top