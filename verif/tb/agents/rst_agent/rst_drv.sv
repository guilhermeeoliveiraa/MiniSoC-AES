class rst_drv extends uvm_driver #(rst_item);
  `uvm_component_utils(rst_drv)

  virtual rst_if vif;

  function new(string name = "rst_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rst_if)::get(this, "", "rst_vif", vif)) begin
      `uvm_fatal("RST_DRV_NO_VIF", "Virtual Interface 'rst_if' nao foi encontrada no uvm_config_db!")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    rst_item item;

    forever begin
      seq_item_port.get_next_item(item);
      drive_item(item);
      seq_item_port.item_done();
    end
  endtask : run_phase

  protected task drive_item(rst_item item);
    vif.rst_n <= item.rst_n;

    if (item.hold_cycles > 0) begin
      repeat (item.hold_cycles) @(posedge vif.clk);
    end
  endtask : drive_item

endclass : rst_drv