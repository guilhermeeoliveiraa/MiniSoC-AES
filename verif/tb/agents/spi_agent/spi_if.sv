interface spi_if;

  logic sclk;
  logic cs_n;
  logic mosi;
  logic miso;

  // Modport utilizado pelo Driver
  modport drv_mp (
    output sclk,
    output cs_n,
    output mosi,
    input  miso
  );

  // Modport utilizado pelo Monitor
  modport mon_mp (
    input sclk,
    input cs_n,
    input mosi,
    input miso
  );

  // Modport utilizado pelo DUT
  modport dut_mp (
    input  sclk,
    input  cs_n,
    input  mosi,
    output miso
  );

endinterface : spi_if