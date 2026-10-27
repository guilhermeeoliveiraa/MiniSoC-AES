class spi_drv extends uvm_driver #(spi_item);
  `uvm_component_utils(spi_drv)

  virtual spi_if vif;

  function new(string name = "spi_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (vif == null) begin
      if (!uvm_config_db#(virtual spi_if)::get(this, "", "spi_vif", vif)) begin
        `uvm_fatal("SPI_DRV_NO_VIF", "Virtual interface 'spi_vif' nao encontrada no uvm_config_db!")
      end
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
    vif.cs_n <= 1'b0;
    #10ns;

    vif.mosi <= item.op;
    toggle_sclk();

    for (int i = 7; i >= 0; i--) begin
      vif.mosi <= item.addr[i];
      toggle_sclk();
    end

    if (item.op == spi_item::SPI_WRITE) begin
      for (int i = 31; i >= 0; i--) begin
        vif.mosi <= item.data[i];
        toggle_sclk();
      end
    end else begin
      for (int i = 31; i >= 0; i--) begin
        toggle_sclk();
        item.rx_data[i] = vif.miso;
      end
    end

    vif.cs_n <= 1'b1;
    vif.mosi <= 1'b0;
    #20ns;
  endtask : drive_item

  task toggle_sclk();
    #5ns;
    vif.sclk <= 1'b1;
    #5ns;
    vif.sclk <= 1'b0;
  endtask : toggle_sclk

endclass : spi_drv