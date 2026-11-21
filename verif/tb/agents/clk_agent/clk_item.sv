
class clk_item extends uvm_sequence_item;

  // Controle de habilitacao do clock
  rand bit enable;

  // Periodo do clock em picossegundos
  rand longint unsigned period_ps;


  // Registro dos campos para automacao UVM
  `uvm_object_utils_begin(clk_item)

    `uvm_field_int(enable, UVM_ALL_ON)
    `uvm_field_int(period_ps, UVM_ALL_ON)

  `uvm_object_utils_end


  // Restricoes dos parametros do clock
  constraint c_default_clk {
    soft enable    == 1'b1;
    soft period_ps == 500;
    period_ps > 0;
  }


  // Construtor
  function new(string name = "clk_item");

    super.new(name);

  endfunction : new

endclass : clk_item
