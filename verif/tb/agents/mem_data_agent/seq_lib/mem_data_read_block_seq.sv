class mem_data_read_block_seq extends mem_data_base_seq;

  `uvm_object_utils(mem_data_read_block_seq)

  // Endereco inicial do bloco na memoria
  rand logic [9:0] start_addr;

  // Bloco de 128 bits lido da memoria
  logic [127:0] block_data;


  // Construtor
  function new(string name = "mem_data_read_block_seq");

    super.new(name);

  endfunction : new


  // Executa a leitura de um bloco de 128 bits
  task body();

    mem_data_read_seq read_seq;

    logic [31:0] words[4];

    // Le quatro palavras consecutivas da memoria
    for (int i = 0; i < 4; i++) begin

      // Cria a sequencia de leitura
      read_seq = mem_data_read_seq::type_id::create(
        $sformatf("read_seq_%0d", i)
      );

      // Configura o endereco da leitura
      read_seq.addr = start_addr + i;

      // Executa a sequencia no sequencer da memoria
      read_seq.start(m_sequencer);

      // Armazena a palavra recebida
      words[i] = read_seq.rdata;

    end

    // Combina as quatro palavras em um bloco de 128 bits
    block_data = {
      words[0],
      words[1],
      words[2],
      words[3]
    };

  endtask : body

endclass : mem_data_read_block_seq