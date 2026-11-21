
class spi_drv extends uvm_driver #(spi_item);

  `uvm_component_utils(spi_drv)

  // Interface virtual utilizada pelo Driver
  virtual spi_if.drv_mp vif;

  // Semiperíodo do clock SPI: 20 ns = 25 MHz
  time spi_half_period = 20ns;

  // Item recebido do Sequencer
  spi_item item;


  // Construtor
  function new(string name = "spi_drv",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Recupera a interface virtual configurada
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual spi_if.drv_mp)::get(
          this, "", "vif", vif
        )) begin

      `uvm_fatal("SPI_DRV",
                 "Interface virtual spi_if.drv_mp nao configurada!")

    end

  endfunction : build_phase


  // Aguarda e executa continuamente as transações
  task run_phase(uvm_phase phase);

    // Inicializa os sinais no estado idle do SPI Mode 0
    vif.sclk = 1'b0;
    vif.cs_n = 1'b1;
    vif.mosi = 1'b0;

    forever begin

      // Recebe uma transação do Sequencer
      seq_item_port.get_next_item(item);

      // Executa a transferência SPI
      drive_transfer(item);

      // Informa ao Sequencer que a transação foi concluída
      seq_item_port.item_done();

    end

  endtask : run_phase


  // Executa uma transferência SPI de 40 bits
  task drive_transfer(spi_item tr);

    logic [39:0] tx_frame;
    logic [39:0] rx_frame;

    // Monta o quadro SPI
    tx_frame = {
      tr.op,
      tr.addr,
      tr.reserved,
      tr.data
    };

    // Inicializa o registrador de recepção
    rx_frame = '0;

    // Garante o estado idle
    vif.sclk = 1'b0;
    vif.cs_n = 1'b1;
    vif.mosi = 1'b0;

    #(spi_half_period);

    // Seleciona o dispositivo SPI
    vif.cs_n = 1'b0;

    #(spi_half_period);

    // Transmite os 40 bits em ordem MSB-first
    for (int i = 39; i >= 0; i--) begin

      // Apresenta o bit em MOSI durante SCLK baixo
      vif.mosi = tx_frame[i];

      #(spi_half_period);

      // Captura MISO antes da borda de subida
      rx_frame[i] = vif.miso;

      // Borda de subida: o DUT amostra MOSI
      vif.sclk = 1'b1;

      #(spi_half_period);

      // Borda de descida
      vif.sclk = 1'b0;

    end

    #(spi_half_period);

    // Finaliza a transferência
    vif.cs_n = 1'b1;
    vif.mosi = 1'b0;

    // Armazena os 32 bits recebidos
    tr.rx_data = rx_frame[31:0];

  endtask : drive_transfer

endclass : spi_drv
