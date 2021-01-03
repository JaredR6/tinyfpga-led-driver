`default_nettype none

module top (
  input CLK,
  output PIN_1,
  output USBPU
);

  localparam PX_COUNT = 256;

  assign USBPU = 1'b0;
  
  // Inputs and Outputs
  
  reg [9:0] cd_index;
  wire [9:0] cd_x, cd_y;
  
  coord cd(
    .index(cd_index),
    .x(cd_x),
    .y(cd_y)
  );  
  
  reg bg_valid, bg_tick;
  reg [9:0] bg_x, bg_y;
  reg bg_ack;
  wire bg_validOut, bg_ready;
  wire [7:0] bg_red, bg_green, bg_blue, bg_alpha;
  
  panel_bg bg(
    .clk(CLK),
    .valid(bg_valid),
    .tick(bg_tick),
    .x(bg_x),
    .y(bg_y),
    .ack(bg_ack),
    .validOut(bg_validOut),
    .ready(bg_ready),
    .red(bg_red),
    .green(bg_green),
    .blue(bg_blue),
    .alpha(bg_alpha)
  );
  
  reg cube_valid, cube_tick;
  reg [9:0] cube_x, cube_y;
  reg cube_ack;
  wire cube_validOut, cube_ready;
  wire [7:0] cube_red, cube_green, cube_blue, cube_alpha;
  
  panel_cube cube(
    .clk(CLK),
    .valid(cube_valid),
    .tick(cube_tick),
    .x(x),
    .y(y),
    .ack(cube_ack),
    .validOut(cube_validOut),
    .ready(cube_ready),
    .red(cube_red),
    .green(cube_green),
    .blue(cube_blue),
    .alpha(cube_alpha)
  );
  
  reg alpha_cube_bg_valid;
  reg [23:0] alpha_cube_bg_colorTop, alpha_cube_bg_colorBot;
  reg [7:0] alpha_cube_bg_alphaTop;
  reg alpha_cube_bg_ack;
  wire alpha_cube_bg_validOut, alpha_cube_bg_ready;
  wire [23:0] alpha_cube_bg_colorOut;
  
  alpha_blend alpha_cube_bg(
    .clk(CLK),
    .valid(alpha_cube_bg_valid),
    .colorTop(alpha_cube_bg_colorTop),
    .colorBot(alpha_cube_bg_colorBot),
    .alphaTop(alpha_cube_bg_alphaTop),
    .ack(alpha_cube_bg_ack),
    .validOut(alpha_cube_bg_validOut),
    .ready(alpha_cube_bg_ready),
    .colorOut(alpha_cube_bg_colorOut)
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
    
    bg_valid = renderValid;
    bg_tick = renderTick;
    bg_x = x;
    bg_y = y;
    bg_ack = ~alpha_cube_bg_ready;
    
    cube_valid = renderValid;
    cube_tick = renderTick;
    cube_x = x;
    cube_y = y;
    cube_ack = ~alpha_cube_bg_ready;
    
    alpha_cube_bg_valid = cube_validOut & bg_validOut;
    alpha_cube_bg_colorTop = {cube_red, cube_green, cube_blue};
    alpha_cube_bg_colorBot = {bg_red, bg_green, bg_blue};
    alpha_cube_bg_alphaTop = cube_alpha;
    alpha_cube_bg_ack = renderValid;
    
    px_red = alpha_cube_bg_colorOut[23:16];
    px_green = alpha_cube_bg_colorOut[15:8];
    px_blue = alpha_cube_bg_colorOut[7:0];
    
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