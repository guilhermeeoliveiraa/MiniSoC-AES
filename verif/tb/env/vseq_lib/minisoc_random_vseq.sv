
class minisoc_random_vseq extends minisoc_base_vseq;

  `uvm_object_utils(minisoc_random_vseq)

  // --------------------------------------------------
  // Quantidade de operacoes aleatorias
  // --------------------------------------------------

  int unsigned num_operations = 50;

  // --------------------------------------------------
  // Parametros aleatorios
  // --------------------------------------------------

  rand bit [127:0] key;
  rand bit [127:0] iv;
  rand bit [127:0] block_data;
  rand bit [2:0] mode;
  rand bit       decrypt;

  // Somente modos suportados pelo MiniSoC-AES
  constraint valid_mode_c {
    mode inside {
      AES_MODE_ECB,
      AES_MODE_CBC,
      AES_MODE_PCBC,
      AES_MODE_CFB,
      AES_MODE_OFB,
      AES_MODE_CTR
    };
  }

  // --------------------------------------------------
  // Construtor
  // --------------------------------------------------

  function new(string name = "minisoc_random_vseq");
    super.new(name);
  endfunction : new


  // --------------------------------------------------
  // Execucao dos testes aleatorios
  // --------------------------------------------------

  task body();

    minisoc_aes_operation_vseq operation_seq;

    `uvm_info("RANDOM_VSEQ",
              "Iniciando testes aleatorios do MiniSoC-AES",
              UVM_LOW)

    for (int unsigned i = 0; i < num_operations; i++) begin

      // ----------------------------------------------
      // Geracao dos parametros aleatorios
      // ----------------------------------------------

      if (!this.randomize()) begin
        `uvm_fatal("RANDOM_VSEQ",
                   "Falha ao gerar parametros aleatorios")
      end

      `uvm_info("RANDOM_VSEQ",
                $sformatf(
                  "Operacao %0d/%0d | MODE=%0d | DECRYPT=%0b",
                  i + 1,
                  num_operations,
                  mode,
                  decrypt
                ),
                UVM_MEDIUM)


      // ----------------------------------------------
      // Criacao da sequencia de operacao
      // ----------------------------------------------

      operation_seq =
        minisoc_aes_operation_vseq::type_id::create(
          $sformatf("operation_seq_%0d", i)
        );


      // ----------------------------------------------
      // Configuracao dos parametros
      // ----------------------------------------------

      operation_seq.key        = key;
      operation_seq.iv         = iv;
      operation_seq.block_data = block_data;

      operation_seq.start_addr = 10'h000;

      operation_seq.mode       = mode;
      operation_seq.decrypt    = decrypt;

      operation_seq.pll_div    = PLL_DIV_1;


      // ----------------------------------------------
      // Execucao da operacao completa
      // ----------------------------------------------

      operation_seq.start(m_sequencer);

    end

    `uvm_info("RANDOM_VSEQ",
              "Testes aleatorios finalizados",
              UVM_LOW)

  endtask : body

endclass : minisoc_random_vseq
