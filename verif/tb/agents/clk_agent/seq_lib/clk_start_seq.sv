class clk_start_seq extends clk_base_seq;

  `uvm_object_utils(clk_start_seq)


  // Construtor
  function new(string name = "clk_start_seq");

    super.new(name);

  endfunction : new


  // Executa a sequencia de inicializacao do clock
  task body();

    clk_item item;

    // Cria o item de inicializacao
    item = clk_item::type_id::create("start_item");

    // Inicia a transferencia
    start_item(item);

    // Configura os campos da transacao
    item.enable    = 1'b1;
    item.period_ps = period_ps;

    // Finaliza a transferencia
    finish_item(item);

  endtask : body

endclass : clk_start_seq