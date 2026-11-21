class rst_start_seq extends rst_base_seq;

  `uvm_object_utils(rst_start_seq)

  // Construtor
  function new(string name = "rst_start_seq");
    super.new(name);
  endfunction : new

  // Corpo da sequencia
  task body();

    rst_item item;

    item = rst_item::type_id::create("item");

    start_item(item);
    item.rst_n = 1'b0;
    finish_item(item);

  endtask : body

endclass : rst_start_seq