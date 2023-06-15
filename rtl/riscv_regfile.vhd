library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_regfile is
    generic(
      data_width : integer := 32; -- each element has 7-bits
		address_width : integer := 32;
		stack_pointer_adress : std_logic_vector(31 downto 0)	-- cannot use address_width here!
        );
	port(
		clk   : in	std_logic;
		reset : in 	std_logic;
		wa		: in	std_logic_vector(4 downto 0);
		wd		: in	std_logic_vector(data_width-1 downto 0);
		we		: in 	std_logic;
		rs1	: in	std_logic_vector(4 downto 0);
		rs2	: in	std_logic_vector(4 downto 0);
		rd1	: out	std_logic_vector(data_width-1 downto 0);
		rd2	: out	std_logic_vector(data_width-1 downto 0)
	);
end entity;


architecture rtl of riscv_regfile is

	type regfile_t is array (31 downto 0) of std_logic_vector(data_width-1 downto 0);
	signal regfile : regfile_t;
	
begin

	process(all)	-- unclocked reads
	begin
		rd1 <= regfile(to_integer(unsigned(rs1)));
		rd2 <= regfile(to_integer(unsigned(rs2)));
	end process;

	process(clk)	-- clocked writes
	begin
		if(rising_edge(clk))then
			if(we = '1')then
				regfile(to_integer(unsigned(wa))) <= wd;
			end if;
			-- make sure register 0 is always 0!
			regfile(0) <= (others => '0');
			if(reset = '1')then
				regfile(2) <= stack_pointer_adress;
			end if;
		end if;
	end process;

end rtl;
