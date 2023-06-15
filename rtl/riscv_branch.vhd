library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_package.all;


entity riscv_branch is
generic(
	data_width : positive := 32);
port(
	A			: in std_logic_vector(data_width-1 downto 0);
	B			: in std_logic_vector(data_width-1 downto 0);
	IMM		: in std_logic_vector(data_width-1 downto 0);
	funct3	: in std_logic_vector(2 downto 0);
	branch	: out std_logic
);
end entity riscv_branch;

architecture RTL of riscv_branch is

begin

	process(all)
	begin
		branch <= '0';
		case funct3 is 
			when funct3_beq_c  => 
				if (A = B) then
					branch <= '1';
				end if;
			
			when funct3_bne_c  => 
				if (A /= B) then 
					branch <= '1';
				end if;
				
			when funct3_blt_c  => 
				if (signed(A) < signed(B)) then 
					branch <= '1';
				end if;
				
			when funct3_bge_c  => 
				if (signed(A) >= signed(B)) then 
					branch <= '1';
				end if;
				
			when funct3_bltu_c => 
				if (unsigned(A) < unsigned(B)) then 
					branch <= '1';
				end if;
				
			when funct3_bgeu_c => 
				if (unsigned(A) >= unsigned(B)) then 
					branch <= '1';
				end if;
				
			when others => 
				NULL;
				
		end case;
		
	end process;

end RTL;