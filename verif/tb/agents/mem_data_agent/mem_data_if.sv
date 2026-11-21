interface mem_data_if;

  logic        mem_clk;
  logic        mem_i_wr_en;
  logic [9:0]  mem_i_addr;
  logic [31:0] mem_i_data;
  logic [31:0] mem_o_data;

  // Modport utilizado pelo Driver
  modport drv_mp (
    output mem_clk,
    output mem_i_wr_en,
    output mem_i_addr,
    output mem_i_data,
    input  mem_o_data
  );

  // Modport utilizado pelo Monitor
  modport mon_mp (
    input mem_clk,
    input mem_i_wr_en,
    input mem_i_addr,
    input mem_i_data,
    input mem_o_data
  );

  // Modport utilizado pelo DUT
  modport dut_mp (
    input  mem_clk,
    input  mem_i_wr_en,
    input  mem_i_addr,
    input  mem_i_data,
    output mem_o_data
  );

endinterface : mem_data_if