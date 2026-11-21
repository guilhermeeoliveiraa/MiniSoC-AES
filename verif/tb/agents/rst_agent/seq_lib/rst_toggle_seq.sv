
class rst_toggle_seq extends rst_base_seq;

  `uvm_object_utils(rst_toggle_seq)


  // Tempo de permanencia do reset ativo
  time hold_time = 5ns;


  // Construtor
  function new(string name = "rst_toggle_seq");

    super.new(name);

  endfunction : new


  // Executa a ativacao e liberacao do reset
  task body();

    rst_item item;

    // Cria o item de ativacao do reset
    item = rst_item::type_id::create("assert_item");

    // Inicia a transferencia
    start_item(item);

    // Configura o estado do reset
    item.rst_n = 1'b0;

    // Finaliza a transferencia
    finish_item(item);


    // Mantem o reset ativo durante o tempo configurado
    #(hold_time);


    // Cria o item de liberacao do reset
    item = rst_item::type_id::create("deassert_item");

    // Inicia a transferencia
    start_item(item);

    // Configura o estado do reset
    item.rst_n = 1'b1;

    // Finaliza a transferencia
    finish_item(item);

  endtask : body

endclass : rst_toggle_seq
