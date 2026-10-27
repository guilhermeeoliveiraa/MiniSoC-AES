class rst_agt extends uvm_agent;
  `uvm_component_utils(rst_agt)
  
  rst_drv drv;
  rst_mon mon;
  rst_sqr sqr;
  
  virtual rst_if vif;
  
  uvm_analysis_port #(rst_item) item_collected_port;
  
  function new(string name = "rst_agt", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual rst_if)::get(this, "", "rst_vif", vif)) begin
      `uvm_fatal("RST_AGT_NO_VIF", "Virtual Interface (rst_if) not found in config_db")
    end
    
    mon = rst_mon::type_id::create("mon", this);
    
    if (get_is_active() == UVM_ACTIVE) begin
      drv = rst_drv::type_id::create("drv", this);
      sqr = rst_sqr::type_id::create("sqr", this);
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
  
endclass : rst_agt  