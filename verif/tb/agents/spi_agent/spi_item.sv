class spi_item extends uvm_sequence_item;
  typedef enum logic { SPI_READ = 1'b0, SPI_WRITE = 1'b1 } spi_op_e;

  rand spi_op_e     op;
  rand logic [7:0]  addr;
  rand logic [31:0] data;
  rand logic [31:0] rx_data; // <-- Adicionado

  `uvm_object_utils_begin(spi_item)
    `uvm_field_enum(spi_op_e, op,      UVM_ALL_ON)
    `uvm_field_int(addr,               UVM_ALL_ON)
    `uvm_field_int(data,               UVM_ALL_ON)
    `uvm_field_int(rx_data,            UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "spi_item");
    super.new(name);
  endfunction : new
  
endclass : spi_item