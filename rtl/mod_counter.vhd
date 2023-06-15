library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mod_counter is
	generic
	(
	CLK_FREQ : integer := 12e6;
	BAUD_RATE : integer := 115200
	);
	port
	(
		CLK	: in  std_logic;
		TICK  : out std_logic
	);
end mod_counter;

architecture RTL of mod_counter is

	constant start_counter : integer := CLK_FREQ/BAUD_RATE;
	signal counter : integer := start_counter;
	
begin

	process(CLK)
	begin
		if(rising_edge(CLK))then
			counter 	<= counter - 1;
			TICK		<= '0';
			if (counter = 0) then
				counter 	<= start_counter;
				TICK 		<= '1';
			end if;
		end if;
	end process;

end RTL;