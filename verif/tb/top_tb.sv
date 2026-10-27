module tb_top;
  import uvm_pkg::*;
  import minisoc_test_pkg::*;
  `include "uvm_macros.svh"

  clk_if clk_vif();

  rst_if rst_vif(
    .clk(clk_vif.clk)
  );

  wire clk = clk_vif.clk;
  wire rst_n = rst_vif.rst_n;

  spi_if spi_vif(
    .clk(clk),
    .rst_n(rst_n)
  );

  mem_data_if mem_vif(
    .clk(clk),
    .rst_n(rst_n)
  );

  minisoc_top dut(
    .clk(clk),
    .rst_n(rst_n),
    .spi_sclk(spi_vif.sclk),
    .spi_cs_n(spi_vif.cs_n),
    .spi_mosi(spi_vif.mosi),
    .spi_miso(spi_vif.miso),
    .mem_clk(clk),
    .mem_i_data(mem_vif.wdata),
    .mem_i_wr_en(mem_vif.en && mem_vif.we),
    .mem_i_addr(mem_vif.addr),
    .mem_o_data(mem_vif.rdata)
  );

  top_assertions u_top_assertions(
    .clk(clk),
    .rst_n(rst_n),
    .spi_cs_n(spi_vif.cs_n),
    .spi_sclk(spi_vif.sclk)
  );

  initial begin
    uvm_config_db#(virtual clk_if)::set(
      null, "*", "clk_vif", clk_vif
    );

    uvm_config_db#(virtual rst_if)::set(
      null, "*", "rst_vif", rst_vif
    );

    uvm_config_db#(virtual spi_if)::set(
      null, "*", "spi_vif", spi_vif
    );

    uvm_config_db#(virtual mem_data_if)::set(
      null, "*", "mem_vif", mem_vif
    );

    run_test();
  end

  initial begin
    $fsdbDumpfile("waves.fsdb");
    $fsdbDumpvars(0, tb_top, "+all");
  end

endmodule : tb_top