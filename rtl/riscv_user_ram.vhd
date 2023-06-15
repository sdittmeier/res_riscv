-- Quartus Prime VHDL Template
-- Simple Dual-Port RAM with different read/write addresses and single read/write clock
-- and with a control for writing single bytes into the memory word; byte enable

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_user_ram is
	generic (
		ADDR_WIDTH 	: natural := 8;
		BYTES 		: natural := 4);
	port (
		clk 		: in  std_logic;
		we 		: in  std_logic;
		be      	: in  std_logic_vector (BYTES - 1 downto 0);
		wdata   	: in  std_logic_vector(BYTES*8 - 1 downto 0);
		addr   	: in  std_logic_vector(ADDR_WIDTH+1 downto 0); 	-- actually need all bits!
		q       	: out std_logic_vector(BYTES*8-1 downto 0));
end riscv_user_ram;

architecture rtl of riscv_user_ram is

type addr_array is array(0 to BYTES-1) of std_logic_vector(ADDR_WIDTH-1 downto 0);
type data_array is array(0 to BYTES-1) of std_logic_vector(7 downto 0);

signal addr_cut : std_logic_vector(ADDR_WIDTH-1 downto 0);

signal addr_local 	: addr_array;
signal data_local 	: data_array;
signal q_local 		: data_array;

signal wren : std_logic_vector(BYTES-1 downto 0);

component riscv_user_ram_ip IS
	GENERIC
	(
		ADDR_WIDTH : positive := 8
	);
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;
	
begin  -- rtl

	gen_ips: for i in 0 to BYTES-1 generate
		i_ram_ip: riscv_user_ram_ip 
		GENERIC MAP
		(
			ADDR_WIDTH => ADDR_WIDTH
		)
		PORT MAP
		(
			address	=> addr_local(i),
			clock		=> clk,
			data		=> data_local(i),
			wren		=> wren(i),
			q			=> q_local(i)
		);
		
	end generate gen_ips;
		
		
	addr_cut <= addr(ADDR_WIDTH+1 downto 2);	
	process(all)
		begin
		if(addr(1 downto 0) = "00")then	-- 4 bytes aligned
			for i in 0 to BYTES-1 loop
				data_local(i) <= wdata((i+1)*8-1 downto i*8);
				wren(i) 		  <= we and be(i);
				addr_local(i) <= addr_cut;
				q((i+1)*8-1 downto i*8) <= q_local(i);
			end loop;
			
		elsif(addr(1 downto 0) = "01")then	-- misaligned 1 byte
			for i in 0 to BYTES-4 loop
				data_local(i) <= wdata((i+4)*8-1 downto (i+3)*8);
				wren(i) 		  <= we and be(i+3);
				addr_local(i) <= std_logic_vector(unsigned(addr_cut)+1);
				q((i+4)*8-1 downto (i+3)*8) <= q_local(i);
			end loop;
			for i in BYTES-3 to BYTES-1 loop
				data_local(i) <= wdata(i*8-1 downto (i-1)*8);
				wren(i) 		  <= we and be(i-1);
				addr_local(i) <= addr_cut;
				q((i)*8-1 downto (i-1)*8) <= q_local(i);
			end loop;
			
		elsif(addr(1 downto 0) = "10")then	-- misaligned 2 bytes
			for i in 0 to BYTES-3 loop
				data_local(i) <= wdata((i+3)*8-1 downto (i+2)*8);
				wren(i) 		  <= we and be(i+2);
				addr_local(i) <= std_logic_vector(unsigned(addr_cut)+1);
				q((i+3)*8-1 downto (i+2)*8) <= q_local(i);
			end loop;
			for i in BYTES-2 to BYTES-1 loop
				data_local(i) <= wdata((i-1)*8-1 downto (i-2)*8);
				wren(i) 		  <= we and be(i-2);
				addr_local(i) <= addr_cut;
				q((i-1)*8-1 downto (i-2)*8) <= q_local(i);
			end loop;
			
		elsif(addr(1 downto 0) = "11")then	-- misaligned 3 bytes
			for i in 0 to BYTES-2 loop
				data_local(i) <= wdata((i+2)*8-1 downto (i+1)*8);
				wren(i) 		  <= we and be(i+1);
				addr_local(i) <= std_logic_vector(unsigned(addr_cut)+1);
				q((i+2)*8-1 downto (i+1)*8) <= q_local(i);
			end loop;
			for i in BYTES-1 to BYTES-1 loop
				data_local(i) <= wdata((i-2)*8-1 downto (i-3)*8);
				wren(i) 		  <= we and be(i-3);
				addr_local(i) <= addr_cut;
				q((i-2)*8-1 downto (i-3)*8) <= q_local(i);
			end loop;
		else
			for i in 0 to BYTES-1 loop
				data_local(i) <= wdata((i+1)*8-1 downto i*8);
				wren(i) 		  <= we and be(i);
				addr_local(i) <= addr_cut;
				q((i+1)*8-1 downto i*8) <= q_local(i);
			end loop;
		end if;
	end process;
	
end rtl;
