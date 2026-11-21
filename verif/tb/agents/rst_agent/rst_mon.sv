
class rst_mon extends uvm_monitor;

  `uvm_component_utils(rst_mon)

  // Interface virtual utilizada pelo Monitor
  virtual rst_if.mon_mp vif;

  // Porta de analise para publicar as transacoes observadas
  uvm_analysis_port #(rst_item) item_collected_port;


  // Construtor
  function new(string name = "rst_mon",
               uvm_component parent = null);

    super.new(name, parent);

    item_collected_port = new("item_collected_port", this);

  endfunction : new


  // Recupera a interface virtual configurada
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual rst_if.mon_mp)::get(
          this, "", "vif", vif
        )) begin

      `uvm_fatal("RST_MON",
                 "Interface virtual rst_if.mon_mp nao configurada!")

    end

  endfunction : build_phase


  // Monitora as operacoes de reset
  task run_phase(uvm_phase phase);

    rst_item item;

    realtime t_start;
    realtime t_end;

    forever begin

      // Aguarda a ativacao do reset
      @(negedge vif.rst_n);

      t_start = $realtime;

      // Aguarda a desativacao do reset
      @(posedge vif.rst_n);

      t_end = $realtime;

      // Cria o item observado
      item = rst_item::type_id::create("item");

      item.rst_n = 1'b1;

      // Publica a transacao observada
      item_collected_port.write(item);

      // Registra a duracao observada do reset
      `uvm_info("RST_MON",
                $sformatf("Reset desativado apos %0t",
                          t_end - t_start),
                UVM_LOW)

    end

  endtask : run_phase

endclass : rst_mon
