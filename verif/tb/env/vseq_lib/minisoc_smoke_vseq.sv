class minisoc_smoke_vseq extends minisoc_base_vseq;

  `uvm_object_utils(minisoc_smoke_vseq)


  // Construtor
  function new(string name = "minisoc_smoke_vseq");

    super.new(name);

  endfunction : new


  // Executa o Smoke Test do MiniSoC
  task body();

    minisoc_clk_rst_vseq     clk_rst_seq;
    clk_start_seq            clk_seq;
    rst_toggle_seq           rst_seq;
    mem_data_write_seq       mem_write_seq;
    mem_data_write_block_seq mem_write_block_seq;
    mem_data_read_seq        mem_read_seq;
    mem_data_read_block_seq  read_block_seq;
    spi_write_reg_seq        reg_seq;
    spi_wait_reg_seq         wait_seq;
    spi_write_key_seq        key_seq;


    `uvm_info("SMOKE_VSEQ", "Iniciando Smoke Test do MiniSoC", UVM_LOW)


    // --------------------------------------------------
    // Inicializacao do clock e reset
    // --------------------------------------------------

    clk_rst_seq = minisoc_clk_rst_vseq::type_id::create("clk_rst_seq");

    // Executa a inicializacao do clock e reset
    clk_rst_seq.start(m_sequencer);

    // --------------------------------------------------
    // Escrita na memoria externa
    // --------------------------------------------------

    mem_write_block_seq = mem_data_write_block_seq::type_id::create("mem_write_block_seq");
    mem_write_block_seq.start_addr = 10'h000;
    mem_write_block_seq.block_data = 128'h00112233445566778899AABBCCDDEEFF;
    mem_write_block_seq.start(p_sequencer.mem_data_sqr);

    // --------------------------------------------------
    // Configuracao do AES via SPI
    // --------------------------------------------------

    // Configura a quantidade de blocos para processamento
    reg_seq = spi_write_reg_seq::type_id::create("reg_seq");
    reg_seq.addr = REG_NUM_BLOCKS;
    reg_seq.data = 32'h00000001;   // 1 bloco
    reg_seq.start(p_sequencer.spi_sqr);

    // Configura modo de operacao do AES
    reg_seq = spi_write_reg_seq::type_id::create("reg_seq");
    reg_seq.addr = REG_AES_CONTROL;
    reg_seq.data = 32'h00000000;   // MODE = ECB, DECRYPT = 0, START = 0
    reg_seq.start(p_sequencer.spi_sqr);

    // Define a chave de criptografia
    key_seq = spi_write_key_seq::type_id::create("key_seq");
    key_seq.key = 128'h000102030405060708090A0B0C0D0E0F;
    key_seq.start(p_sequencer.spi_sqr);

    // --------------------------------------------------
    // Inicialização do PLL
    // --------------------------------------------------

    // Habilita o PLL do MiniSoC
    reg_seq = spi_write_reg_seq::type_id::create("reg_seq");
    reg_seq.addr = REG_SYSTEM_CONTROL;
    reg_seq.data = 32'h00000002;  // MEM_SEL_AES = 0, PLL_ENABLE = 1
    reg_seq.start(p_sequencer.spi_sqr);

    // --------------------------------------------------
    // Transferência de ownership
    // --------------------------------------------------

    // Transfere o ownership da memoria para o AES
    reg_seq = spi_write_reg_seq::type_id::create("reg_seq");
    reg_seq.addr = REG_SYSTEM_CONTROL;
    reg_seq.data = 32'h00000003;  // MEM_SEL_AES = 1, PLL_ENABLE = 1
    reg_seq.start(p_sequencer.spi_sqr);

    // --------------------------------------------------
    // Executar AES
    // --------------------------------------------------

    // Inicia a operacao AES
    reg_seq.addr = REG_AES_CONTROL;
    reg_seq.data = 32'h00000001;  // START = 1
    reg_seq.start(p_sequencer.spi_sqr);

    // --------------------------------------------------
    // Aguardar término do AES
    // --------------------------------------------------

    wait_seq = spi_wait_reg_seq::type_id::create("wait_seq");
    // Registrador AES_STATUS
    wait_seq.addr = REG_AES_STATUS;
    // Configura a verificacao do bit DONE
    wait_seq.mask     = 32'h00000002;
    wait_seq.expected = 32'h00000002;
    // Executa a espera
    wait_seq.start(p_sequencer.spi_sqr);

    // --------------------------------------------------
    // Recuperação da memória externa
    // --------------------------------------------------

    // Devolve a propriedade da memoria ao controle externo
    reg_seq = spi_write_reg_seq::type_id::create("reg_seq");
    reg_seq.addr = REG_SYSTEM_CONTROL;
    reg_seq.data = 32'h00000002; // MEM_SEL_AES=0, PLL_ENABLE=1
    reg_seq.start(p_sequencer.spi_sqr);

    // --------------------------------------------------
    // Leitura da memoria externa
    // --------------------------------------------------

    // Cria a sequencia de leitura de bloco
    read_block_seq = mem_data_read_block_seq::type_id::create("read_block_seq");
    // Configura o endereco inicial do bloco
    read_block_seq.start_addr = 10'h000;
    // Executa a leitura do bloco no sequencer da memoria
    read_block_seq.start(p_sequencer.mem_data_sqr);

    `uvm_info("SMOKE_VSEQ", "Smoke Test finalizado", UVM_LOW)

  endtask : body

endclass : minisoc_smoke_vseq