
class minisoc_aes_operation_vseq extends minisoc_base_vseq;

  `uvm_object_utils(minisoc_aes_operation_vseq)

  // --------------------------------------------------
  // Parametros da operacao AES
  // --------------------------------------------------

  bit [127:0] key;
  bit [127:0] iv;
  bit [127:0] block_data;
  bit [9:0] start_addr;
  bit [2:0] mode;
  bit       decrypt;
  bit [31:0] pll_div;

  // --------------------------------------------------
  // Construtor
  // --------------------------------------------------

  function new(string name = "minisoc_aes_operation_vseq");
    super.new(name);
  endfunction : new


  // --------------------------------------------------
  // Escrita generica de registrador via SPI
  // --------------------------------------------------

  task write_spi_reg(
    input bit [REG_ADDR_WIDTH-1:0] addr,
    input bit [REG_DATA_WIDTH-1:0] data
  );

    spi_write_reg_seq reg_seq;

    reg_seq = spi_write_reg_seq::type_id::create("reg_seq");

    reg_seq.addr = addr;
    reg_seq.data = data;

    reg_seq.start(p_sequencer.spi_sqr);

  endtask : write_spi_reg


  // --------------------------------------------------
  // Escrita do vetor IV
  // --------------------------------------------------

  task write_iv();

    write_spi_reg(REG_IV0, iv[127:96]);
    write_spi_reg(REG_IV1, iv[95:64]);
    write_spi_reg(REG_IV2, iv[63:32]);
    write_spi_reg(REG_IV3, iv[31:0]);

  endtask : write_iv


  // --------------------------------------------------
  // Fluxo completo da operacao AES
  // --------------------------------------------------

  task body();

    minisoc_clk_rst_vseq     clk_rst_seq;
    mem_data_write_block_seq mem_write_seq;
    mem_data_read_block_seq  mem_read_seq;
    spi_write_key_seq        key_seq;
    spi_wait_reg_seq         wait_seq;

    bit [31:0] aes_control;

    `uvm_info("AES_OPERATION",
              "Iniciando operacao completa do AES",
              UVM_LOW)


    // ------------------------------------------------
    // 1. Inicializacao de clock e reset
    // ------------------------------------------------

    clk_rst_seq =
      minisoc_clk_rst_vseq::type_id::create("clk_rst_seq");

    clk_rst_seq.start(m_sequencer);


    // ------------------------------------------------
    // 2. Preparacao da memoria externa
    // ------------------------------------------------

    mem_write_seq =
      mem_data_write_block_seq::type_id::create("mem_write_seq");

    mem_write_seq.start_addr = start_addr;
    mem_write_seq.block_data = block_data;

    mem_write_seq.start(p_sequencer.mem_data_sqr);


    // ------------------------------------------------
    // 3. Habilitacao e estabilizacao da PLL
    // ------------------------------------------------

    write_spi_reg(
      REG_SYSTEM_CONTROL,
      MEM_SEL_EXT | PLL_ENABLE | pll_div
    );

    wait_seq =
      spi_wait_reg_seq::type_id::create("wait_pll_locked_seq");

    wait_seq.addr     = REG_SYSTEM_STATUS;
    wait_seq.mask     = PLL_LOCKED_MASK;
    wait_seq.expected = PLL_LOCKED;

    wait_seq.start(p_sequencer.spi_sqr);


    // ------------------------------------------------
    // 4. Configuracao dos registradores do AES
    // ------------------------------------------------

    // Quantidade de blocos
    write_spi_reg(REG_NUM_BLOCKS, NUM_BLOCKS_MIN);

    // Chave AES
    key_seq =
      spi_write_key_seq::type_id::create("key_seq");

    key_seq.key = key;

    key_seq.start(p_sequencer.spi_sqr);

    // Vetor de inicializacao
    write_iv();

    // Modo e direcao de operacao
    aes_control =
      (mode << AES_MODE_OFFSET) |
      (decrypt ? AES_DECRYPT : AES_ENCRYPT);

    write_spi_reg(REG_AES_CONTROL, aes_control);


    // ------------------------------------------------
    // 5. Transferencia de ownership da memoria
    // ------------------------------------------------

    write_spi_reg(
      REG_SYSTEM_CONTROL,
      MEM_SEL_AES | PLL_ENABLE | pll_div
    );


    // ------------------------------------------------
    // 6. Inicio do processamento AES
    // ------------------------------------------------

    write_spi_reg(
      REG_AES_CONTROL,
      aes_control | AES_START_CMD
    );


    // ------------------------------------------------
    // 7. Aguardar conclusao do processamento
    // ------------------------------------------------

    wait_seq =
      spi_wait_reg_seq::type_id::create("wait_aes_done_seq");

    wait_seq.addr     = REG_AES_STATUS;
    wait_seq.mask     = AES_DONE_MASK;
    wait_seq.expected = AES_DONE_SET;

    wait_seq.start(p_sequencer.spi_sqr);


    // ------------------------------------------------
    // 8. Devolver ownership da memoria
    // ------------------------------------------------

    write_spi_reg(
      REG_SYSTEM_CONTROL,
      MEM_SEL_EXT | PLL_ENABLE | pll_div
    );


    // ------------------------------------------------
    // 9. Leitura do resultado
    // ------------------------------------------------

    mem_read_seq =
      mem_data_read_block_seq::type_id::create("mem_read_seq");

    mem_read_seq.start_addr = start_addr;

    mem_read_seq.start(p_sequencer.mem_data_sqr);


    `uvm_info("AES_OPERATION",
              "Operacao completa do AES finalizada",
              UVM_LOW)

  endtask : body

endclass : minisoc_aes_operation_vseq
