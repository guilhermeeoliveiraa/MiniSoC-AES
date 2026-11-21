class mem_data_item extends uvm_sequence_item;

  // Sinais de controle da memória
  rand bit en;
  rand bit we;

  // Endereço e dados da memória
  rand logic [9:0]  addr;
  rand logic [31:0] wdata;

  // Dado recebido durante uma leitura
       logic [31:0] rdata;


  `uvm_object_utils_begin(mem_data_item)

    `uvm_field_int(en, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(wdata, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(rdata, UVM_ALL_ON | UVM_HEX)

  `uvm_object_utils_end


  // Impede uma operação de escrita quando a memória está desabilitada
  constraint c_disabled_write {
    !en -> !we;
  }


  // Construtor
  function new(string name = "mem_data_item");

    super.new(name);

  endfunction : new

endclass : mem_data_item
