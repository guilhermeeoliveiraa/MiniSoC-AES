  package minisoc_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import clk_agent_pkg::*;
    import rst_agent_pkg::*;
    import spi_agent_pkg::*;
    import mem_data_agent_pkg::*;
    import minisoc_env_pkg::*;
    import minisoc_seq_pkg::*;

    `include "minisoc_base_test.sv"
    `include "minisoc_rst_clk_test.sv"

  endpackage : minisoc_test_pkg   