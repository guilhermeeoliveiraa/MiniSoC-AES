class rst_item extends uvm_sequence_item;

  // Estado de habilitacao do reset
  rand bit rst_n;


  // Registro dos campos para automacao UVM
  `uvm_object_utils_begin(rst_item)

    `uvm_field_int(rst_n, UVM_ALL_ON)

  `uvm_object_utils_end


  // Construtor
  function new(string name = "rst_item");

    super.new(name);

  endfunction : new

endclass : rst_item