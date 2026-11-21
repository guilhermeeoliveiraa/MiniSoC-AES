package spi_agent_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  `include "spi_item.sv"
  `include "spi_sqr.sv"
  `include "spi_drv.sv"
  `include "spi_mon.sv"
  `include "spi_agt.sv"

  // Sequencias
  `include "seq_lib/spi_base_seq.sv"
  `include "seq_lib/spi_start_aes_seq.sv"
  `include "seq_lib/spi_read_reg_seq.sv"
  
endpackage : spi_agent_pkg