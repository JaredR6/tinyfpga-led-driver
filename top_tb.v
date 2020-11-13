`timescale 1ns/10ps

module top_tb ();

  reg CLK=0;
  wire LED, PIN_1, USBPU;

  top tp(
    .CLK(CLK),
    .LED(LED),
    .PIN_1(PIN_1),
    .USBPU(USBPU)
  );
  
  always #1 CLK = ~CLK;
  
  initial begin
    $dumpfile("top_tb.vcd");  // waveforms file
    $dumpvars;  // save waveforms
    $display("%d %m: Starting testbench simulation...", $stime);
    $monitor("%d %m: MONITOR - LED = %d, PIN_1 = %d", $stime, LED, PIN_1);
    repeat(5000) @(posedge CLK);
    #1 $display("%d %m: Testbench simulation finished.", $stime);
    $finish;  // end simulation
 end


endmodule // top_tb 