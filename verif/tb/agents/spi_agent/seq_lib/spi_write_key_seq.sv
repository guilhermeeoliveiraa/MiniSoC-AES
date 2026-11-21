
class spi_write_key_seq extends spi_base_seq;

  `uvm_object_utils(spi_write_key_seq)

  // Chave AES de 128 bits
  rand logic [127:0] key;


  // Construtor
  function new(string name = "spi_write_key_seq");

    super.new(name);

  endfunction : new


  // Executa a sequencia de escrita da chave AES
  task body();

    spi_write_reg_seq write_seq;

    // Escreve os 32 bits mais significativos em KEY0
    write_seq = spi_write_reg_seq::type_id::create("write_key0_seq");
    write_seq.addr = 6'h00;
    write_seq.data = key[127:96];
    write_seq.start(m_sequencer);

    // Escreve os proximos 32 bits em KEY1
    write_seq = spi_write_reg_seq::type_id::create("write_key1_seq");
    write_seq.addr = 6'h01;
    write_seq.data = key[95:64];
    write_seq.start(m_sequencer);

    // Escreve os proximos 32 bits em KEY2
    write_seq = spi_write_reg_seq::type_id::create("write_key2_seq");
    write_seq.addr = 6'h02;
    write_seq.data = key[63:32];
    write_seq.start(m_sequencer);

    // Escreve os 32 bits menos significativos em KEY3
    write_seq = spi_write_reg_seq::type_id::create("write_key3_seq");
    write_seq.addr = 6'h03;
    write_seq.data = key[31:0];
    write_seq.start(m_sequencer);

  endtask : body

endclass : spi_write_key_seq
