class mem_data_sqr extends uvm_sequencer #(mem_data_item);
  `uvm_component_utils(mem_data_sqr)

  function new(string name = "mem_data_sqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : mem_data_sqr