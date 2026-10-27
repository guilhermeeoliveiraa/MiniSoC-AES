class spi_sqr extends uvm_sequencer #(spi_item);
  `uvm_component_utils(spi_sqr)

  function new(string name = "spi_sqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : spi_sqr