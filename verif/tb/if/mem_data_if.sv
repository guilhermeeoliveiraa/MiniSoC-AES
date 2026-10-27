interface mem_data_if (
  input logic clk,
  input logic rst_n
);
  logic        en;
  logic        we;
  logic [9:0]  addr;
  logic [31:0] wdata;
  logic [31:0] rdata;

  clocking drv_cb @(posedge clk);
    default input #1step output #1ns;
    input  en;
    input  we;
    input  addr;
    input  wdata;
    output rdata;
  endclocking : drv_cb

  clocking mon_cb @(posedge clk);
    default input #1step output #1ns;
    input en;
    input we;
    input addr;
    input wdata;
    input rdata;
  endclocking : mon_cb

  modport dut_mp (
    output en,
    output we,
    output addr,
    output wdata,
    input  rdata
  );
endinterface : mem_data_if