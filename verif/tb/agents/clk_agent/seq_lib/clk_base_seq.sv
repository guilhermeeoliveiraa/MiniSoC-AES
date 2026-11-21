class clk_base_seq extends uvm_sequence #(clk_item);

  `uvm_object_utils(clk_base_seq)


  // Periodo do clock em picosegundos
  rand int unsigned period_ps;


  // Construtor
  function new(string name = "clk_base_seq");

    super.new(name);

  endfunction : new

endclass : clk_base_seq