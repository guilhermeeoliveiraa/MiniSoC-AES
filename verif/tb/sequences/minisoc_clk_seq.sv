class minisoc_clk_seq extends uvm_sequence #(clk_item);
  `uvm_object_utils(minisoc_clk_seq)

  function new(string name = "minisoc_clk_seq");
    super.new(name);
  endfunction : new

  task body();
    req = clk_item::type_id::create("req");
    start_item(req);

    if (!req.randomize()) begin
      `uvm_fatal("CLK_SEQ_RAND", "Falha ao aleatorizar clk_item")
    end

    finish_item(req);
  endtask : body

endclass : minisoc_clk_seq