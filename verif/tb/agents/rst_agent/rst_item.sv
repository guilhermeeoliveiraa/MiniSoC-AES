class rst_item extends uvm_sequence_item;

  rand logic rst_n;
  rand int unsigned reset_duration_ns;
  rand int unsigned hold_cycles;

  constraint c_default_rst {
    reset_duration_ns inside {[20:100]};
    hold_cycles inside {[2:10]};
  }

  `uvm_object_utils_begin(rst_item)
    `uvm_field_int(rst_n, UVM_ALL_ON)
    `uvm_field_int(reset_duration_ns, UVM_ALL_ON)
    `uvm_field_int(hold_cycles, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "rst_item");
    super.new(name);
  endfunction : new

endclass : rst_item