class minisoc_mem_seq extends uvm_sequence #(mem_data_item);
  `uvm_object_utils(minisoc_mem_seq)

  typedef enum {
    MEM_WRITE_WORDS,
    MEM_READ_WORDS
  } mem_operation_e;

  mem_operation_e operation = MEM_WRITE_WORDS;

  logic [9:0] base_addr = 10'd0;
  logic [31:0] words[0:3];
  logic [31:0] read_words[0:3];

  function new(string name = "minisoc_mem_seq");
    super.new(name);
    words[0] = 32'h00112233;
    words[1] = 32'h44556677;
    words[2] = 32'h8899AABB;
    words[3] = 32'hCCDDEEFF;
    foreach (read_words[i])
      read_words[i] = '0;
  endfunction

  task body();
    mem_data_item req;

    case (operation)
      MEM_WRITE_WORDS: begin
        for (int i = 0; i < 4; i++) begin
          req = mem_data_item::type_id::create($sformatf("write_req_%0d", i));
          start_item(req);
          req.en = 1'b1;
          req.we = 1'b1;
          req.addr = base_addr + i;
          req.wdata = words[i];
          req.rdata = '0;
          finish_item(req);
          `uvm_info(get_type_name(), $sformatf("MEM WRITE addr=0x%03h data=0x%08h", req.addr, req.wdata), UVM_MEDIUM)
        end
      end

      MEM_READ_WORDS: begin
        for (int i = 0; i < 4; i++) begin
          req = mem_data_item::type_id::create($sformatf("read_req_%0d", i));
          start_item(req);
          req.en = 1'b1;
          req.we = 1'b0;
          req.addr = base_addr + i;
          req.wdata = '0;
          req.rdata = '0;
          finish_item(req);
          read_words[i] = req.rdata;
          `uvm_info(get_type_name(), $sformatf("MEM READ addr=0x%03h data=0x%08h", req.addr, read_words[i]), UVM_MEDIUM)
        end
      end

      default:
        `uvm_fatal("MEM_SEQ_OPERATION", "Operacao de memoria desconhecida")
    endcase
  endtask
endclass : minisoc_mem_seq