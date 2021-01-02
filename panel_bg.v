`default_nettype none

module panel_bg (
  input        clk,
  input        valid,
  input  [9:0] index,
  output       ready,
  output [7:0] red, blue, green,
  output [7:0] alpha,
  output [1:0] blend
);

  wire [9:0] true_index;
  assign true_index = {index[9:3], (index[3] ? ~index[2:0] : index[2:0])};

  assign red = {5'h00, true_index[2:0]};
  assign blue = {5'h00, true_index[5:3]};
  assign green = {5'h00, true_index[8:6]};
  assign alpha = 8'hFF;
  assign blend = 2'h0;
  assign ready = valid;

endmodule // panel_bg