package mem_data_agent_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  `include "mem_data_item.sv"
  `include "mem_data_sqr.sv"
  `include "mem_data_drv.sv"
  `include "mem_data_mon.sv"
  `include "mem_data_agt.sv"

  // Sequencias
  `include "seq_lib/mem_data_base_seq.sv"
  `include "seq_lib/mem_data_write_seq.sv"
  `include "seq_lib/mem_data_read_seq.sv"

endpackage : mem_data_agent_pkg