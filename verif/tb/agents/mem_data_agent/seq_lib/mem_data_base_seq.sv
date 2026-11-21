
class mem_data_base_seq extends uvm_sequence #(mem_data_item);

  `uvm_object_utils(mem_data_base_seq)


  // Construtor
  function new(string name = "mem_data_base_seq");

    super.new(name);

  endfunction : new

endclass : mem_data_base_seq
