package minisoc_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import clk_agent_pkg::*;
  import rst_agent_pkg::*;
  import spi_agent_pkg::*;
  import mem_data_agent_pkg::*;

  `include "minisoc_env_config.sv"
  `include "minisoc_scb.sv"
  `include "minisoc_env.sv"

endpackage : minisoc_env_pkg