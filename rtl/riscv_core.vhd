library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_package.all;

entity riscv_core is
	generic(
		addr_width  : integer := 8; -- required bits to store 16 elements
      data_width : integer := 32; -- each element has 7-bits
		user_addr_width : integer := 32;
		user_ram_addr_width : integer := 8
   );
	port(
		clk		: in	std_logic;
		reset 	: in 	std_logic;
		uart_tx 	: out std_logic;
		uart_rx 	: in std_logic;
		led		: out std_logic_vector(7 downto 0)
	);
end entity;


architecture rtl of riscv_core is

-- regfile
signal wa : std_logic_vector(4 downto 0);
signal wd : std_logic_vector(data_width-1 downto 0);
signal we : std_logic;
signal rs1: std_logic_vector(4 downto 0);
signal rs2: std_logic_vector(4 downto 0);
signal rd1: std_logic_vector(data_width-1 downto 0);
signal rd2: std_logic_vector(data_width-1 downto 0);

-- instruction ROM
signal instruction_address : std_logic_vector(addr_width+1 downto 0); -- aka current Program Counter in register
signal program_counter 		: std_logic_vector(addr_width+1 downto 0); -- next instruction address
signal instruction_data 	: std_logic_vector(data_width-1 downto 0);

-- instruction decoder
signal imm		: std_logic_vector(data_width-1 downto 0);	-- immediate value
signal rd		: std_logic_vector(4 downto 0);					-- destination register
signal funct3	: std_logic_vector(2 downto 0);					-- holds value of funct3
signal funct7	: std_logic_vector(6 downto 0);					-- holds value of funct7
signal opcode	: std_logic_vector(6 downto 0);					-- operation code

-- control signal creation from decoded instructions
signal imm_mux	: 	std_logic;
signal alu_sel	:  std_logic;	-- 
signal imm_sel	:  std_logic;	-- 
signal pc_sel	:  std_logic;	-- 
signal jal_sel	:  std_logic;
signal jalr_sel	:  std_logic;
signal branch_sel	:  std_logic;
signal load_sel 	:  std_logic;
signal store_sel 	:  std_logic;

-- alu inputs and outputs
signal muxed_rd1_pc	: std_logic_vector(data_width-1 downto 0);
signal muxed_rd2_imm	: std_logic_vector(data_width-1 downto 0);	
signal alu_R			: std_logic_vector(data_width-1 downto 0); 

-- branch logic
signal branch : std_logic;

-- data address space
signal memory_address : std_logic_vector(user_addr_width -1 downto 0);
signal memory_data : std_logic_vector(data_width -1 downto 0);
signal mem_byte_enable : std_logic_vector(data_width/8 -1 downto 0);
signal mem_data_o : std_logic_vector(data_width -1 downto 0);

signal memory_we	: std_logic;
signal uart_we		: std_logic;
signal led_we		: std_logic;
signal ram_data	: std_logic_vector(data_width-1 downto 0);
signal uart_data	: std_logic_vector(data_width-1 downto 0);
signal uart_data_b	: std_logic_vector(7 downto 0);

signal ram_data_shift : std_logic_vector(data_width-1 downto 0);

signal clk_1, clk_2, clk_3, locked : std_logic;
signal reset_locked : std_logic;
signal reset_locked_del : std_logic;

component clk_split IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		c2		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
END component;

