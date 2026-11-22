class mem_data_write_block_seq extends mem_data_base_seq;

  `uvm_object_utils(mem_data_write_block_seq)


  // Endereco inicial da memoria que sera escrito
  rand logic [9:0] start_addr;

  // Bloco de 128 bits que sera escrito na memoria
  rand logic [127:0] block_data;


  // Construtor
  function new(string name = "mem_data_write_block_seq");

    super.new(name);

  endfunction : new


  // Executa a sequencia de escrita do bloco na memoria
  task body();

    mem_data_write_seq write_seq;

    // Cria a sequencia de escrita
    write_seq = mem_data_write_seq::type_id::create("write_seq");

    // Escreve a primeira palavra do bloco
    write_seq.addr = start_addr;
    write_seq.data = block_data[127:96];
    write_seq.start(p_sequencer);

    // Escreve a segunda palavra do bloco
    write_seq.addr = start_addr + 1;
    write_seq.data = block_data[95:64];
    write_seq.start(p_sequencer);

    // Escreve a terceira palavra do bloco
    write_seq.addr = start_addr + 2;
    write_seq.data = block_data[63:32];
    write_seq.start(p_sequencer);

    // Escreve a quarta palavra do bloco
    write_seq.addr = start_addr + 3;
    write_seq.data = block_data[31:0];
    write_seq.start(p_sequencer);

  endtask : body

endclass : mem_data_write_block_seq