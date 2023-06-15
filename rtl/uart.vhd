library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
	generic(
		CLK_FREQ : positive := 12e6;
		USE_PARITY : boolean := false
	);
	port(
		CLK		: in	std_logic;
		RESET		: in	std_logic;
		DATA_W   : in 	std_logic_vector(7 downto 0);
		WEN	   : in 	std_logic;
		DATA_RD  : out std_logic_vector(7 downto 0);
		UART_TX  : out std_logic;
		UART_RX  : in std_logic
	);
end entity;


architecture rtl of uart is

component uart_fifo IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;

signal btn_deb 	: std_logic;
signal baud_tick 	: std_logic;

signal tick_counter    : integer range 0 to 7 := 0;
signal busy : std_logic := '0';

type UART_states is (idle, start_bit, running, parity, stop_bit);
signal current_state : UART_states := idle;

signal even_odd : std_logic := '0';

-- below: for UART RX
constant BAUD_RATE : integer := 115200;
constant half_bit : integer := CLK_FREQ/(2*BAUD_RATE);

type UART_RX_type is (idle, wait_for_first_bit, more_bits, stopping);
signal rx_state : UART_RX_type := idle;
signal cnt_bits : integer range 0 to 8;
signal cnt_ena : std_logic;
signal rx_cnt : integer range 0 to 3*half_bit;
signal rx_dataout : std_logic_vector(7 downto 0) := x"00";
signal rx_edge : std_logic_vector (1 downto 0);

signal rdreq, empty, full : std_logic;
signal fifo_q : std_logic_vector(7 downto 0);

begin

i_fifo: uart_fifo 
	PORT MAP
	(
		clock		=> CLK,
		data		=> DATA_W,
		rdreq		=> rdreq,
		wrreq		=> WEN,
		empty		=> empty,
		full		=> full,
		q			=> fifo_q
	);

i_mod : entity work.mod_counter
	generic map
	(
	CLK_FREQ => CLK_FREQ,
	BAUD_RATE => 115200	
	)
	port map(
		CLK	=> CLK,
		TICK  => baud_tick
	);

UART_TX_proc: process(CLK)
begin
	if(rising_edge(CLK))then
				
		case current_state is
		
			when idle => 
				UART_TX			<= '1';
				tick_counter	<= 0;
				even_odd			<= '0';
				rdreq				<= '0';
				if(empty = '0' and baud_tick = '1') then
					current_state <= start_bit;
					rdreq 		  <= '1';
				end if;
				
			when start_bit =>
				rdreq	<= '0';
				if(baud_tick = '1')then
					current_state	<= running;
					UART_TX			<= '0';
				end if;
				
			when running =>
				if(baud_tick = '1')then
					UART_TX 			<= fifo_q(tick_counter);
					even_odd			<= even_odd xor fifo_q(tick_counter);	-- xor does the job
					if (tick_counter < 7) then
						tick_counter	<= tick_counter + 1;
					else
						current_state  <= parity;
					end if;
				end if;
				
			when parity =>
				if (baud_tick = '1') then
					UART_TX 			<= '1';
					if (USE_PARITY)then
						UART_TX		<= even_odd;
					end if;
					current_state 	<= stop_bit;
				end if;
				
			
			when stop_bit =>
				if (baud_tick = '1')then
					UART_TX 	<= '1';
					current_state <= idle;
				end if;			
			
			when others =>
				current_state <= idle;
				
		end case;
		
		
		if(RESET = '1')then
			current_state 	<= idle;
			UART_TX			<= '1';
			tick_counter	<= 0;
			even_odd			<= '0';
			rdreq				<= '0';
		end if;
								
	end if;
end process;


UART_RX_proc: process(CLK)
begin
	if (rising_edge(CLK))then
		rx_edge <= rx_edge(0) & UART_RX;
		
		if cnt_ena = '1' then
			rx_cnt <= rx_cnt + 1;
		else
			rx_cnt <= 0;
		end if;
		
		case rx_state is
		
			when idle =>
				cnt_ena <= '0';
				cnt_bits <= 0;
				if (rx_edge = "10")then	-- start condition!
					rx_state <= wait_for_first_bit;
					cnt_ena  <= '1';
				end if;
				
			when wait_for_first_bit =>	-- wait for full start bit to pass, then another half
				if rx_cnt = 3*half_bit -1 then
					rx_dataout <= UART_RX & rx_dataout(7 downto 1);
					rx_state   <= more_bits;
					cnt_ena <= '0';
					cnt_bits <= cnt_bits + 1;
				end if;
				
			when more_bits =>
				cnt_ena <= '1';
				if(rx_cnt = 2*half_bit - 2)then
					rx_dataout <= UART_RX & rx_dataout(7 downto 1);
					cnt_ena <= '0';
					cnt_bits <= cnt_bits + 1;
				end if;
				if (cnt_bits = 8)then
					rx_state <= stopping;
				end if;
				
			when stopping =>
				cnt_ena <= '1';
				if(rx_cnt = 2*half_bit)then
					--if(UART_RX = '1')then
						rx_state <= idle;
					--end if;
				end if;					
			
			when others => 
				rx_state <= idle;
		end case;
		
		
		if(RESET = '1')then
			rx_state 		<= idle;
			rx_edge			<= "11";
			rx_cnt			<= 0;
			cnt_ena			<= '0';
			rx_dataout		<= x"00";
			cnt_bits			<= 0;
		end if;
	end if;
end process;

DATA_RD <= rx_dataout;

end rtl;
