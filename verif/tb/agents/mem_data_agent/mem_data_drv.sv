
class mem_data_drv extends uvm_driver #(mem_data_item);

  `uvm_component_utils(mem_data_drv)

  // Interface virtual utilizada pelo Driver
  virtual mem_data_if.drv_mp vif;

  // Periodo do clock da memoria
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


  // Aguarda e executa continuamente as transacoes
  task run_phase(uvm_phase phase);

    mem_data_item rsp;

    // Inicializa os sinais da memoria
    vif.mem_clk     = 1'b0;
    vif.mem_i_data  = '0;
    vif.mem_i_wr_en = 1'b0;
    vif.mem_i_addr  = '0;

    forever begin

      // Recebe uma transacao do Sequencer
      seq_item_port.get_next_item(item);

      // Executa a operacao de memoria
      drive_transfer(item);

      // Cria a resposta da transacao
      rsp = mem_data_item::type_id::create("rsp");

      // Preserva a identificacao da requisicao
      rsp.set_id_info(item);

      // Retorna o dado lido
      rsp.rdata = item.rdata;

      // Finaliza a requisicao e retorna a resposta
      seq_item_port.item_done(rsp);

    end

  endtask : run_phase


  // Executa uma operacao de leitura ou escrita na memoria
  task drive_transfer(mem_data_item tr);

    // Inicializa o dado de resposta
    tr.rdata = '0;

    // Verifica se existe uma operacao solicitada
    if (!tr.en) begin
      return;
    end

    // Mantem o clock inicialmente em nivel baixo
    vif.mem_clk = 1'b0;

    // Apresenta o endereco e os dados na interface
    vif.mem_i_addr = tr.addr;
    vif.mem_i_data = tr.wdata;

    // Define se a operacao sera de leitura ou escrita
    vif.mem_i_wr_en = tr.we;

    // Aguarda antes da borda ativa do clock
    #(mem_clk_period / 2);

    // Borda de subida do clock da memoria
    vif.mem_clk = 1'b1;

    // Aguarda o processamento da operacao pela memoria
    #(mem_clk_period / 2);

    // Captura o dado de saida somente em operacoes de leitura
    if (!tr.we) begin

      tr.rdata = vif.mem_o_data;

    end

    // Borda de descida do clock
    vif.mem_clk = 1'b0;

    // Desativa o sinal de escrita
    vif.mem_i_wr_en = 1'b0;

  endtask : drive_transfer

endclass : mem_data_drv
