class minisoc_base_seq extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(minisoc_base_seq)

  function new(string name = "minisoc_base_seq");
    super.new(name);
  endfunction : new

  task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this, get_type_name());
    end
  endtask : pre_body

  task post_body();
    if (starting_phase != null) begin
      starting_phase.drop_objection(this, get_type_name());
    end
  endtask : post_body

endclass : minisoc_base_seq