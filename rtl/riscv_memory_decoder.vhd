library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_package.all;


entity riscv_memory_decoder is
generic(
	data_width : positive := 32);
port(
	load		: in std_logic;
	store		: in std_logic;
	funct3	: in std_logic_vector(2 downto 0);
	byteenable : out std_logic_vector((data_width/8)-1 downto 0); 
	mem_data_i : in std_logic_vector(data_width-1 downto 0);
	mem_data_o : out std_logic_vector(data_width-1 downto 0)
);
end entity riscv_memory_decoder;

architecture RTL of riscv_memory_decoder is
begin

	process(all)
	begin
		mem_data_o 	<= (others => '0');
		byteenable 	<= (others => '0');
		
		if load = '1' then
			case funct3 is
				when funct3_lb_c  => 
					mem_data_o					<=(others => mem_data_i(7));	
					mem_data_o(7 downto 0)	<= mem_data_i(7 downto 0);
				when funct3_lh_c  => 
					mem_data_o					<=(others => mem_data_i(15));	
					mem_data_o(15 downto 0)	<= mem_data_i(15 downto 0);
				when funct3_lw_c  => 
					mem_data_o	<= mem_data_i;
				when funct3_lbu_c  => 
					mem_data_o(7 downto 0)	<= mem_data_i(7 downto 0);
				when funct3_lhu_c  => 
					mem_data_o(15 downto 0)	<= mem_data_i(15 downto 0);
				when funct3_lwu_c  => 
					mem_data_o	<= mem_data_i;
				when others => 
					NULL;
			end case;
		end if;
		
		if store = '1' then
			case funct3 is
				when funct3_sb_c  => 
					byteenable(0) <= '1';
				when funct3_sh_c  => 
					byteenable(1 downto 0) <= "11";
				when funct3_sw_c  => 
					byteenable(3 downto 0) <= "1111";
				when others => 
					NULL;
			end case;
		end if;
				
	end process;

end RTL;