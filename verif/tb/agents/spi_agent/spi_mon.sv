class spi_mon extends uvm_monitor;
  `uvm_component_utils(spi_mon)

  virtual spi_if vif;

  uvm_analysis_port #(spi_item) item_collected_port;

  function new(string name = "spi_mon", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (vif == null) begin
      if (!uvm_config_db#(virtual spi_if)::get(this, "", "spi_vif", vif)) begin
        `uvm_fatal("SPI_MON_NO_VIF", "Virtual interface 'spi_vif' nao encontrada no uvm_config_db!")
      end
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    spi_item item;

    forever begin
      @(negedge vif.cs_n);

      item = spi_item::type_id::create("item");

      @(posedge vif.sclk);
      item.op = spi_item::spi_op_e'(vif.mosi);

      for (int i = 7; i >= 0; i--) begin
        @(posedge vif.sclk);
        item.addr[i] = vif.mosi;
      end

      if (item.op == spi_item::SPI_WRITE) begin
        for (int i = 31; i >= 0; i--) begin
          @(posedge vif.sclk);
          item.data[i] = vif.mosi;
        end
        `uvm_info(get_type_name(), $sformatf("SPI Write Capturado: addr=0x%0h data=0x%0h", item.addr, item.data), UVM_HIGH)
      end else begin
        for (int i = 31; i >= 0; i--) begin
          @(posedge vif.sclk);
          item.rx_data[i] = vif.miso;
        end
        `uvm_info(get_type_name(), $sformatf("SPI Read Capturado: addr=0x%0h rx_data=0x%0h", item.addr, item.rx_data), UVM_HIGH)
      end

      @(posedge vif.cs_n);
      item_collected_port.write(item);
    end
  endtask : run_phase

endclass : spi_mon