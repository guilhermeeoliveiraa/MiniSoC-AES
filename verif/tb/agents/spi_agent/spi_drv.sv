class spi_drv extends uvm_driver #(spi_item);
  `uvm_component_utils(spi_drv)

  virtual spi_if vif;

  localparam time SPI_HALF_PERIOD = 20ns;
  localparam time CS_SETUP_TIME   = 40ns;
  localparam time CS_HOLD_TIME    = 40ns;

  function new(string name = "spi_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual spi_if)::get(this, "", "spi_vif", vif)) begin
      `uvm_fatal("SPI_DRV_NO_VIF",
                 "Virtual interface 'spi_vif' nao encontrada no uvm_config_db!")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    spi_item item;

    vif.cs_n <= 1'b1;
    vif.sclk <= 1'b0;
    vif.mosi <= 1'b0;

    forever begin
      seq_item_port.get_next_item(item);
      drive_item(item);
      seq_item_port.item_done();
    end
  endtask : run_phase

  task drive_item(spi_item item);
    logic [39:0] frame;
    logic [31:0] read_data;

    if (item.addr > 8'h3F) begin
      `uvm_fatal("SPI_ADDR_RANGE",
                 $sformatf("Endereco SPI fora do intervalo de 6 bits: 0x%02h",
                           item.addr))
    end

    item.rx_data = '0;

    if (item.op == spi_item::SPI_WRITE) begin
      frame = {1'b0, item.addr[5:0], 1'b0, item.data};

      spi_frame(frame, read_data);
    end
    else begin
      frame = {1'b1, item.addr[5:0], 1'b0, 32'h00000000};

      spi_frame(frame, read_data);

      #CS_HOLD_TIME;

      frame = {1'b1, 6'h3F, 1'b0, 32'h00000000};

      spi_frame(frame, read_data);

      item.rx_data = read_data;
    end

    vif.cs_n <= 1'b1;
    vif.sclk <= 1'b0;
    vif.mosi <= 1'b0;

    #CS_HOLD_TIME;
  endtask : drive_item

  task spi_frame(
    input  logic [39:0] tx_frame,
    output logic [31:0] rx_data
  );
    logic [39:0] rx_frame;

    rx_frame = '0;
    rx_data  = '0;

    vif.sclk <= 1'b0;
    vif.cs_n <= 1'b0;
    vif.mosi <= tx_frame[39];

    #CS_SETUP_TIME;

    for (int i = 39; i >= 0; i--) begin
      vif.mosi <= tx_frame[i];

      #SPI_HALF_PERIOD;
      vif.sclk <= 1'b1;

      #1ns;
      rx_frame[i] = vif.miso;

      # (SPI_HALF_PERIOD - 1ns);
      vif.sclk <= 1'b0;
    end

    rx_data = rx_frame[31:0];

    vif.mosi <= 1'b0;
    #CS_HOLD_TIME;
  endtask : spi_frame

endclass : spi_drv