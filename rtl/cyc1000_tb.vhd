library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cyc1000_tb is
end entity;

architecture test of cyc1000_tb is

signal CLK12M	: 	std_logic := '0';
signal USER_BTN	: std_logic := '1';
signal LED		: 	std_logic_vector(7 downto 0);
signal UART_TX  : std_logic;
signal UART_RX  : std_logic := '1';

constant CLK_PERIOD : time := 83.333 ns;

begin

uut: entity work.cyc1000
generic map(
	CLK_FREQ => 12e6,
	USE_PARITY => false
)
port map(
		CLK12M	=> CLK12M,
		USER_BTN	=> USER_BTN,
		LED		=> LED,
		UART_TX  => UART_TX,
		UART_RX  => UART_RX
	);
	
UART_RX <= UART_TX;	
	
process
begin
	wait for CLK_PERIOD/2;
	CLK12M <= not CLK12M;
end process;

process
begin
	USER_BTN <= '0';
	wait for 100 ns;
	USER_BTN <= '1';
	wait;
end process;

end test;