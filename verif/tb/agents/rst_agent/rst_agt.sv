
class rst_agt extends uvm_agent;

  `uvm_component_utils(rst_agt)

  // Interfaces virtuais utilizadas pelos componentes
  virtual rst_if.drv_mp drv_vif;
  virtual rst_if.mon_mp mon_vif;

  // Componentes do Agent
  rst_drv drv;
  rst_mon mon;
  rst_sqr sqr;

  // Porta de analise para publicar as transacoes observadas
  uvm_analysis_port #(rst_item) item_collected_port;


  // Construtor
  function new(string name = "rst_agt",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Constroi os componentes do Agent
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Recupera a interface virtual do Monitor
    if (!uvm_config_db#(virtual rst_if.mon_mp)::get(
          this, "", "rst_mon_vif", mon_vif
        )) begin

      `uvm_fatal("RST_AGT",
                 "Interface virtual rst_if.mon_mp nao configurada!")

    end

    // Cria a porta de analise do Agent
    item_collected_port = new("item_collected_port", this);

    // Cria o Monitor
    mon = rst_mon::type_id::create("mon", this);

    // Configura a interface virtual do Monitor
    uvm_config_db#(virtual rst_if.mon_mp)::set(
      this, "mon", "vif", mon_vif
    );

    // Cria os componentes do Agent ativo
    if (is_active == UVM_ACTIVE) begin

      // Recupera a interface virtual do Driver
      if (!uvm_config_db#(virtual rst_if.drv_mp)::get(
            this, "", "rst_drv_vif", drv_vif
          )) begin

        `uvm_fatal("RST_AGT",
                   "Interface virtual rst_if.drv_mp nao configurada!")

      end

      // Cria o Sequencer
      sqr = rst_sqr::type_id::create("sqr", this);

      // Cria o Driver
      drv = rst_drv::type_id::create("drv", this);

      // Configura a interface virtual de reset do Driver
      uvm_config_db#(virtual rst_if.drv_mp)::set(
        this, "drv", "rst_vif", drv_vif
      );

    end

  endfunction : build_phase


  // Conecta os componentes do Agent
  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    // Conecta a porta de analise do Monitor ao Agent
    mon.item_collected_port.connect(item_collected_port);

    // Conecta o Driver ao Sequencer
    if (is_active == UVM_ACTIVE) begin

      drv.seq_item_port.connect(sqr.seq_item_export);

    end

  endfunction : connect_phase

endclass : rst_agt
