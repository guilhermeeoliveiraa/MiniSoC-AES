class rst_sqr extends uvm_sequencer #(rst_item);
  `uvm_component_utils(rst_sqr)

  function new(string name = "rst_sqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : rst_sqr