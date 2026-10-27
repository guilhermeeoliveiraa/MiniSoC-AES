class spi_agt extends uvm_agent;
  `uvm_component_utils(spi_agt)

  spi_sqr sqr;
  spi_drv drv;
  spi_mon mon;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(string name = "spi_agt", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = spi_mon::type_id::create("mon", this);

    if (is_active == UVM_ACTIVE) begin
      sqr = spi_sqr::type_id::create("sqr", this);
      drv = spi_drv::type_id::create("drv", this);
    end
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
  endfunction : connect_phase

endclass : spi_agt