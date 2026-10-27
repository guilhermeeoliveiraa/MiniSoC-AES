class minisoc_rst_seq extends uvm_sequence #(rst_item);
  `uvm_object_utils(minisoc_rst_seq)

  rand int unsigned reset_cycles;

  constraint c_reset_cycles {
    reset_cycles inside {[2:10]};
  }

  function new(string name = "minisoc_rst_seq");
    super.new(name);
  endfunction

  task body();
    rst_item req;

    if (!this.randomize())
      `uvm_fatal("RST_SEQ_RAND", "Falha ao aleatorizar a duracao do reset")

    req = rst_item::type_id::create("req");

    start_item(req);
    if (!req.randomize() with {
      rst_n == 1'b0;
      hold_cycles == local::reset_cycles;
    })
      `uvm_fatal("RST_ASSERT_RAND", "Falha ao aleatorizar a assercao do reset")
    finish_item(req);

    start_item(req);
    if (!req.randomize() with {
      rst_n == 1'b1;
      hold_cycles == 2;
    })
      `uvm_fatal("RST_RELEASE_RAND", "Falha ao aleatorizar a liberacao do reset")
    finish_item(req);
  endtask
endclass