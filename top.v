//
// WS2811 Driver
//

module top (
  input CLK, // 16 MHz
  output LED,
  output USBPU
);

  // LED Sample code

  reg [22:0] clk_1hz_divider = 23'b0;
  reg        clk_1hz = 1'b0;
  
  always @(posedge CLK) begin
    if (clk_1hz_divider < 23'd7_999_999) // 
      clk_1hz_divider <= clk_1hz_divider + 23'd1;
    else begin
      clk_1hz_divider <= 23'b0;
      clk_1hz <= ~clk_1hz;
    end
  end
  
  assign LED = clk_1hz;
  assign USBPU = 1'b0;

  // Pixel driver
  
  // TODO: add pixel driver once ready
  // TODO: integrate serial
  
  
endmodule // top