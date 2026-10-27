class minisoc_env_config extends uvm_object;
  `uvm_object_utils(minisoc_env_config)

  bit has_spi_agent  = 1'b1;
  bit has_mem_agent  = 1'b1;
  bit has_scoreboard = 1'b1;

  uvm_active_passive_enum spi_agt_mode = UVM_ACTIVE;
  uvm_active_passive_enum mem_agt_mode = UVM_ACTIVE;

  function new(string name = "minisoc_env_config");
    super.new(name);
  endfunction : new
endclass : minisoc_env_config