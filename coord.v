module coord (
  input  [9:0] index,
  output [9:0] x,
  output [9:0] y);
  
  assign x = {3'h0, index[9:3]};
  assign y = {7'h00, (index[3] ? ~index[2:0] : index[2:0])};
endmodule // coord