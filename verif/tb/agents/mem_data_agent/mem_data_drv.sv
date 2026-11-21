
class mem_data_drv extends uvm_driver #(mem_data_item);

  `uvm_component_utils(mem_data_drv)

  // Interface virtual utilizada pelo Driver
  virtual mem_data_if.drv_mp vif;

  // Período do clock da memória
  time mem_clk_period = 20ns;

  // Item recebido do Sequencer
  mem_data_item item;


  // Construtor
  function new(string name = "mem_data_drv",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Recupera a interface virtual configurada
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual mem_data_if.drv_mp)::get(
          this, "", "vif", vif
        )) begin

      `uvm_fatal("MEM_DATA_DRV",
                 "Interface virtual mem_data_if.drv_mp nao configurada!")

    end

  endfunction : build_phase


  // Aguarda e executa continuamente as transações
  task run_phase(uvm_phase phase);

    // Inicializa os sinais da memória
    vif.mem_clk     = 1'b0;
    vif.mem_i_data  = '0;
    vif.mem_i_wr_en = 1'b0;
    vif.mem_i_addr  = '0;

    forever begin

      // Recebe uma transação do Sequencer
      seq_item_port.get_next_item(item);

      // Executa a operação de memória
      drive_transfer(item);

      // Informa ao Sequencer que a transação foi concluída
      seq_item_port.item_done();

    end

  endtask : run_phase


  // Executa uma operação de leitura ou escrita na memória
  task drive_transfer(mem_data_item tr);

    // Verifica se existe uma operação solicitada
    if (!tr.en) begin
      return;
    end

    // Mantém o clock inicialmente em nível baixo
    vif.mem_clk = 1'b0;

    // Apresenta o endereço e os dados na interface
    vif.mem_i_addr = tr.addr;
    vif.mem_i_data = tr.wdata;

    // Define se a operação será de leitura ou escrita
    vif.mem_i_wr_en = tr.we;

    // Aguarda antes da borda ativa do clock
    #(mem_clk_period / 2);

    // Borda de subida do clock da memória
    vif.mem_clk = 1'b1;

    // Aguarda o processamento da operação pela memória
    #(mem_clk_period / 2);

    // Captura o dado de saída em caso de leitura
    if (!tr.we) begin

      tr.rdata = vif.mem_o_data;

    end

    // Borda de descida do clock
    vif.mem_clk = 1'b0;

    // Desativa o sinal de escrita
    vif.mem_i_wr_en = 1'b0;

  endtask : drive_transfer

endclass : mem_data_drv
