library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- not covering shifts here!

entity riscv_alu is
generic(
	data_width : positive := 32);
port(
	A			: in std_logic_vector(data_width-1 downto 0);
	B			: in std_logic_vector(data_width-1 downto 0);	
	funct3	: in std_logic_vector(2 downto 0);
	funct7	: in std_logic_vector(6 downto 0);
	R			: out std_logic_vector(data_width-1 downto 0)
);
end entity riscv_alu;

architecture rtl of riscv_alu is

signal functioncall : std_logic_vector(3 downto 0);
signal less_than_immediate : std_logic_vector(data_width-1 downto 0);
signal less_than_immediate_unsigned : std_logic_vector(data_width-1 downto 0);

begin

functioncall <= funct7(5) & funct3;

less_than_immediate <= std_logic_vector(to_unsigned(1,data_width)) when (signed(A) < signed(B)) else std_logic_vector(to_unsigned(0,data_width));
less_than_immediate_unsigned <= std_logic_vector(to_unsigned(1,data_width)) when (unsigned(A) < unsigned(B)) else std_logic_vector(to_unsigned(0,data_width));

with functioncall select R <=
	std_logic_vector(signed(A)+signed(B)) 				when "0000",	-- add	-- neorv32 uses unsigned! but I'd use signed
	std_logic_vector(signed(A)-signed(B)) 				when "1000",	-- sub	-- neorv32 uses unsigned! but I'd use signed
	less_than_immediate										when "0010",	-- 
	less_than_immediate_unsigned							when "0011",	
	A xor B          											when "0100",
	A or B          											when "0110",
	A and B          											when "0111",
	(others => '0') when others;

end rtl;
