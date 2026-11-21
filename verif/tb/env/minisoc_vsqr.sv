class minisoc_vsqr extends uvm_sequencer;

  `uvm_component_utils(minisoc_vsqr)

  // Sequencers dos agentes
  spi_sqr      spi_sqr;
  mem_data_sqr mem_data_sqr;
  clk_sqr      clk_sqr;
  rst_sqr      rst_sqr;


  // Construtor
  function new(string name = "minisoc_vsqr",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new

endclass : minisoc_vsqr