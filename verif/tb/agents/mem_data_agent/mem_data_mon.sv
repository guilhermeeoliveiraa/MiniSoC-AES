class mem_data_mon extends uvm_monitor;
  `uvm_component_utils(mem_data_mon)

  virtual mem_data_if vif;

  // Declarado como 'ap'
  uvm_analysis_port #(mem_data_item) ap;

  function new(string name = "mem_data_mon", uvm_component parent = null);
    super.new(name, parent);
    // Instanciado como 'ap'
    ap = new("ap", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (vif == null) begin
      if (!uvm_config_db#(virtual mem_data_if)::get(this, "", "mem_vif", vif)) begin
        `uvm_fatal("MEM_MON_NO_VIF", "Virtual interface 'mem_data_vif' nao encontrada no uvm_config_db!")
      end
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    mem_data_item item;

    forever begin
      @(posedge vif.clk);

      if (!vif.rst_n) begin
        continue;
      end

      if (vif.en) begin
        item = mem_data_item::type_id::create("item");
        item.we   = vif.we;
        item.addr = vif.addr;

        if (vif.we) begin
          item.wdata = vif.wdata;
          `uvm_info(get_type_name(), $sformatf("Mem Write: addr=0x%0h wdata=0x%0h", item.addr, item.wdata), UVM_HIGH)
          // Usando ap.write
          ap.write(item);
        end else begin
          @(posedge vif.clk);
          item.rdata = vif.rdata;
          `uvm_info(get_type_name(), $sformatf("Mem Read: addr=0x%0h rdata=0x%0h", item.addr, item.rdata), UVM_HIGH)
          // Usando ap.write
          ap.write(item);
        end
      end
    end
  endtask : run_phase

endclass : mem_data_mon