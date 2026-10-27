class clk_drv extends uvm_driver #(clk_item);
  `uvm_component_utils(clk_drv)

  virtual clk_if vif;

  function new(string name = "clk_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual clk_if)::get(this, "", "clk_vif", vif)) begin
      `uvm_fatal("CLK_DRV_NO_VIF", "Virtual Interface 'clk_if' nao foi encontrada no uvm_config_db!")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    clk_item item;

    forever begin
      seq_item_port.get_next_item(item);
      drive_item(item);
      seq_item_port.item_done();
    end
  endtask : run_phase

  local task drive_item(clk_item item);
    if (item.enable) begin
      // Converte picossegundos (ps) para nanossefundos (ns) na interface
      vif.period = item.period_ps / 1000.0;
    end
  endtask : drive_item

endclass : clk_drv