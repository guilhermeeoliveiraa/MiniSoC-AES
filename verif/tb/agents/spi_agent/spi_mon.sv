
class spi_mon extends uvm_monitor;

  `uvm_component_utils(spi_mon)

  // Interface virtual utilizada pelo Monitor
  virtual spi_if.mon_mp vif;

  // Porta de análise para publicar as transações observadas
  uvm_analysis_port #(spi_item) item_collected_port;

  // Indica se existe uma leitura aguardando resposta
  bit pending_read;

  // Armazena o endereço da leitura solicitada
  logic [5:0] pending_addr;


  // Construtor
  function new(string name = "spi_mon",
               uvm_component parent = null);

    super.new(name, parent);

    item_collected_port = new("item_collected_port", this);

    pending_read = 1'b0;
    pending_addr = '0;

  endfunction : new


  // Recupera a interface virtual configurada
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual spi_if.mon_mp)::get(
          this, "", "vif", vif
        )) begin

      `uvm_fatal("SPI_MON",
                 "Interface virtual spi_if.mon_mp nao configurada!")

    end

  endfunction : build_phase


  // Observa continuamente as transferências SPI
  task run_phase(uvm_phase phase);

    spi_item item;

    logic [39:0] tx_frame;
    logic [39:0] rx_frame;

    logic [5:0] frame_addr;
    logic frame_rw;
    logic frame_reserved;

    bit frame_valid;

    forever begin

      // Aguarda a seleção do dispositivo SPI
      @(negedge vif.cs_n);

      // Inicializa os quadros de transmissão e recepção
      tx_frame = '0;
      rx_frame = '0;

      frame_valid = 1'b1;

      // Captura os 40 bits do quadro SPI
      for (int i = 39; i >= 0; i--) begin

        // Aguarda a borda de subida do clock ou a desativação
        // do dispositivo SPI
        @(posedge vif.sclk or posedge vif.cs_n);

        if (vif.cs_n) begin
          frame_valid = 1'b0;
          break;
        end

        // Captura MOSI e MISO na borda de subida
        tx_frame[i] = vif.mosi;
        rx_frame[i] = vif.miso;

      end

      // Descarta quadros incompletos
      if (!frame_valid) begin

        pending_read = 1'b0;

        `uvm_warning("SPI_MON",
                     "Transferencia SPI incompleta")

        continue;

      end

      // Extrai os campos do quadro SPI
      frame_rw       = tx_frame[39];
      frame_addr     = tx_frame[38:33];
      frame_reserved = tx_frame[32];

      // Verifica o bit reservado
      if (frame_reserved != 1'b0) begin

        `uvm_error("SPI_MON",
                   "Bit reservado do quadro SPI diferente de zero")

        pending_read = 1'b0;

        continue;

      end

      // Identifica uma operacao de escrita
      if (!frame_rw) begin

        item = spi_item::type_id::create("write_item", this);

        item.op       = spi_item::SPI_WRITE;
        item.addr     = frame_addr;
        item.reserved = frame_reserved;
        item.data     = tx_frame[31:0];
        item.rx_data  = '0;

        // Publica a transacao observada
        item_collected_port.write(item);

        `uvm_info(
          get_type_name(),
          $sformatf(
            "SPI WRITE: addr=0x%02h data=0x%08h",
            item.addr,
            item.data
          ),
          UVM_MEDIUM
        )

        // Cancela uma leitura que ainda aguardava resposta
        pending_read = 1'b0;

      end

      // Identifica a primeira transacao de leitura
      else if (!pending_read) begin

        // Armazena o endereco solicitado
        pending_addr = frame_addr;

        // Indica que uma resposta esta sendo aguardada
        pending_read = 1'b1;

        `uvm_info(
          get_type_name(),
          $sformatf(
            "SPI READ solicitado: addr=0x%02h",
            pending_addr
          ),
          UVM_MEDIUM
        )

      end

      // Identifica a segunda transacao de leitura
      else begin

        item = spi_item::type_id::create("read_item", this);

        item.op       = spi_item::SPI_READ;
        item.addr     = pending_addr;
        item.reserved = frame_reserved;
        item.data     = '0;

        // Captura os dados recebidos atraves de MISO
        item.rx_data = rx_frame[31:0];

        // Publica a transacao de leitura concluida
        item_collected_port.write(item);

        `uvm_info(
          get_type_name(),
          $sformatf(
            "SPI READ concluido: addr=0x%02h data=0x%08h",
            item.addr,
            item.rx_data
          ),
          UVM_MEDIUM
        )

        // Finaliza o acompanhamento da leitura
        pending_read = 1'b0;

      end

    end

  endtask : run_phase

endclass : spi_mon
