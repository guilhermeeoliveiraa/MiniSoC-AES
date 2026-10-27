class minisoc_smoke_test extends minisoc_base_test;
  `uvm_component_utils(minisoc_smoke_test)

  minisoc_clk_seq clk_seq;
  minisoc_rst_seq rst_seq;
  minisoc_spi_seq spi_seq;
  minisoc_mem_seq mem_seq;

  virtual rst_if rst_vif;

  function new(string name = "minisoc_smoke_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void configure_env(minisoc_env_config cfg);
    cfg.has_spi_agent = 1;
    cfg.has_mem_agent = 1;
    cfg.has_scoreboard = 1;
  endfunction : configure_env

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual rst_if)::get(
          this, "", "rst_vif", rst_vif)) begin
      `uvm_fatal("RST_VIF", "Nao foi possivel obter rst_vif")
    end
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("SMOKE", "Iniciando teste integrado MiniSoC AES", UVM_NONE)

    clk_seq = minisoc_clk_seq::type_id::create("clk_seq");
    rst_seq = minisoc_rst_seq::type_id::create("rst_seq");

    clk_seq.start(env.clk_agent.sqr);
    rst_seq.start(env.rst_agent.sqr);

    wait (rst_vif.rst_n === 1'b1);
    repeat (10) @(posedge rst_vif.clk);

    spi_seq = minisoc_spi_seq::type_id::create("spi_init_pll_seq");
    spi_seq.operation = minisoc_spi_seq::SPI_SEQ_INIT_PLL;
    spi_seq.start(env.spi_agent.sqr);

    mem_seq = minisoc_mem_seq::type_id::create("mem_write_seq");
    mem_seq.operation = minisoc_mem_seq::MEM_WRITE_WORDS;
    mem_seq.start(env.mem_agent.sqr);

    spi_seq = minisoc_spi_seq::type_id::create("spi_config_aes_seq");
    spi_seq.operation = minisoc_spi_seq::SPI_SEQ_CONFIG_AES;
    spi_seq.start(env.spi_agent.sqr);

    spi_seq = minisoc_spi_seq::type_id::create("spi_give_mem_seq");
    spi_seq.operation = minisoc_spi_seq::SPI_SEQ_GIVE_MEM;
    spi_seq.start(env.spi_agent.sqr);

    spi_seq = minisoc_spi_seq::type_id::create("spi_start_aes_seq");
    spi_seq.operation = minisoc_spi_seq::SPI_SEQ_START_AES;
    spi_seq.start(env.spi_agent.sqr);

    spi_seq = minisoc_spi_seq::type_id::create("spi_wait_done_seq");
    spi_seq.operation = minisoc_spi_seq::SPI_SEQ_WAIT_DONE;
    spi_seq.start(env.spi_agent.sqr);

    spi_seq = minisoc_spi_seq::type_id::create("spi_release_mem_seq");
    spi_seq.operation = minisoc_spi_seq::SPI_SEQ_RELEASE_MEM;
    spi_seq.start(env.spi_agent.sqr);

    repeat (5) @(posedge rst_vif.clk);

    mem_seq = minisoc_mem_seq::type_id::create("mem_read_seq");
    mem_seq.operation = minisoc_mem_seq::MEM_READ_WORDS;
    mem_seq.start(env.mem_agent.sqr);

    `uvm_info("SMOKE",
      "Cenario concluido; a verificacao do resultado sera reportada pelo scoreboard",
      UVM_NONE)

    phase.drop_objection(this);
  endtask : run_phase

endclass : minisoc_smoke_test