class clk_stop_seq extends clk_base_seq;

  `uvm_object_utils(clk_stop_seq)


  // Construtor
  function new(string name = "clk_stop_seq");

    super.new(name);

  endfunction : new


  // Executa a sequencia de parada do clock
  task body();

    clk_item item;

    // Cria o item de parada
    item = clk_item::type_id::create("stop_item");

    // Inicia a transferencia
    start_item(item);

    // Configura os campos da transacao
    item.enable = 1'b0;

    // Finaliza a transferencia
    finish_item(item);

  endtask : body

endclass : clk_stop_seq