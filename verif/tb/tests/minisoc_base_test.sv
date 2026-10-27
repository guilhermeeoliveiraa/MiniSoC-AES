class minisoc_base_test extends uvm_test;
  `uvm_component_utils(minisoc_base_test)

  minisoc_env        env;
  minisoc_env_config cfg;

  function new(string name = "minisoc_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    cfg = minisoc_env_config::type_id::create("cfg");
    configure_env(cfg);

    uvm_config_db#(minisoc_env_config)::set(this, "env", "cfg", cfg);

    env = minisoc_env::type_id::create("env", this);
  endfunction : build_phase

  virtual function void configure_env(minisoc_env_config cfg);
    cfg.has_spi_agent  = 1'b1;
    cfg.has_mem_agent  = 1'b1;
    cfg.has_scoreboard = 1'b1;
  endfunction : configure_env

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("BASE_TEST", $sformatf("Starting execution of test: %s", get_type_name()), UVM_LOW)
  endfunction : start_of_simulation_phase

endclass : minisoc_base_test