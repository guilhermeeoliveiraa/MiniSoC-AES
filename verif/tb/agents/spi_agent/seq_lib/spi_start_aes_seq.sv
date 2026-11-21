
class spi_start_aes_seq extends spi_base_seq;

  `uvm_object_utils(spi_start_aes_seq)


  // Construtor
  function new(string name = "spi_start_aes_seq");

    super.new(name);

  endfunction : new


  // Executa a sequencia de inicializacao do AES
  task body();

    spi_item item;

    // Cria o item de escrita do registrador AES_CONTROL
    item = spi_item::type_id::create("start_aes_item");

    // Inicia a transferencia SPI
    start_item(item);

    // Configura a escrita do comando START
    item.op       = spi_item::SPI_WRITE;
    item.addr     = 6'h0B;
    item.reserved = 1'b0;
    item.data     = 32'h00000001;

    // Finaliza a transferencia SPI
    finish_item(item);

  endtask : body

endclass : spi_start_aes_seq
