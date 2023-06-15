library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_package.all;

entity riscv_control is
	generic(
      data_width : integer := 32 -- each element has 7-bits
   );
	port(
		opcode   	: in std_logic_vector(6 downto 0);
		imm_mux  	: out	std_logic;
		alu_sel 		: out std_logic;	-- 
		imm_sel 		: out std_logic;	-- 
		pc_sel  		: out std_logic;	-- 
		jal_sel 		: out std_logic;
		jalr_sel 	: out std_logic;
		branch_sel 	: out std_logic;
		load_sel 	: out std_logic;
		store_sel 	: out std_logic
	);
end entity;

architecture rtl of riscv_control is

begin 

process(all)
begin
	-- default assignments
	imm_mux <= '0';	-- use rd2
	alu_sel <= '0';	-- 
	imm_sel <= '0';	-- 
	pc_sel  <= '0';	-- 
	jal_sel <= '0';
	jalr_sel <= '0';
	branch_sel <= '0';
	load_sel <= '0';
	store_sel <= '0';
	
	case opcode	is
	
		when opcode_alui_c =>
			imm_mux	<= '1';
			alu_sel	<= '1';
				
		when opcode_alu_c  =>	
			alu_sel	<= '1';	
		
		when opcode_lui_c =>
			imm_sel	<= '1';
		
		when opcode_auipc_c =>
			pc_sel	<= '1';
		
		when opcode_jal_c =>
			jal_sel  <= '1';
		
		when  opcode_jalr_c =>
			jalr_sel <= '1';
		
		when opcode_branch_c =>
			branch_sel <= '1';
		
		when opcode_load_c =>
			load_sel  	<= '1';
		
		when opcode_store_c =>
			store_sel 	<= '1';
		
		when others =>
			NULL;
			
	end case;
		
end process;

end rtl;