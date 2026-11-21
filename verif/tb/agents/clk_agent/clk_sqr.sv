
class clk_sqr extends uvm_sequencer #(clk_item);

  `uvm_component_utils(clk_sqr)


  // Construtor
  function new(string name = "clk_sqr",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new

endclass : clk_sqr
