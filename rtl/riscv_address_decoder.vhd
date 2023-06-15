library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity riscv_address_decoder is
generic(
	addr_width : positive := 32;
	data_width : positive := 32);
port(
	address		: in std_logic_vector(addr_width-1 downto 0);
	offset		: in std_logic_vector(addr_width-1 downto 0);
	store			: in std_logic;
	memory_we	: out std_logic;
	uart_we     : out std_logic;
	led_we      : out std_logic;
	load			: in std_logic;
	memory_data : in std_logic_vector(data_width-1 downto 0);
	uart_data 	: in std_logic_vector(data_width-1 downto 0);
	data_out    : out std_logic_vector(data_width-1 downto 0);
	full_addr   : out std_logic_vector(addr_width-1 downto 0)
);
end entity riscv_address_decoder;

architecture rtl of riscv_address_decoder is

--signal full_addr : std_logic_vector(addr_width-1 downto 0);

begin

	full_addr <= std_logic_vector(signed(address) + signed(offset));

	process(all)
	begin
		memory_we 	<= '0';
		uart_we   	<= '0';
		led_we 		<= '0';
		data_out 	<= (others => '0');
		if(store = '1')then
			if(full_addr = x"02000000")then
				led_we <= '1';
			end if;
			if(full_addr = x"02000008")then
				uart_we <= '1';
			end if;
			if(full_addr(24)= '1')then
				memory_we <= '1';
			end if;
		end if;
		if(load = '1')then
			if(full_addr = x"02000008")then	-- example for reading from UART
				data_out <= uart_data;
			end if;
			if(full_addr(24)='1')then
				--if(full_addr(1 downto 0) = "00")then
					data_out <= memory_data;
				--elsif(full_addr(1 downto 0) = "01")then
				--	data_out(23 downto 0) <= memory_data(31 downto 8);
				--elsif(full_addr(1 downto 0) = "10")then
				--	data_out(15 downto 0) <= memory_data(31 downto 16);
				--elsif(full_addr(1 downto 0) = "11")then
				--	data_out(7 downto 0) <= memory_data(31 downto 24);
				--end if;
			end if;
		end if;
	end process;

end rtl;