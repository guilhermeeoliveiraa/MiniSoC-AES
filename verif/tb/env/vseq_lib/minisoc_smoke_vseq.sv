class minisoc_smoke_vseq extends minisoc_base_vseq;

  `uvm_object_utils(minisoc_smoke_vseq)


  // Construtor
  function new(string name = "minisoc_smoke_vseq");

    super.new(name);

  endfunction : new


  // Executa o Smoke Test do MiniSoC
  task body();

    minisoc_clk_rst_vseq clk_rst_seq;
    clk_start_seq        clk_seq;
    rst_toggle_seq        rst_seq;
    mem_data_write_seq   mem_write_seq;
    mem_data_read_seq    mem_read_seq;
    spi_read_reg_seq     spi_read_seq;


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

    mem_write_seq = mem_data_write_seq::type_id::create("mem_write_seq");

    // Configura endereco e dado
    mem_write_seq.addr = 10'h000;
    mem_write_seq.data = 32'h12345678;

    // Executa a escrita
    mem_write_seq.start(p_sequencer.mem_data_sqr);


    // --------------------------------------------------
    // Leitura da memoria externa
    // --------------------------------------------------

    mem_read_seq = mem_data_read_seq::type_id::create("mem_read_seq");

    // Configura endereco de leitura
    mem_read_seq.addr = 10'h000;

    // Executa a leitura
    mem_read_seq.start(p_sequencer.mem_data_sqr);


    // --------------------------------------------------
    // Leitura de registrador via SPI
    // --------------------------------------------------

    spi_read_seq = spi_read_reg_seq::type_id::create("spi_read_seq");

    // Seleciona o registrador VERSION (0x0D)
    spi_read_seq.addr = 6'h0D;

    // Executa a leitura SPI
    spi_read_seq.start(p_sequencer.spi_sqr);


    `uvm_info("SMOKE_VSEQ", "Smoke Test finalizado", UVM_LOW)

  endtask : body

endclass : minisoc_smoke_vseq