class rst_mon extends uvm_monitor;
  `uvm_component_utils(rst_mon)

  virtual rst_if vif;
  uvm_analysis_port #(rst_item) item_collected_port;

  function new(string name = "rst_mon", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (vif == null) begin
      if (!uvm_config_db#(virtual rst_if)::get(this, "", "rst_vif", vif)) begin
        `uvm_fatal("RST_MON_NO_VIF", "Virtual interface 'rst_vif' nao encontrada no uvm_config_db!")
      end
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    rst_item item;
    realtime t_start, t_end;

    forever begin
      @(negedge vif.rst_n);
      t_start = $realtime;

      @(posedge vif.rst_n);
      t_end = $realtime;

      item = rst_item::type_id::create("item");
      item.rst_n = 1'b1;
      item.reset_duration_ns = (t_end - t_start) / 1ns;

      `uvm_info(get_type_name(),
        $sformatf("Reset assertado por %0t", t_end - t_start),
        UVM_LOW)

      item_collected_port.write(item);
    end
  endtask : run_phase

endclass : rst_mon