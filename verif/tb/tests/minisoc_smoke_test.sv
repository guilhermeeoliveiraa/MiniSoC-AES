class minisoc_smoke_test extends minisoc_base_test;

  `uvm_component_utils(minisoc_smoke_test)


  // Construtor
  function new(string name = "minisoc_smoke_test",uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Executa o teste
  task run_phase(uvm_phase phase);

    minisoc_smoke_vseq smoke_seq;

    // Mantem a simulacao ativa durante a execucao do teste
    phase.raise_objection(this);

    // Cria a sequencia virtual de verificacao inicial
    smoke_seq = minisoc_smoke_vseq::type_id::create("smoke_seq");

    // Inicia a sequencia virtual no Virtual Sequencer
    smoke_seq.start(env.virtual_sequencer);

    // Finaliza a execucao do teste
    phase.drop_objection(this);

  endtask : run_phase

endclass : minisoc_smoke_test