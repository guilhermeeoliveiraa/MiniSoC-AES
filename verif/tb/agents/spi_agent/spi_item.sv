
class spi_item extends uvm_sequence_item;

  // Operações suportadas pelo protocolo SPI
  typedef enum logic {
    SPI_WRITE = 1'b0,
    SPI_READ  = 1'b1
  } spi_op_e;

  // Operação de leitura ou escrita
  rand spi_op_e op;
  // Endereço do registrador
  rand logic [5:0] addr;
  // Bit reservado do quadro SPI
  rand logic reserved;
  // Dados transmitidos pelo mestre
  rand logic [31:0] data;
  // Dados recebidos do dispositivo SPI
  logic [31:0] rx_data;


  // Registro dos campos para automação UVM
  `uvm_object_utils_begin(spi_item)

    `uvm_field_enum(spi_op_e, op, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(reserved, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(rx_data, UVM_ALL_ON)

  `uvm_object_utils_end


  // Construtor
  function new(string name = "spi_item");

    super.new(name);

  endfunction : new

endclass : spi_item
