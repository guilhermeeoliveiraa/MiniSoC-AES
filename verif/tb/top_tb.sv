module tb_top;

  import uvm_pkg::*;
  import minisoc_test_pkg::*;

  `include "uvm_macros.svh"

  // Instanciação das interfaces
  clk_if clk_vif();
  rst_if rst_vif();
  spi_if spi_vif();
  mem_data_if mem_vif();

  // Instanciação do DUT
  minisoc_top dut(
    .clk(clk_vif.clk),
    .rst_n(rst_vif.rst_n),
    .spi_sclk(spi_vif.sclk),
    .spi_cs_n(spi_vif.cs_n),
    .spi_mosi(spi_vif.mosi),
    .spi_miso(spi_vif.miso),
    .mem_clk(mem_vif.mem_clk),
    .mem_i_data(mem_vif.mem_i_data),
    .mem_i_wr_en(mem_vif.mem_i_wr_en),
    .mem_i_addr(mem_vif.mem_i_addr),
    .mem_o_data(mem_vif.mem_o_data)
  );

  // Instanciação do módulo de assertions

  top_assertions u_top_assertions(
    .clk(clk_vif.clk),
    .rst_n(rst_vif.rst_n),
    .spi_cs_n(spi_vif.cs_n),
    .spi_sclk(spi_vif.sclk)
  );

  initial begin

    // Resgistrando as interfaces no banco de configuração do UVM
    // Os componentes acessem as IF usando get()

    // Registra a interface de Clock
    uvm_config_db#(virtual clk_if.drv_mp)::set(null, "*", "clk_drv_vif", clk_vif);
    uvm_config_db#(virtual clk_if.mon_mp)::set(null, "*", "clk_mon_vif", clk_vif);

    // Registra a interface de Reset
    uvm_config_db#(virtual rst_if.drv_mp)::set(null, "*", "rst_drv_vif", rst_vif);
    uvm_config_db#(virtual rst_if.mon_mp)::set(null, "*", "rst_mon_vif", rst_vif);

    // Registra as interfaces de SPI
    uvm_config_db#(virtual spi_if.drv_mp)::set(null, "*", "spi_drv_vif", spi_vif);
    uvm_config_db#(virtual spi_if.mon_mp)::set(null, "*", "spi_mon_vif", spi_vif);

    // Registra as interfaces de Memoria  
    uvm_config_db#(virtual mem_data_if.drv_mp)::set(null, "*", "mem_data_drv_vif", mem_vif);
    uvm_config_db#(virtual mem_data_if.mon_mp)::set(null, "*", "mem_data_mon_vif", mem_vif);
  
    run_test();
    
  end

  initial begin
    $fsdbDumpfile("waves.fsdb");
    $fsdbDumpvars(0, tb_top, "+all");
  end

endmodule : tb_top