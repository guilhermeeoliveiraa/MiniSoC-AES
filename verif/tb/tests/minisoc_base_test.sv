
class minisoc_base_test extends uvm_test;

  `uvm_component_utils(minisoc_base_test)


  // Configuracao do ambiente
  minisoc_env_config cfg;

  // Ambiente de verificacao
  minisoc_env env;


  // Construtor
  function new(string name = "minisoc_base_test",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Cria e configura o ambiente de verificacao
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);


    // Cria a configuracao do ambiente
    cfg = minisoc_env_config::type_id::create("cfg");

    // Configura a habilitacao dos agentes
    cfg.has_clk_agent = 1'b1;
    cfg.has_rst_agent = 1'b1;
    cfg.has_spi_agent = 1'b1;
    cfg.has_mem_agent = 1'b1;

    // Configura o modo de operacao dos agentes
    cfg.clk_agt_mode = UVM_ACTIVE;
    cfg.rst_agt_mode = UVM_ACTIVE;
    cfg.spi_agt_mode = UVM_ACTIVE;
    cfg.mem_agt_mode = UVM_ACTIVE;

    // Habilita o Scoreboard
    cfg.has_scoreboard = 1'b1;

    // Disponibiliza a configuracao para o ambiente
    uvm_config_db#(minisoc_env_config)::set(
      this, "env", "cfg", cfg
    );


    // Cria o ambiente
    env = minisoc_env::type_id::create("env", this);

  endfunction : build_phase


endclass : minisoc_base_test
