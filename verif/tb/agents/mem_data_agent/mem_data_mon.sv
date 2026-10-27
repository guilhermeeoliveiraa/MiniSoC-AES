class mem_data_mon extends uvm_monitor;
  `uvm_component_utils(mem_data_mon)

  virtual mem_data_if vif;

  uvm_analysis_port #(mem_data_item) ap;

  function new(string name = "mem_data_mon", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual mem_data_if)::get(this, "", "mem_vif", vif)) begin
      `uvm_fatal("MEM_MON_NO_VIF",
                 "Virtual interface mem_vif nao encontrada!")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    mem_data_item item;

    forever begin
      @(posedge vif.clk);

      if (!vif.rst_n || !vif.en)
        continue;

      item = mem_data_item::type_id::create("item", this);

      item.en    = vif.en;
      item.we    = vif.we;
      item.addr  = vif.addr;
      item.wdata = vif.wdata;
      item.rdata = '0;

      if (vif.we) begin
        `uvm_info(
          get_type_name(),
          $sformatf(
            "MEM WRITE: addr=0x%03h data=0x%08h",
            item.addr,
            item.wdata
          ),
          UVM_MEDIUM
        )

        ap.write(item);
      end
      else begin
        @(negedge vif.clk);

        item.rdata = vif.rdata;

        `uvm_info(
          get_type_name(),
          $sformatf(
            "MEM READ: addr=0x%03h data=0x%08h",
            item.addr,
            item.rdata
          ),
          UVM_MEDIUM
        )

        ap.write(item);
      end
    end
  endtask : run_phase

endclass : mem_data_mon