begin


	i_clk_split : clk_split
	port map
	(	
		areset => '0',
		inclk0 => clk,
		c0     => clk_1,
		c1     => clk_2,
		c2     => clk_3,
		locked => locked
	);

	reset_locked <= reset or (not locked);
	
	i_regfile : entity work.riscv_regfile
   generic map(
        data_width => data_width,
		address_width => user_addr_width,
		stack_pointer_adress => x"01000200"
	)
	port map(
		clk   => clk_3,	-- last stage, write back
		reset => reset_locked_del,
		wa		=> wa,
		wd		=> wd,
		we		=> we,
		rs1	=> rs1,
		rs2	=> rs2,
		rd1	=> rd1,
		rd2	=> rd2
	);
	
	wa <= rd;	-- write address is destination register of decoder
	
	process(all)	-- write data and write enable, depending on operation
	begin
		wd <= (others => '0');
		wd(addr_width+1 downto 0) <=  program_counter;
		we <= '0';
		if(alu_sel = '1' or pc_sel = '1')then
			wd <= alu_R;
			we <= '1';
		end if;
		if(imm_sel = '1')then
			wd <= imm;
			we <= '1';
		end if;
		if(jal_sel = '1' or jalr_sel = '1')then
			wd(addr_width+1 downto 0)  <= std_logic_vector(unsigned(instruction_address) + (to_unsigned(4,program_counter'length)));
			we <= '1';
		end if;
		if(load_sel = '1')then
			wd <= memory_data;
			we <= '1';
		end if;
	end process;
	
	i_instrROM : entity work.ROM
   generic map(
		addr_width => addr_width,
		data_width => data_width
	)
	port map(
		clk  => clk_1,	-- get instruciton data in first cycle after update of program counter
		addr => instruction_address(addr_width+1 downto 2),	-- try with cutting off bits, always making 32 bit aligned
		data => instruction_data
	);
	
	i_decoder: entity work.riscv_decoder
	generic map(
		data_width => data_width
	)
	port map(		
		instruction_in => instruction_data,
		imm		=> imm,
		rd			=> rd,	
		rs1 		=> rs1,
		rs2 		=> rs2,
		funct3	=> funct3,
		funct7	=> funct7,
		opcode   => opcode
	);
	
	i_ctrl: entity work.riscv_control
	generic map(
		data_width => data_width
	)
	port map(		
		opcode   	=> opcode,
		imm_mux  	=> imm_mux,
		alu_sel 		=> alu_sel,	-- 
		imm_sel 		=> imm_sel,	-- 
		pc_sel  		=> pc_sel,	-- 
		jal_sel 		=> jal_sel,
		jalr_sel 	=> jalr_sel,
		branch_sel 	=> branch_sel,
		load_sel 	=> load_sel,
		store_sel 	=> store_sel
	);	
	
	i_alu : entity work.riscv_alu
	generic map(
		data_width => data_width
	)
	port map(
		A			=> muxed_rd1_pc,
		B			=> muxed_rd2_imm,	
		funct3	=> funct3,
		funct7	=> funct7,
		R			=> alu_R
	);
	
	i_branch : entity work.riscv_branch
	generic map(
		data_width => data_width
	)
	port map(
		A			=> rd1,
		B			=> rd2,	
		IMM		=> imm,
		funct3	=> funct3,
		branch 	=> branch
	);
	
	i_mem_dec: entity work.riscv_memory_decoder 
	generic map(
		data_width => data_width
	)
	port map(
		load			=> load_sel,
		store			=> store_sel,
		funct3		=> funct3,
		byteenable  => mem_byte_enable,
		mem_data_i 	=> mem_data_o,
		mem_data_o 	=> memory_data
	);

	i_add_dec: entity work.riscv_address_decoder
	generic map(
		addr_width => user_addr_width,
		data_width => data_width
	)
	port map(
		address		=> rd1,
		offset		=> imm,
		store			=> store_sel,
		memory_we	=> memory_we,
		uart_we     => uart_we,
		led_we      => led_we,
		load			=> load_sel,
		memory_data => ram_data,--_shift,
		uart_data 	=> uart_data,
		data_out    => mem_data_o,
		full_addr   => memory_address
	);
	
	process(clk_2)
	begin
		if(rising_edge(clk_2))then
			if(led_we = '1')then
				led <= rd2(7 downto 0);
			end if;
		end if;
	end process;
	
	uart_data(data_width-1 downto 8) <= (others => '0');
	uart_data(7 downto 0) <=  uart_data_b;
	
	i_uart : entity work.uart
	generic map(
		CLK_FREQ => 12e6,
		USE_PARITY => false
	)
	port map(
		CLK		=> clk_2,
		RESET		=> reset_locked,
		DATA_W   => rd2(7 downto 0),
		WEN	   => uart_we,
		DATA_RD  => uart_data_b,
		UART_TX  => UART_TX,
		UART_RX  => UART_RX
	);
	
	--clk_ram <= not clk;
	
	i_user_ram : entity work.riscv_user_ram
	generic map(
		ADDR_WIDTH => user_ram_addr_width,
		BYTES 	  => data_width/8
	)
	port map(
		clk			=> clk_2,	-- get values from RAM in phase 2
		we 			=> memory_we,
		be    		=> mem_byte_enable,
		wdata 		=> rd2,
		addr  		=> memory_address(user_ram_addr_width+1 downto 0),	-- we are again 4-byte aligned!
		q     		=> ram_data
	);
		
--	process(ram_data, funct3, memory_address) -- shifting ram_data down for unaligned access!
--	begin
--	ram_data_shift	<= (others => '0');
--	if((funct3 = funct3_lbu_c) or (funct3 = funct3_lb_c))then
--		if memory_address(1 downto 0) = "00" then
--			ram_data_shift <= ram_data;
--		elsif memory_address(1 downto 0) = "01" then
--			ram_data_shift(23 downto 0) <= ram_data(31 downto 8);
--		elsif memory_address(1 downto 0) = "10" then
--			ram_data_shift(15 downto 0) <= ram_data(31 downto 16);
--		elsif memory_address(1 downto 0) = "11" then
--			ram_data_shift(7 downto 0) <= ram_data(31 downto 24);
--		else
--			ram_data_shift <= ram_data;
--		end if;
--	else
--		ram_data_shift <= ram_data;	
--	end if;
--	end process;
		
	process(all)
	begin
		muxed_rd2_imm <= rd2;
		if(imm_mux = '1')then
			muxed_rd2_imm <= imm;
		end if;
	end process;
	
	process(all)
	begin
		muxed_rd1_pc <= rd1;
		if(pc_sel = '1')then
			muxed_rd1_pc <= (others => '0');
			muxed_rd1_pc(addr_width+1 downto 0) <= instruction_address;
		end if;
	end process;
	
	process(clk)
	begin
		if(rising_edge(clk))then
			instruction_address <= program_counter;
			reset_locked_del <= reset_locked;
		end if;
	end process;
	
	process(all)
	begin
		program_counter <= std_logic_vector(unsigned(instruction_address) + (to_unsigned(4,program_counter'length))); 
		if jal_sel = '1' then
			program_counter <= std_logic_vector(signed(instruction_address) + signed(imm(program_counter'length-1 downto 0))); 
		end if;
		if jalr_sel = '1' then
			program_counter <= std_logic_vector(signed(rd1(program_counter'length-1 downto 0)) + signed(imm(program_counter'length-1 downto 0))); 
			program_counter(0) <= '0';
		end if;
		if branch_sel = '1' and branch = '1' then
			program_counter <= std_logic_vector(signed(instruction_address) + signed(imm(program_counter'length-1 downto 0))); 
		end if;
		if reset_locked_del = '1' or reset_locked = '1' then
			program_counter <= (others => '0');
		end if;
	end process;

end rtl;
