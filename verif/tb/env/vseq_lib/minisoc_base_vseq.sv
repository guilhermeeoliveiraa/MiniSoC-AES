class minisoc_base_vseq extends uvm_sequence;

  `uvm_object_utils(minisoc_base_vseq)
  `uvm_declare_p_sequencer(minisoc_vsqr)


  // Construtor
  function new(string name = "minisoc_base_vseq");

    super.new(name);

  endfunction : new

endclass : minisoc_base_vseq