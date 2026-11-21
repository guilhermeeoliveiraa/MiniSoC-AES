
class rst_drv extends uvm_driver #(rst_item);

  `uvm_component_utils(rst_drv)

  // Interface virtual utilizada pelo Driver
  virtual rst_if.drv_mp rst_vif;


  // Construtor
  function new(string name = "rst_drv",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new


  // Recupera a interface virtual configurada
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual rst_if.drv_mp)::get(
          this, "", "rst_vif", rst_vif
        )) begin

      `uvm_fatal("RST_DRV",
                 "Interface virtual rst_if.drv_mp nao configurada!")

    end

  endfunction : build_phase


  // Executa as operacoes de reset
  task run_phase(uvm_phase phase);

    // Inicializa o reset como inativo
    rst_vif.rst_n <= 1'b1;

    forever begin

      // Aguarda um item do Sequencer
      seq_item_port.get_next_item(req);

      // Executa a operacao de reset
      drive_item(req);

      // Finaliza o item recebido
      seq_item_port.item_done();

    end

  endtask : run_phase


  // Atualiza o estado do reset
  local task drive_item(rst_item item);

    rst_vif.rst_n <= item.rst_n;

  endtask : drive_item

endclass : rst_drv
