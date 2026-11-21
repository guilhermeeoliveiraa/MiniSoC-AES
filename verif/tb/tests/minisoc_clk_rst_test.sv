class minisoc_clk_rst_test extends minisoc_base_test;

  `uvm_component_utils(minisoc_clk_rst_test)


  // Construtor
  function new(string name = "minisoc_clk_rst_test", uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Executa o teste
  task run_phase(uvm_phase phase);

    minisoc_clk_rst_vseq clk_rst_seq;

    // Mantem a simulacao ativa durante a execucao do teste
    phase.raise_objection(this);

    // Cria a sequencia virtual de verificacao de clock e reset
    clk_rst_seq = minisoc_clk_rst_vseq::type_id::create("clk_rst_seq");

    // Inicia a sequencia virtual no Virtual Sequencer
    clk_rst_seq.start(env.virtual_sequencer);

    // Finaliza a execucao do teste
    phase.drop_objection(this);

  endtask : run_phase

endclass : minisoc_clk_rst_test
