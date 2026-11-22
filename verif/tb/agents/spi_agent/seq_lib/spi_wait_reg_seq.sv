class spi_wait_reg_seq extends spi_base_seq;

  `uvm_object_utils(spi_wait_reg_seq)


  // Endereco do registrador
  rand logic [5:0] addr;

  // Mascara dos bits que devem ser verificados
  logic [31:0] mask;

  // Valor esperado para os bits selecionados
  logic [31:0] expected;

  // Intervalo entre consultas
  realtime poll_delay = 1us;

  // Quantidade maxima de consultas
  int unsigned max_polls = 1000;

  // Valor lido do registrador
  logic [31:0] data;


  // Construtor
  function new(string name = "spi_wait_reg_seq");

    super.new(name);

  endfunction : new


  // Aguarda uma condicao no registrador
  task body();

    spi_read_reg_seq read_seq;

    bit condition_met;

    condition_met = 1'b0;

    read_seq = spi_read_reg_seq::type_id::create("read_seq");

    for (int i = 0; i < max_polls; i++) begin

      // Configura o endereco do registrador
      read_seq.addr = addr;

      // Realiza a leitura SPI
      read_seq.start(p_sequencer);

      // Recupera o valor lido
      data = read_seq.data;

      // Verifica a condicao esperada
      if ((data & mask) == expected) begin

        condition_met = 1'b1;

        `uvm_info("SPI_WAIT_REG",
                  $sformatf("Condicao atendida: addr=0x%02h data=0x%08h",
                            addr, data),
                  UVM_LOW)

        break;

      end

      // Aguarda antes da proxima consulta
      #(poll_delay);

    end

    if (!condition_met) begin

      `uvm_fatal("SPI_WAIT_REG",
                 $sformatf("Timeout: addr=0x%02h data=0x%08h mask=0x%08h expected=0x%08h",
                           addr, data, mask, expected))

    end

  endtask : body

endclass : spi_wait_reg_seq