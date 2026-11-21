
class spi_base_seq extends uvm_sequence #(spi_item);

  `uvm_object_utils(spi_base_seq)


  // Construtor
  function new(string name = "spi_base_seq");

    super.new(name);

  endfunction : new

endclass : spi_base_seq
