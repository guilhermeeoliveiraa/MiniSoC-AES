class spi_agt extends uvm_agent;

  `uvm_component_utils(spi_agt)

  // Interfaces virtuais utilizadas pelos componentes
  virtual spi_if.drv_mp drv_vif;
  virtual spi_if.mon_mp mon_vif;

  // Componentes do Agent
  spi_sqr sqr;
  spi_drv drv;
  spi_mon mon;

  // Define se o Agent será ativo ou passivo
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  // Porta de análise para disponibilizar as transações observadas
  uvm_analysis_port #(spi_item) ap;


  // Construtor
  function new(string name = "spi_agt",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Cria os componentes do Agent
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Recupera a interface virtual do Monitor
    if (!uvm_config_db#(virtual spi_if.mon_mp)::get(
          this, "", "spi_mon_vif", mon_vif
        )) begin

      `uvm_fatal("SPI_AGT",
                 "Interface virtual do Monitor nao configurada!")

    end

    // Cria a porta de análise
    ap = new("ap", this);

    // Cria o Monitor
    mon = spi_mon::type_id::create("mon", this);

    // Configura a interface virtual do Monitor
    uvm_config_db#(virtual spi_if.mon_mp)::set(
      this, "mon", "vif", mon_vif
    );

    if (get_is_active() == UVM_ACTIVE) begin

      // Recupera a interface virtual do Driver
      if (!uvm_config_db#(virtual spi_if.drv_mp)::get(
            this, "", "spi_drv_vif", drv_vif
          )) begin

        `uvm_fatal("SPI_AGT",
                   "Interface virtual do Driver nao configurada!")

      end

      // Cria o Sequencer
      sqr = spi_sqr::type_id::create("sqr", this);

      // Cria o Driver
      drv = spi_drv::type_id::create("drv", this);

      // Configura a interface virtual do Driver
      uvm_config_db#(virtual spi_if.drv_mp)::set(
        this, "drv", "vif", drv_vif
      );

    end

  endfunction : build_phase


  // Conecta os componentes do Agent
  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    // Conecta a porta de análise do Monitor ao Agent
    mon.item_collected_port.connect(ap);

    if (get_is_active() == UVM_ACTIVE) begin

      // Conecta o Driver ao Sequencer
      drv.seq_item_port.connect(sqr.seq_item_export);

    end

  endfunction : connect_phase

endclass : spi_agt
