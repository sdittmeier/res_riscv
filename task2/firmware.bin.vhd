-- template for a simple unpipelined ROM

-- V. 1.0

-- ports:
    -- addr             : address input port (addr_width bits wide)
    -- data             : data output (data_width bits wide)
    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
    generic(
        addr_width  : integer := 8; -- required bits to store 16 elements
        data_width : integer := 32 -- each element has 7-bits
        );
port(
    clk  : in std_logic;
    addr : in std_logic_vector(addr_width-1 downto 0);
    data : out std_logic_vector(data_width-1 downto 0)
);
end ROM;

architecture ROM_arch of ROM is
  type rom_type is array (0 to 2**addr_width-1) of std_logic_vector(data_width-1 downto 0);
  signal ROM_array : rom_type := (
	
--init_data
x"00000093",
x"00000193",
x"00000213",
x"00000293",
x"00000313",
x"00000393",
x"00000413",
x"00000493",
x"00000513",
x"00000593",
x"00000613",
x"00000693",
x"00000713",
x"00000793",
x"00000813",
x"00000893",
x"00000913",
x"00000993",
x"00000a13",
x"00000a93",
x"00000b13",
x"00000b93",
x"00000c13",
x"00000c93",
x"00000d13",
x"00000d93",
x"00000e13",
x"00000e93",
x"00000f13",
x"00000f93",
x"02000537",
x"0aa00593",
x"00b52023",
x"0f0000ef",
x"0000006f",
x"fe010113",
x"00112e23",
x"00812c23",
x"02010413",
x"00050793",
x"fef407a3",
x"fef44703",
x"00a00793",
x"00f71663",
x"00d00513",
x"fd9ff0ef",
x"020007b7",
x"00878793",
x"fef44703",
x"00e7a023",
x"00000013",
x"01c12083",
x"01812403",
x"02010113",
x"00008067",
x"fe010113",
x"00112e23",
x"00812c23",
x"02010413",
x"fea42623",
x"01c0006f",
x"fec42783",
x"00178713",
x"fee42623",
x"0007c783",
x"00078513",
x"f85ff0ef",
x"fec42783",
x"0007c783",
x"fe0790e3",
x"00000013",
x"00000013",
x"01c12083",
x"01812403",
x"02010113",
x"00008067",
x"fe010113",
x"00812e23",
x"02010413",
x"fe042623",
x"0100006f",
x"fec42783",
x"00178793",
x"fef42623",
x"fec42703",
x"00b727b7",
x"aff78793",
x"fee7d4e3",
x"00000013",
x"00000013",
x"01c12403",
x"02010113",
x"00008067",
x"fe010113",
x"00112e23",
x"00812c23",
x"02010413",
x"020007b7",
x"00478793",
x"00001737",
x"45870713",
x"00e7a023",
x"6c6c67b7",
x"54878793",
x"fef42223",
x"6f7727b7",
x"06f78793",
x"fef42423",
x"006477b7",
x"c7278793",
x"fef42623",
x"020007b7",
x"0ff00713",
x"00e7a023",
x"fe440793",
x"00078513",
x"f0dff0ef",
x"f5dff0ef",
x"020007b7",
x"0007a023",
x"f51ff0ef",
x"fd9ff06f",
--init_data
	
  others => (others=>'0')  -- we add a dummy entry to leave out the stupid ',' for the last item
  );

begin

	process(clk)
	begin
		if(rising_edge(clk))then
			data <= ROM_array(to_integer(unsigned(addr)));
		end if;
	end process;	
	
end ROM_arch; 
