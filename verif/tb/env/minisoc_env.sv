
class minisoc_env extends uvm_env;

  `uvm_component_utils(minisoc_env)


  // Configuracao do ambiente
  minisoc_env_config cfg;


  // Agents do ambiente
  clk_agt      clk_agent;
  rst_agt      rst_agent;
  spi_agt      spi_agent;
  mem_data_agt mem_agent;


  // Virtual Sequencer
  minisoc_vsqr virtual_sequencer;


  // Componentes de verificacao
  minisoc_scb scb;
  minisoc_sub sub;


  // Construtor
  function new(string name = "minisoc_env",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Cria e configura os componentes do ambiente
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);


    // Recupera a configuracao do ambiente
    if (!uvm_config_db#(minisoc_env_config)::get(
          this, "", "cfg", cfg
        )) begin

      cfg = minisoc_env_config::type_id::create("cfg");

    end


    // Cria o Virtual Sequencer
    virtual_sequencer = minisoc_vsqr::type_id::create(
      "virtual_sequencer", this
    );


    // Configura e cria o Agent de Clock
    if (cfg.has_clk_agent) begin

      uvm_config_db#(uvm_active_passive_enum)::set(
        this, "clk_agent", "is_active", cfg.clk_agt_mode
      );

      clk_agent = clk_agt::type_id::create(
        "clk_agent", this
      );

    end


    // Configura e cria o Agent de Reset
    if (cfg.has_rst_agent) begin

      uvm_config_db#(uvm_active_passive_enum)::set(
        this, "rst_agent", "is_active", cfg.rst_agt_mode
      );

      rst_agent = rst_agt::type_id::create(
        "rst_agent", this
      );

    end


    // Configura e cria o Agent SPI
    if (cfg.has_spi_agent) begin

      uvm_config_db#(uvm_active_passive_enum)::set(
        this, "spi_agent", "is_active", cfg.spi_agt_mode
      );

      spi_agent = spi_agt::type_id::create(
        "spi_agent", this
      );

    end


    // Configura e cria o Agent de Memoria
    if (cfg.has_mem_agent) begin

      uvm_config_db#(uvm_active_passive_enum)::set(
        this, "mem_agent", "is_active", cfg.mem_agt_mode
      );

      mem_agent = mem_data_agt::type_id::create(
        "mem_agent", this
      );

    end


    // Cria o Scoreboard
    if (cfg.has_scoreboard) begin

      scb = minisoc_scb::type_id::create(
        "scb", this
      );

    end


    // Cria o Subscriber
    if (cfg.has_subscriber) begin

      sub = minisoc_sub::type_id::create(
        "sub", this
      );

    end

  endfunction : build_phase


  // Conecta os componentes do ambiente
  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);


    // Conecta os sequencers dos agentes ao Virtual Sequencer
    virtual_sequencer.clk_sqr = clk_agent.sqr;
    virtual_sequencer.rst_sqr = rst_agent.sqr;


    // Conecta o sequencer SPI quando o Agent estiver ativo
    if (cfg.has_spi_agent &&
        cfg.spi_agt_mode == UVM_ACTIVE) begin

      virtual_sequencer.spi_sqr = spi_agent.sqr;

    end


    // Conecta o sequencer de memoria quando o Agent estiver ativo
    if (cfg.has_mem_agent &&
        cfg.mem_agt_mode == UVM_ACTIVE) begin

      virtual_sequencer.mem_data_sqr = mem_agent.sqr;

    end


    // Conecta os monitores ao Scoreboard
    if (cfg.has_scoreboard) begin

      if (cfg.has_mem_agent) begin

        mem_agent.mon.ap.connect(scb.mem_export);

      end

      if (cfg.has_spi_agent) begin

        spi_agent.mon.item_collected_port.connect(scb.spi_export);

      end

    end


    // Conecta os monitores ao Subscriber
    if (cfg.has_mem_agent) begin

      mem_agent.mon.ap.connect(sub.mem_export);

    end

    if (cfg.has_spi_agent) begin

      spi_agent.mon.item_collected_port.connect(sub.spi_export);

    end

  endfunction : connect_phase


endclass : minisoc_env
