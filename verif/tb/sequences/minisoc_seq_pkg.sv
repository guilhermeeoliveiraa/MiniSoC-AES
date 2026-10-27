package minisoc_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  import clk_agent_pkg::*;
  import rst_agent_pkg::*;
  import spi_agent_pkg::*;
  import mem_data_agent_pkg::*;

  `include "minisoc_base_seq.sv"
  `include "minisoc_clk_seq.sv"
  `include "minisoc_rst_seq.sv"
  `include "minisoc_mem_seq.sv"
  `include "minisoc_spi_seq.sv"

endpackage : minisoc_seq_pkg