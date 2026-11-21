package clk_agent_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  `include "clk_item.sv"
  `include "clk_sqr.sv"
  `include "clk_drv.sv"
  `include "clk_mon.sv"
  `include "clk_agt.sv"

  // Sequencias
  `include "seq_lib/clk_base_seq.sv"
  `include "seq_lib/clk_start_seq.sv"
  `include "seq_lib/clk_stop_seq.sv"

endpackage : clk_agent_pkg