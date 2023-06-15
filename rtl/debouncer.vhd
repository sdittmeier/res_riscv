library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
generic (
	CLK_FREQ 	: positive := 1000000;	-- 1MHz = 1e6
	BOUNCE_FREQ	: positive := 1000		-- 1kHz = 1e3
);
port(
	clk		: in std_logic;
	din		: in std_logic;
	dout	: out std_logic
);
end entity debouncer;

architecture rtl of debouncer is
-- number of clock cycles the signal should stay at a new level before switching the output
-- integer division, then multiply by some safety factor
constant bounce_threshold : positive := (CLK_FREQ/BOUNCE_FREQ)*2;
	
signal counter : integer range 0 to bounce_threshold := 0;

signal din_r  : std_logic := '0';	-- some initial values as we don't use a reset
signal dout_r : std_logic := '0';	-- some initial values as we don't use a reset
signal counter_ena  : std_logic := '0';

begin

dout	<= dout_r;

	process(clk)
	begin
		if(rising_edge(clk))then
			din_r <= din;				-- registering edge
			if(din_r /= din)then		-- this is an edge
				counter <= 0;			-- so we reset the counter
				counter_ena   <= '1';	-- and we enable the counter
				if(counter = 0) then	-- if counter was zero
					dout_r <= din;	-- we forward the new state to the output
				end if;
			elsif counter_ena = '1' then	-- counter is enabled
				if(counter = bounce_threshold)then	-- we reach the threshold
					counter	<= 0;			-- counter is zerod
					counter_ena <= '0';		-- and disabled
				else
					counter 	<= counter + 1;	-- counter process
				end if;
			end if;
		end if;
	end process;


end rtl;
