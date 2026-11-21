
class rst_item extends uvm_sequence_item;

  // Estado de habilitacao do reset
  rand bit rst_n;

  // Quantidade de ciclos para manter o estado do reset
  rand int unsigned hold_cycles;


  // Registro dos campos para automacao UVM
  `uvm_object_utils_begin(rst_item)

    `uvm_field_int(rst_n, UVM_ALL_ON)
    `uvm_field_int(hold_cycles, UVM_ALL_ON)

  `uvm_object_utils_end


  // Restricoes dos parametros do reset
  constraint c_default_rst {
    hold_cycles inside {[2:10]};
  }


  // Construtor
  function new(string name = "rst_item");

    super.new(name);

  endfunction : new

endclass : rst_item
