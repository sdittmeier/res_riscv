library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_package.all;

entity riscv_decoder is
	generic(
      data_width : integer := 32 -- each element has 7-bits
   );
	port(
		instruction_in : in std_logic_vector(data_width-1 downto 0);
		imm		: out std_logic_vector(data_width-1 downto 0);
		rd			: out std_logic_vector(4 downto 0);
		rs1 		: out std_logic_vector(4 downto 0);
		rs2 		: out std_logic_vector(4 downto 0);
		funct3	: out std_logic_vector(2 downto 0);
		funct7	: out std_logic_vector(6 downto 0);
		opcode   : out std_logic_vector(6 downto 0)
	);
end entity;

architecture rtl of riscv_decoder is

begin 

process(all)
begin
	-- default assignments
	imm <= (others => '0');
	rs1 <= (others => '0');
	rs2 <= (others => '0');
	rd <= (others => '0');
	funct7 <= (others => '0');
	funct3 <= (others => '0');
	opcode <= instruction_in(instr_opcode_msb_c downto instr_opcode_lsb_c);
	
	case instruction_in(instr_opcode_msb_c downto instr_opcode_lsb_c) is
	
		when opcode_alui_c =>
			rd			<= instruction_in(11 downto 7);
			funct3	<= instruction_in(14 downto 12);
			rs1 		<= instruction_in(19 downto 15);
--				rs2 		<= instruction_in(24 downto 20);
			imm(11 downto 0) <= instruction_in(31 downto 20);
			imm(31 downto 12) <= (others => instruction_in(31));
			--funct7	<= instruction_in(31 downto 25);	-- only needed for shift, not used here
				
		when opcode_alu_c  =>		
			rd			<= instruction_in(11 downto 7);
			funct3	<= instruction_in(14 downto 12);
			rs1 		<= instruction_in(19 downto 15);
			rs2 		<= instruction_in(24 downto 20);
			funct7	<= instruction_in(31 downto 25);	
		
		when opcode_lui_c =>
			rd			<= instruction_in(11 downto 7);
			imm(31 downto 12) <= instruction_in(31 downto 12);
		
		when opcode_auipc_c =>
			rd			<= instruction_in(11 downto 7);
			imm(31 downto 12) <= instruction_in(31 downto 12);
		
		when opcode_jal_c =>
			rd			<= instruction_in(11 downto 7);
			imm(10 downto 1) 	<= instruction_in(30 downto 21);
			imm(11) 				<= instruction_in(20);
			imm(19 downto 12) <= instruction_in(19 downto 12);
			imm(20) 				<= instruction_in(31);
			imm(31 downto 21) <= (others => instruction_in(31));
		
		when  opcode_jalr_c =>
			rd			<= instruction_in(11 downto 7);
			funct3	<= instruction_in(14 downto 12);
			rs1 		<= instruction_in(19 downto 15);
			imm(11 downto 0) <= instruction_in(31 downto 20);
			imm(31 downto 12) <= (others => instruction_in(31));
		
		when opcode_branch_c =>
			funct3	<= instruction_in(14 downto 12);
			rs1 		<= instruction_in(19 downto 15);
			rs2 		<= instruction_in(24 downto 20);
			imm(4 downto 1) 	<= instruction_in(11 downto 8);
			imm(10 downto 5) <= instruction_in(30 downto 25);
			imm(11) 				<= instruction_in(7);
			imm(12) 				<= instruction_in(31);
			imm(31 downto 13) <= (others => instruction_in(31));
		
		when opcode_load_c | opcode_fp_load_c =>
			rd			<= instruction_in(11 downto 7);
			funct3	<= instruction_in(14 downto 12);
			rs1 		<= instruction_in(19 downto 15);
			imm(11 downto 0) <= instruction_in(31 downto 20);
			imm(31 downto 12) <= (others => instruction_in(31));
		
		when opcode_store_c =>
			funct3	<= instruction_in(14 downto 12);
			rs1 		<= instruction_in(19 downto 15);
			rs2 		<= instruction_in(24 downto 20);
			imm(4 downto 0) <= instruction_in(11 downto 7);
			imm(11 downto 5) <= instruction_in(31 downto 25);
			imm(31 downto 12) <= (others => instruction_in(31));
		
		when others =>
			null;
		
	end case;
		
end process;

end rtl;