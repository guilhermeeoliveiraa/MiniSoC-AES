class spi_mon extends uvm_monitor;
  `uvm_component_utils(spi_mon)

  virtual spi_if vif;
  uvm_analysis_port #(spi_item) item_collected_port;

  bit pending_read;
  logic [5:0] pending_addr;

  function new(string name = "spi_mon", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
    pending_read = 1'b0;
    pending_addr = '0;
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual spi_if)::get(this, "", "spi_vif", vif)) begin
      `uvm_fatal("SPI_MON_NO_VIF",
                 "Virtual interface 'spi_vif' nao encontrada no uvm_config_db!")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    spi_item item;
    logic [39:0] frame;
    logic [5:0] frame_addr;
    logic frame_rw;
    bit frame_valid;

    forever begin
      @(negedge vif.cs_n);

      frame = '0;
      frame_valid = 1'b1;

      for (int i = 39; i >= 0; i--) begin
        @(posedge vif.sclk or posedge vif.cs_n);

        if (vif.cs_n) begin
          frame_valid = 1'b0;
          break;
        end

        frame[i] = vif.mosi;
      end

      if (!frame_valid)
        continue;

      frame_rw = frame[39];
      frame_addr = frame[38:33];

      if (!frame_rw) begin
        item = spi_item::type_id::create("write_item", this);
        item.op = spi_item::SPI_WRITE;
        item.addr = {2'b00, frame_addr};
        item.data = frame[31:0];
        item.rx_data = '0;

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

        pending_read = 1'b0;
      end
      else if (!pending_read) begin
        pending_addr = frame_addr;
        pending_read = 1'b1;

        `uvm_info(
          get_type_name(),
          $sformatf("SPI READ solicitado: addr=0x%02h", pending_addr),
          UVM_MEDIUM
        )
      end
      else begin
        item = spi_item::type_id::create("read_item", this);
        item.op = spi_item::SPI_READ;
        item.addr = {2'b00, pending_addr};
        item.data = '0;
        item.rx_data = frame[31:0];

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

        pending_read = 1'b0;
      end
    end
  endtask : run_phase

endclass : spi_mon