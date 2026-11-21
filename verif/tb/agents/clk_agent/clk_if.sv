interface clk_if;

  logic clk;

  // Modport utilizado pelo DUT
  modport dut_mp (
    input clk
  );

  // Modport utilizado pelo Driver
  modport drv_mp (
    output clk
  );

  // Modport utilizado pelo Monitor
  modport mon_mp (
    input clk
  );

endinterface : clk_if