library ieee, work;
use ieee.std_logic_1164.all;
use work.dlx_package.all;

entity DLX_Registers is
	port
	(
		clk			: in std_logic;
		wr_en		: in std_logic;
		wr_addr		: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		wr_data		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		rd_addr_0	: out std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		rd_addr_1	: out std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		rd_data_0	: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		rd_data_1	: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0)
	);
	
end entity;

architecture rtl of DLX_Registers is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	type memory_t is array(c_NUM_OF_REGISTERS-1 downto 0) of word_t;
	
	-- Declare the RAM signal.
	signal ram : memory_t;

begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(wr_en = '1') then
				ram(to_integer(unsigned(wr_addr))) <= wr_data;
			end if;
			
			rd_data_0 <= ram(to_integer(unsigned(rd_addr_0)));
			rd_data_1 <= ram(to_integer(unsigned(rd_addr_1)));
		end if;
	
	end process;
	
end rtl;
