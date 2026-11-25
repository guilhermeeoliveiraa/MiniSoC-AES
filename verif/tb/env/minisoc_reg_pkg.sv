
package minisoc_reg_pkg;

  // ============================================================
  // MiniSoC AES - Register and Configuration Package
  // Block Guide V1.0.0 - September 2026
  // ============================================================


  // ============================================================
  // 1. GENERAL PARAMETERS
  // ============================================================

  localparam int REG_ADDR_WIDTH = 6;
  localparam int REG_DATA_WIDTH = 32;

  localparam int AES_BLOCK_WIDTH = 128;
  localparam int AES_KEY_WIDTH   = 128;
  localparam int AES_IV_WIDTH    = 128;

  localparam int AES_WORD_WIDTH  = 32;
  localparam int AES_WORDS_PER_BLOCK = 4;

  localparam int AES_COUNTER_WIDTH = 64;

  localparam int MEM_DATA_WIDTH = 32;
  localparam int MEM_ADDR_WIDTH = 10;
  localparam int MEM_DEPTH      = 1024;

  localparam int AES_MAX_BLOCKS = 256;
  localparam int AES_MIN_BLOCKS = 1;


  // ============================================================
  // 2. SPI REGISTER ADDRESS MAP
  // ============================================================

  localparam logic [REG_ADDR_WIDTH-1:0] REG_KEY0          = 6'h00;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_KEY1          = 6'h01;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_KEY2          = 6'h02;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_KEY3          = 6'h03;

  localparam logic [REG_ADDR_WIDTH-1:0] REG_IV0           = 6'h04;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_IV1           = 6'h05;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_IV2           = 6'h06;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_IV3           = 6'h07;

  localparam logic [REG_ADDR_WIDTH-1:0] REG_COUNTER_HI    = 6'h08;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_COUNTER_LO    = 6'h09;

  localparam logic [REG_ADDR_WIDTH-1:0] REG_NUM_BLOCKS    = 6'h0A;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_AES_CONTROL   = 6'h0B;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_AES_STATUS    = 6'h0C;

  localparam logic [REG_ADDR_WIDTH-1:0] REG_VERSION       = 6'h0D;

  localparam logic [REG_ADDR_WIDTH-1:0] REG_SYSTEM_CONTROL = 6'h0E;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_SYSTEM_STATUS  = 6'h0F;

  localparam logic [REG_ADDR_WIDTH-1:0] REG_NOP           = 6'h3F;


  // ============================================================
  // 3. KEY REGISTERS
  // ============================================================

  // KEY0 -> cfg_key[127:96]
  // KEY1 -> cfg_key[95:64]
  // KEY2 -> cfg_key[63:32]
  // KEY3 -> cfg_key[31:0]

  localparam logic [31:0] KEY_WORD_MASK = 32'hFFFFFFFF;

  localparam int KEY_WORD_COUNT = 4;


  // ============================================================
  // 4. IV REGISTERS
  // ============================================================

  // IV0 -> cfg_iv[127:96]
  // IV1 -> cfg_iv[95:64]
  // IV2 -> cfg_iv[63:32]
  // IV3 -> cfg_iv[31:0]

  localparam logic [31:0] IV_WORD_MASK = 32'hFFFFFFFF;

  localparam int IV_WORD_COUNT = 4;


  // ============================================================
  // 5. COUNTER REGISTERS
  // ============================================================

  // COUNTER_HI -> cfg_counter[63:32]
  // COUNTER_LO -> cfg_counter[31:0]

  localparam logic [31:0] COUNTER_WORD_MASK = 32'hFFFFFFFF;

  localparam int COUNTER_WORD_COUNT = 2;


  // ============================================================
  // 6. NUM_BLOCKS REGISTER (0x0A)
  // ============================================================

  // Valid range: 1..256
  // Register field: [8:0]

  localparam int NUM_BLOCKS_OFFSET = 0;
  localparam int NUM_BLOCKS_WIDTH  = 9;

  localparam logic [31:0] NUM_BLOCKS_MASK = 32'h000001FF;

  localparam logic [8:0] NUM_BLOCKS_MIN = 9'd1;
  localparam logic [8:0] NUM_BLOCKS_MAX = 9'd256;


  // ============================================================
  // 7. AES_CONTROL REGISTER (0x0B)
  // ============================================================

  // Bit 0    : START
  // Bit 1    : DECRYPT
  // Bits 4:2 : MODE
  // Bits 31:5: RESERVED

  // ----------------------------
  // START field
  // ----------------------------

  localparam int AES_START_OFFSET = 0;
  localparam int AES_START_WIDTH  = 1;

  localparam logic [31:0] AES_START_MASK = 32'h00000001;

  localparam logic [31:0] AES_START_IDLE = 32'h00000000;
  localparam logic [31:0] AES_START_CMD  = 32'h00000001;


  // ----------------------------
  // DECRYPT field
  // ----------------------------

  localparam int AES_DECRYPT_OFFSET = 1;
  localparam int AES_DECRYPT_WIDTH  = 1;

  localparam logic [31:0] AES_DECRYPT_MASK = 32'h00000002;

  localparam logic [31:0] AES_ENCRYPT = 32'h00000000;
  localparam logic [31:0] AES_DECRYPT = 32'h00000002;


  // ----------------------------
  // MODE field
  // ----------------------------

  localparam int AES_MODE_OFFSET = 2;
  localparam int AES_MODE_WIDTH  = 3;

  localparam logic [31:0] AES_MODE_MASK = 32'h0000001C;

  // Raw 3-bit mode encodings

  localparam logic [2:0] AES_MODE_ECB  = 3'b000;
  localparam logic [2:0] AES_MODE_CBC  = 3'b001;
  localparam logic [2:0] AES_MODE_PCBC = 3'b010;
  localparam logic [2:0] AES_MODE_CFB  = 3'b011;
  localparam logic [2:0] AES_MODE_OFB  = 3'b100;
  localparam logic [2:0] AES_MODE_CTR  = 3'b101;

  // Mode values already positioned in AES_CONTROL[4:2]

  localparam logic [31:0] AES_MODE_ECB_REG  = 32'h00000000;
  localparam logic [31:0] AES_MODE_CBC_REG  = 32'h00000004;
  localparam logic [31:0] AES_MODE_PCBC_REG = 32'h00000008;
  localparam logic [31:0] AES_MODE_CFB_REG  = 32'h0000000C;
  localparam logic [31:0] AES_MODE_OFB_REG  = 32'h00000010;
  localparam logic [31:0] AES_MODE_CTR_REG  = 32'h00000014;

  // Complete AES_CONTROL field mask

  localparam logic [31:0] AES_CONTROL_MASK = 32'h0000001F;


  // ============================================================
  // 8. AES_STATUS REGISTER (0x0C)
  // ============================================================

  // Bit 0     : BUSY
  // Bit 1     : DONE
  // Bit 2     : ERROR
  // Bits 11:3 : BLOCKS_DONE
  // Bits 31:12: RESERVED

  // ----------------------------
  // BUSY
  // ----------------------------

  localparam int AES_BUSY_OFFSET = 0;
  localparam int AES_BUSY_WIDTH  = 1;

  localparam logic [31:0] AES_BUSY_MASK = 32'h00000001;

  localparam logic [31:0] AES_IDLE = 32'h00000000;
  localparam logic [31:0] AES_BUSY = 32'h00000001;


  // ----------------------------
  // DONE
  // ----------------------------

  localparam int AES_DONE_OFFSET = 1;
  localparam int AES_DONE_WIDTH  = 1;

  localparam logic [31:0] AES_DONE_MASK = 32'h00000002;

  localparam logic [31:0] AES_NOT_DONE = 32'h00000000;
  localparam logic [31:0] AES_DONE_SET = 32'h00000002;


  // ----------------------------
  // ERROR
  // ----------------------------

  localparam int AES_ERROR_OFFSET = 2;
  localparam int AES_ERROR_WIDTH  = 1;

  localparam logic [31:0] AES_ERROR_MASK = 32'h00000004;

  localparam logic [31:0] AES_NO_ERROR = 32'h00000000;
  localparam logic [31:0] AES_ERROR_SET = 32'h00000004;


  // ----------------------------
  // BLOCKS_DONE
  // ----------------------------

  localparam int AES_BLOCKS_DONE_OFFSET = 3;
  localparam int AES_BLOCKS_DONE_WIDTH  = 9;

  localparam logic [31:0] AES_BLOCKS_DONE_MASK = 32'h00000FF8;

  localparam logic [31:0] AES_STATUS_MASK = 32'h00000FFF;


  // ============================================================
  // 9. VERSION REGISTER (0x0D)
  // ============================================================

  localparam logic [31:0] REG_VERSION_VALUE = 32'h00010100;


  // ============================================================
  // 10. SYSTEM_CONTROL REGISTER (0x0E)
  // ============================================================

  // Bit 0   : MEM_SEL_AES
  // Bit 1   : PLL_ENABLE
  // Bits 3:2: PLL_DIV_SEL

  // ----------------------------
  // MEM_SEL_AES
  // ----------------------------

  localparam int MEM_SEL_AES_OFFSET = 0;
  localparam int MEM_SEL_AES_WIDTH  = 1;

  localparam logic [31:0] MEM_SEL_AES_MASK = 32'h00000001;

  localparam logic [31:0] MEM_SEL_EXT = 32'h00000000;
  localparam logic [31:0] MEM_SEL_AES = 32'h00000001;


  // ----------------------------
  // PLL_ENABLE
  // ----------------------------

  localparam int PLL_ENABLE_OFFSET = 1;
  localparam int PLL_ENABLE_WIDTH  = 1;

  localparam logic [31:0] PLL_ENABLE_MASK = 32'h00000002;

  localparam logic [31:0] PLL_DISABLE = 32'h00000000;
  localparam logic [31:0] PLL_ENABLE  = 32'h00000002;


  // ----------------------------
  // PLL_DIV_SEL
  // ----------------------------

  localparam int PLL_DIV_OFFSET = 2;
  localparam int PLL_DIV_WIDTH  = 2;

  localparam logic [31:0] PLL_DIV_MASK = 32'h0000000C;

  // Raw 2-bit encodings

  localparam logic [1:0] PLL_DIV_SEL_1 = 2'b00;
  localparam logic [1:0] PLL_DIV_SEL_2 = 2'b01;
  localparam logic [1:0] PLL_DIV_SEL_4 = 2'b10;
  localparam logic [1:0] PLL_DIV_SEL_8 = 2'b11;

  // Values already positioned in SYSTEM_CONTROL[3:2]

  localparam logic [31:0] PLL_DIV_1 = 32'h00000000;
  localparam logic [31:0] PLL_DIV_2 = 32'h00000004;
  localparam logic [31:0] PLL_DIV_4 = 32'h00000008;
  localparam logic [31:0] PLL_DIV_8 = 32'h0000000C;

  localparam logic [31:0] SYSTEM_CONTROL_MASK = 32'h0000000F;


  // ============================================================
  // 11. SYSTEM_STATUS REGISTER (0x0F)
  // ============================================================

  // Bit 0: PLL_LOCKED

  localparam int PLL_LOCKED_OFFSET = 0;
  localparam int PLL_LOCKED_WIDTH  = 1;

  localparam logic [31:0] PLL_LOCKED_MASK = 32'h00000001;

  localparam logic [31:0] PLL_UNLOCKED = 32'h00000000;
  localparam logic [31:0] PLL_LOCKED   = 32'h00000001;


  // ============================================================
  // 12. SPI PROTOCOL PARAMETERS
  // ============================================================

  localparam int SPI_FRAME_WIDTH = 40;

  localparam int SPI_RWB_BIT  = 39;
  localparam int SPI_ADDR_MSB = 38;
  localparam int SPI_ADDR_LSB = 33;
  localparam int SPI_RSV_BIT  = 32;

  localparam int SPI_DATA_MSB = 31;
  localparam int SPI_DATA_LSB = 0;

  localparam logic SPI_WRITE = 1'b0;
  localparam logic SPI_READ  = 1'b1;

  localparam logic SPI_RSV_VALUE = 1'b0;

  localparam int SPI_MAX_FREQ_MHZ = 25;


  // ============================================================
  // 13. CLOCK AND PLL PARAMETERS
  // ============================================================

  localparam int CLK_REF_FREQ_GHZ = 2;

  localparam int PLL_DIV1_FREQ_MHZ = 2000;
  localparam int PLL_DIV2_FREQ_MHZ = 1000;
  localparam int PLL_DIV4_FREQ_MHZ = 500;
  localparam int PLL_DIV8_FREQ_MHZ = 250;

  localparam int MEM_MAX_FREQ_MHZ = 200;


  // ============================================================
  // 14. MEMORY PARAMETERS
  // ============================================================

  localparam logic [MEM_ADDR_WIDTH-1:0] MEM_ADDR_MIN = 10'd0;
  localparam logic [MEM_ADDR_WIDTH-1:0] MEM_ADDR_MAX = 10'd1023;

  localparam int MEM_BLOCK_CAPACITY = 256;

  localparam int MEM_WORD0_OFFSET = 0;
  localparam int MEM_WORD1_OFFSET = 1;
  localparam int MEM_WORD2_OFFSET = 2;
  localparam int MEM_WORD3_OFFSET = 3;


  // ============================================================
  // 15. MEMORY OWNERSHIP
  // ============================================================

  localparam logic MEM_OWNER_EXTERNAL = 1'b0;
  localparam logic MEM_OWNER_AES      = 1'b1;


  // ============================================================
  // 16. AES OPERATION PARAMETERS
  // ============================================================

  localparam int AES_ROUNDS = 10;

  localparam logic AES_OPERATION_ENCRYPT = 1'b0;
  localparam logic AES_OPERATION_DECRYPT = 1'b1;


  // ============================================================
  // 17. RESERVED VALUES
  // ============================================================

  localparam logic [2:0] AES_MODE_RESERVED_6 = 3'b110;
  localparam logic [2:0] AES_MODE_RESERVED_7 = 3'b111;

endpackage
