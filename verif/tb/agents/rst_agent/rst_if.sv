
interface rst_if;

  logic rst_n;

  // Modport utilizado pelo DUT
  modport dut_mp (
    input rst_n
  );

  // Modport utilizado pelo Driver
  modport drv_mp (
    output rst_n
  );

  // Modport utilizado pelo Monitor
  modport mon_mp (
    input rst_n
  );

endinterface : rst_if
  