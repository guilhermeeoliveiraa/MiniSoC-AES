class spi_read_reg_seq extends spi_base_seq;

  `uvm_object_utils(spi_read_reg_seq)

  // Endereco do registrador que sera lido
  rand logic [5:0] addr;


  // Construtor
  function new(string name = "spi_read_reg_seq");

    super.new(name);

  endfunction : new


  // Executa a sequencia de leitura SPI
  task body();

    spi_item item;

    // Primeira transferencia: solicita a leitura do endereco
    item = spi_item::type_id::create("read_request_item");

    start_item(item);

    item.op       = spi_item::SPI_READ;
    item.addr     = addr;
    item.reserved = 1'b0;
    item.data     = '0;

    finish_item(item);


    // Segunda transferencia: recebe os dados do registrador
    item = spi_item::type_id::create("read_response_item");

    start_item(item);

    item.op       = spi_item::SPI_READ;
    item.addr     = addr;
    item.reserved = 1'b0;
    item.data     = '0;

    finish_item(item);

  endtask : body

endclass : spi_read_reg_seq
