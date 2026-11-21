
class mem_data_mon extends uvm_monitor;

  `uvm_component_utils(mem_data_mon)

  // Interface virtual utilizada pelo Monitor
  virtual mem_data_if.mon_mp vif;

  // Porta de análise para publicar as transações observadas
  uvm_analysis_port #(mem_data_item) ap;


  // Construtor
  function new(string name = "mem_data_mon",
               uvm_component parent = null);

    super.new(name, parent);

    ap = new("ap", this);

  endfunction : new


  // Recupera a interface virtual configurada
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual mem_data_if.mon_mp)::get(
          this, "", "vif", vif
        )) begin

      `uvm_fatal("MEM_DATA_MON",
                 "Interface virtual mem_data_if.mon_mp nao configurada!")

    end

  endfunction : build_phase


  // Observa continuamente as operações da memória
  task run_phase(uvm_phase phase);

    mem_data_item item;

    forever begin

      // Aguarda a borda de subida do clock da memória
      @(posedge vif.mem_clk);

      // Cria um novo item para representar a operação observada
      item = mem_data_item::type_id::create("item", this);

      // Registra os sinais de controle e endereço
      item.en    = 1'b1;
      item.we    = vif.mem_i_wr_en;
      item.addr  = vif.mem_i_addr;
      item.wdata = vif.mem_i_data;
      item.rdata = '0;

      // Aguarda a conclusão do ciclo da memória
      @(negedge vif.mem_clk);

      // Identifica uma operação de escrita
      if (item.we) begin

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

      // Identifica uma operação de leitura
      else begin

        // Captura o dado disponibilizado pela memória
        item.rdata = vif.mem_o_data;

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

      // Publica a transação observada
      ap.write(item);

    end

  endtask : run_phase

endclass : mem_data_mon
