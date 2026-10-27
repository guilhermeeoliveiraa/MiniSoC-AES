interface clk_if;
  timeunit 1ns;
  timeprecision 1ps;

  logic clk;
  real period = 10.0;

  initial begin
    clk = 1'b0;
    forever #(period / 2.0) clk = ~clk;
  end

  clocking drv_cb @(posedge clk);
    default input #1step output #1ns;
  endclocking : drv_cb

endinterface : clk_if