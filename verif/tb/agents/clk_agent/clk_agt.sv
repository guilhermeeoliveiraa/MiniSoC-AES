class clk_agt extends uvm_agent;
  `uvm_component_utils(clk_agt)

  clk_drv drv;
  clk_mon mon;
  clk_sqr sqr;

  virtual clk_if vif;

  uvm_analysis_port #(clk_item) item_collected_port;

  function new(string name = "clk_agt", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual clk_if)::get(this, "", "clk_vif", vif)) begin
      `uvm_fatal("CLK_AGT_NO_VIF", "Virtual Interface (clk_if) não encontrada no config_db")
    end

    mon = clk_mon::type_id::create("mon", this);

    if (get_is_active() == UVM_ACTIVE) begin
      drv = clk_drv::type_id::create("drv", this);
      sqr = clk_sqr::type_id::create("sqr", this);
    end
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    mon.vif = this.vif;

    if (get_is_active() == UVM_ACTIVE) begin
      drv.vif = this.vif;
      drv.seq_item_port.connect(sqr.seq_item_export);
    end

    item_collected_port = mon.item_collected_port;
  endfunction : connect_phase
endclass : clk_agt