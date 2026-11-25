class minisoc_random_test extends minisoc_base_test;

  `uvm_component_utils(minisoc_random_test)


  // Construtor
  function new(string name = "minisoc_random_test",uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Executa o teste
  task run_phase(uvm_phase phase);

    minisoc_random_vseq random_seq;

    // Mantem a simulacao ativa durante a execucao do teste
    phase.raise_objection(this);

    // Cria a sequencia virtual de verificacao
    random_seq = minisoc_random_vseq::type_id::create("random_seq");

    // Inicia a sequencia virtual no Virtual Sequencer
    random_seq.start(env.virtual_sequencer);

    // Finaliza a execucao do teste
    phase.drop_objection(this);

  endtask : run_phase

endclass : minisoc_random_test