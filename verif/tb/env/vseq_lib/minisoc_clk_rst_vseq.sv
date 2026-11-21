class minisoc_clk_rst_vseq extends minisoc_base_vseq;

  `uvm_object_utils(minisoc_clk_rst_vseq)


  // Construtor
  function new(string name = "minisoc_clk_rst_vseq");

    super.new(name);

  endfunction : new


  // Corpo da sequencia
  task body();

    clk_start_seq clk_seq;
    rst_toggle_seq rst_seq;
    rst_start_seq rst_start;
    rst_stop_seq rst_stop;


    // Inicia a geracao do clock
    `uvm_info("CLK_RST_VSEQ", "Iniciando geracao do clock",  UVM_LOW)

    clk_seq = clk_start_seq::type_id::create("clk_seq");

    // Configura o periodo do clock em 500 ps (2 GHz)
    clk_seq.period_ps = 500;

    clk_seq.start(p_sequencer.clk_sqr);


    //Aplica e libera o reset do MiniSoC
    `uvm_info("CLK_RST_VSEQ", "Aplicando reset ao MiniSoC", UVM_LOW)

    rst_seq = rst_toggle_seq::type_id::create("rst_seq");

    rst_seq.hold_time = 5ns; // 10 ciclos de clock

    rst_seq.start(p_sequencer.rst_sqr);


    `uvm_info("CLK_RST_VSEQ", "Inicializacao de clock e reset finalizada",  UVM_LOW)

  endtask : body

endclass : minisoc_clk_rst_vseq