interface rst_if (
  input logic clk
);

  logic rst_n;

  initial rst_n = 1'b0;

  clocking drv_cb @(posedge clk);
    default input #1step output #1ns;
    output rst_n;
  endclocking : drv_cb

  clocking mon_cb @(posedge clk);
    default input #1step output #1ns;
    input rst_n;
  endclocking : mon_cb   

  modport dut_mp (
    input rst_n
  );

endinterface : rst_if