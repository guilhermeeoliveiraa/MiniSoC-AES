
class spi_write_reg_seq extends spi_base_seq;

  `uvm_object_utils(spi_write_reg_seq)

  // Endereco do registrador que sera escrito
  rand logic [5:0] addr;

  // Valor que sera escrito no registrador
  rand logic [31:0] data;


  // Construtor
  function new(string name = "spi_write_reg_seq");

    super.new(name);

  endfunction : new


  // Executa a sequencia de escrita SPI
  task body();

    spi_item item;

    // Cria o item de escrita
    item = spi_item::type_id::create("write_item");

    // Inicia a transferencia
    start_item(item);

    // Configura os campos da transacao
    item.op       = spi_item::SPI_WRITE;
    item.addr     = addr;
    item.reserved = 1'b0;
    item.data     = data;

    // Finaliza a transferencia
    finish_item(item);

  endtask : body

endclass : spi_write_reg_seq
