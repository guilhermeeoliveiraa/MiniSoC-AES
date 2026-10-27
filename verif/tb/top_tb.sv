module tb_top;
  import minisoc_test_pkg::*;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam int MEM_ADDR_WIDTH = 16;
  localparam int MEM_DATA_WIDTH = 32;

  clk_if clk_vif ();
  rst_if rst_vif (
    .clk(clk_vif.clk)
  );

  wire clk   = clk_vif.clk;
  wire rst_n = rst_vif.rst_n;

  spi_if spi_vif (
    .clk   (clk),
    .rst_n (rst_n)
  );

  mem_data_if mem_vif (
    .clk   (clk),
    .rst_n (rst_n)
  );

  minisoc_aes_top dut (
    .clk             (clk_vif.clk),
    .rst_n           (rst_vif.rst_n),

    .cfg_start       (1'b0),
    .cfg_decrypt     (1'b0),
    .cfg_mode        (3'b0),
    .cfg_num_blocks  (9'b0),
    .cfg_key         (128'b0),
    .cfg_iv          (128'b0),
    .cfg_counter     (64'b0),

    .busy            (),
    .done            (),
    .error           (),
    .blocks_done     (),

    .mem_en           (mem_vif.en),
    .mem_wr_en        (mem_vif.we),
    .mem_addr         (mem_vif.addr),
    .mem_wdata        (mem_vif.wdata),
    .mem_rdata        (mem_vif.rdata)
  );

  top_assertions u_top_assertions (
    .clk      (clk),
    .rst_n    (rst_n),
    .spi_cs_n (spi_vif.cs_n),
    .spi_sclk (spi_vif.sclk)
  );

  initial begin
    $display("[TB_TOP] Passou pelo inicio do initial block!");

    uvm_config_db#(virtual clk_if)::set(null, "*", "clk_vif", clk_vif);
    uvm_config_db#(virtual rst_if)::set(null, "*", "rst_vif", rst_vif);
    uvm_config_db#(virtual spi_if)::set(null, "*", "spi_vif", spi_vif);
    uvm_config_db#(virtual mem_data_if)::set(null, "*", "mem_vif", mem_vif);

    run_test();
  end

  initial begin
      $fsdbDumpfile("waves.fsdb");
      $fsdbDumpvars(0, tb_top, "+all");
  end

endmodule : tb_top