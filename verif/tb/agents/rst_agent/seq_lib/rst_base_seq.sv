class rst_base_seq extends uvm_sequence #(rst_item);

  `uvm_object_utils(rst_base_seq)


  // Construtor
  function new(string name = "rst_base_seq");

    super.new(name);

  endfunction : new

endclass : rst_base_seq