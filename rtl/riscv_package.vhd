library ieee;
use ieee.std_logic_1164.all;
-- copied from https://github.com/stnolting/neorv32/blob/main/rtl/core/neorv32_package.vhd
-- removed anything not required for minimal setup

package riscv_package is
-- ****************************************************************************************************************************
-- RISC-V ISA Definitions
-- ****************************************************************************************************************************

  -- RISC-V 32-Bit Instruction Word Layout --------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  constant instr_opcode_lsb_c  : natural :=  0; -- opcode bit 0
  constant instr_opcode_msb_c  : natural :=  6; -- opcode bit 6
  constant instr_rd_lsb_c      : natural :=  7; -- destination register address bit 0
  constant instr_rd_msb_c      : natural := 11; -- destination register address bit 4
  constant instr_funct3_lsb_c  : natural := 12; -- funct3 bit 0
  constant instr_funct3_msb_c  : natural := 14; -- funct3 bit 2
  constant instr_rs1_lsb_c     : natural := 15; -- source register 1 address bit 0
  constant instr_rs1_msb_c     : natural := 19; -- source register 1 address bit 4
  constant instr_rs2_lsb_c     : natural := 20; -- source register 2 address bit 0
  constant instr_rs2_msb_c     : natural := 24; -- source register 2 address bit 4
  constant instr_funct7_lsb_c  : natural := 25; -- funct7 bit 0
  constant instr_funct7_msb_c  : natural := 31; -- funct7 bit 6
  constant instr_imm12_lsb_c   : natural := 20; -- immediate12 bit 0
  constant instr_imm12_msb_c   : natural := 31; -- immediate12 bit 11
  constant instr_imm20_lsb_c   : natural := 12; -- immediate20 bit 0
  constant instr_imm20_msb_c   : natural := 31; -- immediate20 bit 21

  -- RISC-V Opcodes -------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  -- alu --
  constant opcode_alui_c   : std_logic_vector(6 downto 0) := "0010011"; -- ALU operation with immediate
  constant opcode_alu_c    : std_logic_vector(6 downto 0) := "0110011"; -- ALU operation
  constant opcode_lui_c    : std_logic_vector(6 downto 0) := "0110111"; -- load upper immediate
  constant opcode_auipc_c  : std_logic_vector(6 downto 0) := "0010111"; -- add upper immediate to PC
  -- control flow --
  constant opcode_jal_c    : std_logic_vector(6 downto 0) := "1101111"; -- jump and link
  constant opcode_jalr_c   : std_logic_vector(6 downto 0) := "1100111"; -- jump and link with register
  constant opcode_branch_c : std_logic_vector(6 downto 0) := "1100011"; -- branch
  -- memory access --
  constant opcode_load_c   : std_logic_vector(6 downto 0) := "0000011"; -- load
  constant opcode_store_c  : std_logic_vector(6 downto 0) := "0100011"; -- store
  -- floating point --
  constant opcode_fp_load_c   : std_logic_vector(6 downto 0) := "0000111"; -- load

  -- RISC-V Funct3 --------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  -- control flow --
  constant funct3_beq_c    : std_logic_vector(2 downto 0) := "000"; -- branch if equal
  constant funct3_bne_c    : std_logic_vector(2 downto 0) := "001"; -- branch if not equal
  constant funct3_blt_c    : std_logic_vector(2 downto 0) := "100"; -- branch if less than
  constant funct3_bge_c    : std_logic_vector(2 downto 0) := "101"; -- branch if greater than or equal
  constant funct3_bltu_c   : std_logic_vector(2 downto 0) := "110"; -- branch if less than (unsigned)
  constant funct3_bgeu_c   : std_logic_vector(2 downto 0) := "111"; -- branch if greater than or equal (unsigned)
  -- memory access --
  constant funct3_lb_c     : std_logic_vector(2 downto 0) := "000"; -- load byte
  constant funct3_lh_c     : std_logic_vector(2 downto 0) := "001"; -- load half word
  constant funct3_lw_c     : std_logic_vector(2 downto 0) := "010"; -- load word
  constant funct3_lbu_c    : std_logic_vector(2 downto 0) := "100"; -- load byte (unsigned)
  constant funct3_lhu_c    : std_logic_vector(2 downto 0) := "101"; -- load half word (unsigned)
  constant funct3_lwu_c    : std_logic_vector(2 downto 0) := "110"; -- load word (unsigned)
  constant funct3_sb_c     : std_logic_vector(2 downto 0) := "000"; -- store byte
  constant funct3_sh_c     : std_logic_vector(2 downto 0) := "001"; -- store half word
  constant funct3_sw_c     : std_logic_vector(2 downto 0) := "010"; -- store word
  -- alu --
  constant funct3_subadd_c : std_logic_vector(2 downto 0) := "000"; -- sub/add via funct7
  constant funct3_sll_c    : std_logic_vector(2 downto 0) := "001"; -- shift logical left
  constant funct3_slt_c    : std_logic_vector(2 downto 0) := "010"; -- set on less
  constant funct3_sltu_c   : std_logic_vector(2 downto 0) := "011"; -- set on less unsigned
  constant funct3_xor_c    : std_logic_vector(2 downto 0) := "100"; -- xor
  constant funct3_sr_c     : std_logic_vector(2 downto 0) := "101"; -- shift right via funct7
  constant funct3_or_c     : std_logic_vector(2 downto 0) := "110"; -- or
  constant funct3_and_c    : std_logic_vector(2 downto 0) := "111"; -- and
  
end riscv_package;
