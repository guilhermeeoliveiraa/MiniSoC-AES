class mem_data_drv extends uvm_driver #(mem_data_item);
  `uvm_component_utils(mem_data_drv)

  virtual mem_data_if vif;

  function new(string name = "mem_data_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual mem_data_if)::get(this, "", "mem_vif", vif)) begin
      `uvm_fatal("MEM_DRV_NO_VIF",
                 "Virtual interface mem_vif nao encontrada!")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    mem_data_item item;

    vif.en    <= 1'b0;
    vif.we    <= 1'b0;
    vif.addr  <= '0;
    vif.wdata <= '0;

    forever begin
      seq_item_port.get_next_item(item);
      drive_item(item);
      seq_item_port.item_done();
    end
  endtask : run_phase

  task drive_item(mem_data_item item);
    if (item.addr > 10'd1023) begin
      `uvm_error("MEM_ADDR_RANGE",
                 $sformatf("Endereco invalido: 0x%03h", item.addr))
      item.rdata = '0;
      return;
    end

    if (!vif.rst_n) begin
      `uvm_error("MEM_DURING_RESET",
                 "Tentativa de acessar memoria durante reset")
      item.rdata = '0;
      return;
    end

    @(negedge vif.clk);

    vif.en    <= item.en;
    vif.we    <= item.en && item.we;
    vif.addr  <= item.addr;
    vif.wdata <= item.wdata;

    if (item.en) begin
      if (item.we) begin
        @(posedge vif.clk);

        `uvm_info(
          get_type_name(),
          $sformatf(
            "MEM WRITE: addr=0x%03h data=0x%08h",
            item.addr,
            item.wdata
          ),
          UVM_MEDIUM
        )
      end
      else begin
        @(posedge vif.clk);
        #1ps;

        item.rdata = vif.rdata;

        `uvm_info(
          get_type_name(),
          $sformatf(
            "MEM READ: addr=0x%03h data=0x%08h",
            item.addr,
            item.rdata
          ),
          UVM_MEDIUM
        )
      end
    end
    else begin
      item.rdata = '0;
      @(posedge vif.clk);
    end

    @(negedge vif.clk);

    vif.en    <= 1'b0;
    vif.we    <= 1'b0;
    vif.wdata <= '0;
  endtask : drive_item

endclass : mem_data_drv