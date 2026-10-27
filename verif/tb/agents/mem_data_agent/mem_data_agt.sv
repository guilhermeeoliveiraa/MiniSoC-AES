class mem_data_agt extends uvm_agent;
  `uvm_component_utils(mem_data_agt)
  
  virtual mem_data_if vif;

  mem_data_drv drv;
  mem_data_mon mon;
  mem_data_sqr sqr;
  
  uvm_analysis_port #(mem_data_item) ap;
  
  function new(string name = "mem_data_agt", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual mem_data_if)::get(this, "", "mem_vif", vif)) begin
      `uvm_fatal("MEM_DATA_AGT_NO_VIF", "Virtual Interface (mem_data_if) not found in config_db")
    end
    
    ap = new("ap", this);
    mon = mem_data_mon::type_id::create("mon", this);
    
    if (get_is_active() == UVM_ACTIVE) begin
      drv = mem_data_drv::type_id::create("drv", this);
      sqr = mem_data_sqr::type_id::create("sqr", this);
    end
    
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    mon.vif = this.vif;
    
    if (get_is_active() == UVM_ACTIVE) begin
      drv.vif = this.vif;
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
    
    mon.ap.connect(this.ap); 
    
  endfunction : connect_phase
  
endclass : mem_data_agt