class mem_data_drv extends uvm_driver #(mem_data_item);
  `uvm_component_utils(mem_data_drv)

  virtual mem_data_if vif;

  logic [31:0] memory [0:1023];

  function new(string name = "mem_data_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual mem_data_if)::get(this, "", "mem_vif", vif)) begin
      `uvm_fatal("MEM_DRV_NO_VIF", "Virtual interface mem_vif nao encontrada!")
    end
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    int i;

    vif.rdata = '0;

    for (i = 0; i < 1024; i++) begin
      memory[i] = '0;
    end

    forever begin
      @(posedge vif.clk);

      if (!vif.rst_n) begin
        vif.rdata <= '0;
      end
      else if (vif.en) begin
        if (vif.addr < 1024) begin
          if (vif.we) begin
            memory[vif.addr] <= vif.wdata;

            `uvm_info(
              get_type_name(),
              $sformatf(
                "Memoria WRITE: addr=0x%03h data=0x%08h",
                vif.addr,
                vif.wdata
              ),
              UVM_HIGH
            )
          end
          else begin
            vif.rdata <= memory[vif.addr];

            `uvm_info(
              get_type_name(),
              $sformatf(
                "Memoria READ: addr=0x%03h data=0x%08h",
                vif.addr,
                memory[vif.addr]
              ),
              UVM_HIGH
            )
          end
        end
        else begin
          `uvm_error(
            "MEM_ADDR_RANGE",
            $sformatf("Endereco de memoria invalido: 0x%03h", vif.addr)
          )

          vif.rdata <= '0;
        end
      end
    end
  endtask : run_phase

endclass : mem_data_drv