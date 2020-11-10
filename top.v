`define ZR_CYC_HI 8  // .5 ns
`define ON_CYC_HI 20 // 1.25 ns (within 1.2 ns +- 150us)
`define CYC_COUNT 40 // 2.5 ns
`define CYC_BITS 6

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
  
  wire clk_lo, clk_hi, clk_bit;
  ws2811_clk led_clk (
    .clk(CLK),
    .clk_lo(clk_lo),
    .clk_hi(clk_hi),
    .clk_bit(clk_bit)
  );
  
  reg [7:0][2:0][2:0] rgb = 72'hf00_0f0_00f;
  
  // TODO: write the basic pixel queue, refresh on verilog indexing
  
  
endmodule // top
  
module ws2811_clk (
  input clk,
  output clk_lo,
  output clk_hi,
  output clk_bit
);

  reg [CYC_BITS-1:0] counter;
  
  always @(posedge clk) begin
    if (counter < CYC_COUNT) begin
      counter <= counter + 1;
      clk_bit <= 1'b0;
      if (!(counter < ZR_CYC_HI)) // counter >= zero hi length
        clk_lo <= 1'b0;
      if (!(counter < ON_CYC_HI)) // counter >= one hi length
        clk_hi <= 1'b0;
    else begin
      counter <= 1'b0;
      clk_lo <= 1'b1;
      clk_hi <= 1'b1;
      clk_bit <= 1'b1;
    end
  end

endmodule // ws2811_clk