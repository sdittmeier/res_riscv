library ieee;
use ieee.std_logic_1164.all;

entity cyc1000 is
	generic(
		CLK_FREQ : positive := 12e6;
		USE_PARITY : boolean := false
	);
	port(
		CLK12M	: in	std_logic;
		USER_BTN	: in	std_logic;
		LED		: out	std_logic_vector(7 downto 0);
		UART_TX  : out std_logic;
		UART_RX  : in std_logic
	);
end entity;


architecture rtl of cyc1000 is

signal btn_deb 	: std_logic;
signal reset		: std_logic;


begin

i_deb: entity work.debouncer
	generic map(
		CLK_FREQ => CLK_FREQ,
		BOUNCE_FREQ => 1e3
	)
	port map
	(
		clk		=> CLK12M,
		din		=> USER_BTN,
		dout		=> btn_deb
	);

	
	reset <= not btn_deb;
	
i_rv_core : entity work.riscv_core 
	generic map(
		addr_width  =>  8, -- required bits to store 16 elements
      data_width  => 32, -- each element has 7-bits
		user_addr_width => 32
   )
	port map(
		clk		=> CLK12M,
		reset 	=> reset,
		uart_tx 	=> UART_TX,
		uart_rx 	=> UART_RX,
		led		=> LED
	);


end rtl;
