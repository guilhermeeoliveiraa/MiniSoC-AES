class clk_item extends uvm_sequence_item;

  rand bit              enable;
  rand longint unsigned period_ps;
  rand int unsigned     duty_cycle;
  realtime              freq_mhz;

  constraint c_default_clk {
    enable     == 1'b1;
    period_ps  == 500;
    duty_cycle == 50;
  }

  `uvm_object_utils_begin(clk_item)
    `uvm_field_int(enable, UVM_ALL_ON)
    `uvm_field_int(period_ps, UVM_ALL_ON)
    `uvm_field_int(duty_cycle, UVM_ALL_ON)
    `uvm_field_real(freq_mhz, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "clk_item");
    super.new(name);
  endfunction : new

endclass : clk_item