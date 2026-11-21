
class minisoc_env_config extends uvm_object;

  `uvm_object_utils(minisoc_env_config)


  // Controle de instanciacao dos Agents
  bit has_spi_agent  = 1'b1;
  bit has_mem_agent  = 1'b1;
  bit has_clk_agent  = 1'b1;
  bit has_rst_agent  = 1'b1;


  // Controle dos componentes de verificacao
  bit has_scoreboard = 1'b1;
  bit has_subscriber = 1'b1;


  // Configuracao dos Agents
  uvm_active_passive_enum spi_agt_mode = UVM_ACTIVE;
  uvm_active_passive_enum mem_agt_mode = UVM_ACTIVE;
  uvm_active_passive_enum clk_agt_mode = UVM_ACTIVE;
  uvm_active_passive_enum rst_agt_mode = UVM_ACTIVE;


  // Construtor
  function new(string name = "minisoc_env_config");

    super.new(name);

  endfunction : new


endclass : minisoc_env_config
