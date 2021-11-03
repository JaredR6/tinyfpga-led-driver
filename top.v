`default_nettype none

module top (
  input CLK,
  output PIN_1,
  output USBPU
);

  localparam PX_COUNT = 298;

  assign USBPU = 1'b0;
  
  // Inputs and Outputs
  
  reg [9:0] cd_index;
  wire [9:0] cd_x, cd_y;
  
  coord cd(
    .index(cd_index),
    .x(cd_x),
    .y(cd_y)
  );  
  
  reg pixel_valid, pixel_tick;
  reg [9:0] pixel_x, pixel_y;
  reg pixel_ack;
  wire pixel_validOut, pixel_ready;
  wire [7:0] pixel_red, pixel_green, pixel_blue, pixel_alpha;
  
  panel_pulse pixel(
    .clk(CLK),
    .valid(pixel_valid),
    .tick(pixel_tick),
    .x(pixel_x),
    .y(pixel_y),
    .ack(pixel_ack),
    .validOut(pixel_validOut),
    .ready(pixel_ready),
    .red(pixel_red),
    .green(pixel_green),
    .blue(pixel_blue),
    .alpha(pixel_alpha)
  );
    
  reg [7:0] px_red, px_green, px_blue;
  reg px_reset, px_valid;
  wire px_ready;
  
  pixel_driver
    #(.CLK_HZ(16000000),
      .HZ(80),
      .LED(PX_COUNT))
    px(
    .clk(CLK),
    .red(px_red),
    .green(px_green),
    .blue(px_blue),
    .reset(px_reset),
    .valid(px_valid),
    .ready(px_ready),
    .clk_out(PIN_1)
  );
  
  
  // Connections
  
  reg [9:0] index = 0;
  reg renderValid, renderTick, renderReady;
  reg outValid, outReset, outReady;
  
  reg [9:0] x, y;
  
  
  always @(*) begin
    cd_index = index;
    x = cd_x;
    y = cd_y;
    
    pixel_valid = renderValid;
    pixel_tick = renderTick;
    pixel_x = index;
    pixel_y = 0;
    pixel_ack = renderValid;
    
    px_red = pixel_red;
    px_green = pixel_green;
    px_blue = pixel_blue;
    
    outReset = (index == PX_COUNT);
    outReady = px_ready;
    outValid = outReady;
    
    px_reset = outReset;
    px_valid = outValid;
    
  end
  
  always @(posedge CLK) begin
    renderValid <= 0;
    renderTick <= 0;
    if (outReady) begin
      renderValid <= 1;
      if (outReset) begin
        index <= 0;
      end else begin
        index <= index + 1;
        if (index == PX_COUNT - 1)
          renderTick <= 1;
      end
    end
  end
  
endmodule // top