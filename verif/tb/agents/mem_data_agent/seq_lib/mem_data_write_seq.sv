class mem_data_write_seq extends mem_data_base_seq;

  `uvm_object_utils(mem_data_write_seq)

  // Endereco da memoria que sera escrito
  rand logic [9:0] addr;

  // Dado que sera escrito na memoria
  rand logic [31:0] data;


  // Construtor
  function new(string name = "mem_data_write_seq");

    super.new(name);

  endfunction : new


  // Executa a sequencia de escrita na memoria
  task body();

    mem_data_item item;

    // Cria o item de escrita
    item = mem_data_item::type_id::create("write_item");

    // Inicia a transferencia
    start_item(item);

    // Configura os campos da transacao
    item.en    = 1'b1;
    item.we    = 1'b1;
    item.addr  = addr;
    item.wdata = data;

    // Finaliza a transferencia
    finish_item(item);

  endtask : body

endclass : mem_data_write_seq