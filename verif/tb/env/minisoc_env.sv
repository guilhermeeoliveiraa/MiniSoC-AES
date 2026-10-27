class minisoc_env extends uvm_env;
  `uvm_component_utils(minisoc_env)

  minisoc_env_config cfg;

  clk_agt clk_agent;
  rst_agt rst_agent;
  spi_agt spi_agent;
  mem_data_agt mem_agent;
  minisoc_scb scb;

  function new(string name = "minisoc_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(minisoc_env_config)::get(this, "", "cfg", cfg))
      cfg = minisoc_env_config::type_id::create("cfg");

    clk_agent = clk_agt::type_id::create("clk_agent", this);
    rst_agent = rst_agt::type_id::create("rst_agent", this);

    if (cfg.has_spi_agent)
      spi_agent = spi_agt::type_id::create("spi_agent", this);

    if (cfg.has_mem_agent)
      mem_agent = mem_data_agt::type_id::create("mem_agent", this);

    if (cfg.has_scoreboard)
      scb = minisoc_scb::type_id::create("scb", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (cfg.has_scoreboard) begin
      if (cfg.has_mem_agent)
        mem_agent.mon.ap.connect(scb.mem_export);

      if (cfg.has_spi_agent)
        spi_agent.mon.item_collected_port.connect(scb.spi_export);
    end
  endfunction : connect_phase

endclass : minisoc_env