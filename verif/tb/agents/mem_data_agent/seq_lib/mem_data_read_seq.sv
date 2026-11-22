
class mem_data_read_seq extends mem_data_base_seq;

  `uvm_object_utils(mem_data_read_seq)

  // Endereco da memoria que sera lido
  rand logic [9:0] addr;

  // Dado retornado pela memoria
  logic [31:0] rdata;


  // Construtor
  function new(string name = "mem_data_read_seq");

    super.new(name);

  endfunction : new


  // Executa a sequencia de leitura da memoria
  task body();

    mem_data_item item;
    mem_data_item rsp;

    // Cria o item de leitura
    item = mem_data_item::type_id::create("read_item");

    // Inicia a transferencia
    start_item(item);

    // Configura os campos da transacao
    item.en    = 1'b1;
    item.we    = 1'b0;
    item.addr  = addr;
    item.wdata = '0;

    // Finaliza a transferencia
    finish_item(item);

    // Recebe a resposta do Driver
    get_response(rsp);

    // Armazena o dado lido
    rdata = rsp.rdata;

  endtask : body

endclass : mem_data_read_seq
