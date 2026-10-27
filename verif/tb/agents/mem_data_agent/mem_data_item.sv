class mem_data_item extends uvm_sequence_item;

  rand bit          en;
  rand bit          we;
  rand logic [9:0]  addr;
  rand logic [31:0] wdata;
       logic [31:0] rdata;

  `uvm_object_utils_begin(mem_data_item)
    `uvm_field_int(en, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(wdata, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(rdata, UVM_ALL_ON | UVM_HEX)
  `uvm_object_utils_end

  constraint c_disabled_write {
    !en -> !we;
  }

  function new(string name = "mem_data_item");
    super.new(name);
  endfunction : new

endclass : mem_data_item