
class mem_data_agt extends uvm_agent;

  `uvm_component_utils(mem_data_agt)

  // Interfaces virtuais utilizadas pelos componentes
  virtual mem_data_if.drv_mp drv_vif;
  virtual mem_data_if.mon_mp mon_vif;

  // Componentes do Agent
  mem_data_drv drv;
  mem_data_mon mon;
  mem_data_sqr sqr;

  // Porta de análise para disponibilizar as transações observadas
  uvm_analysis_port #(mem_data_item) ap;


  // Construtor
  function new(string name = "mem_data_agt",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Cria os componentes e recupera as interfaces virtuais
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Recupera a interface virtual do Monitor
    if (!uvm_config_db#(virtual mem_data_if.mon_mp)::get(
          this, "", "mem_data_mon_vif", mon_vif
        )) begin

      `uvm_fatal("MEM_DATA_AGT",
                 "Interface virtual do Monitor nao configurada!")

    end

    // Cria a porta de análise
    ap = new("ap", this);

    // Cria o Monitor
    mon = mem_data_mon::type_id::create("mon", this);

    // Configura a interface virtual do Monitor
    uvm_config_db#(virtual mem_data_if.mon_mp)::set(
      this, "mon", "vif", mon_vif
    );

    // Cria os componentes ativos
    if (get_is_active() == UVM_ACTIVE) begin

      // Recupera a interface virtual do Driver
      if (!uvm_config_db#(virtual mem_data_if.drv_mp)::get(
            this, "", "mem_data_drv_vif", drv_vif
          )) begin

        `uvm_fatal("MEM_DATA_AGT",
                   "Interface virtual do Driver nao configurada!")

      end

      // Cria o Driver
      drv = mem_data_drv::type_id::create("drv", this);

      // Cria o Sequencer
      sqr = mem_data_sqr::type_id::create("sqr", this);

      // Configura a interface virtual do Driver
      uvm_config_db#(virtual mem_data_if.drv_mp)::set(
        this, "drv", "vif", drv_vif
      );

    end

  endfunction : build_phase


  // Conecta os componentes do Agent
  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    // Conecta a porta de análise do Monitor ao Agent
    mon.ap.connect(ap);

    // Conecta o Driver ao Sequencer
    if (get_is_active() == UVM_ACTIVE) begin

      drv.seq_item_port.connect(sqr.seq_item_export);

    end

  endfunction : connect_phase

endclass : mem_data_agt
