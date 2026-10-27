interface spi_if (
  input logic clk,
  input logic rst_n
);

  logic sclk;
  logic cs_n;
  logic mosi;
  logic miso;

  clocking drv_cb @(posedge clk);
    default input #1step output #1ns;
    output sclk;
    output cs_n;
    output mosi;
    input  miso;
  endclocking : drv_cb

  clocking mon_cb @(posedge clk);
    default input #1step output #1ns;
    input sclk;
    input cs_n;
    input mosi;
    input miso;
  endclocking : mon_cb

  modport dut_mp (
    input  sclk, cs_n, mosi,
    output miso
  );

endinterface : spi_if