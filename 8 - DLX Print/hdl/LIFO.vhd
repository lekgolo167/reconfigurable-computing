library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_package.all;

entity LIFO is
	generic (
		g_WIDTH : natural := 8;
		g_DEPTH : natural := 16;
	)
	port
	(
		clk			: in std_logic;
		rstn		: in std_logic;
		-- write
		full		: out std_logic;
		wr_en		: in std_logic;
		wr_data		: out std_logic_vector(g_WIDTH-1 downto 0);
		-- read
		empty		: out std_logic;
		rd_en		: in std_logic;
		rd_data		: out std_logic_vector(g_WIDTH-1 downto 0)
	);
		
	end entity;
	
architecture rtl of LIFO is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(g_WIDTH-1 downto 0);
	type memory_t is array(g_DEPTH-1 downto 0) of word_t;
	
	-- Declare the RAM signal.
	signal ram : memory_t := (others => (others => '0'));
	signal data : std_logic_vector(g_WIDTH-1 downto 0) := (others => '0');
	signal stack_pointer : integer range 0 to g_DEPTH := 0;

begin

	rd_data <= data;
	full <= '1' when stack_pointer = g_DEPTH else '0';
	empty <= '1' when stack_pointer = 0 else '0';

	process(clk, rstn)
	begin
		if rstn = '0' then
			stack_pointer <= 0;
		elsif(rising_edge(clk)) then
			if wr_en = '1' and full /= '1' then
				ram(stack_pointer) <= wr_data;
				stack_pointer <= stack_pointer + 1;
			else if rd_en = '1' and empty /= '1' then
				data <= ram(stack_pointer-1);
				stack_pointer <= stack_pointer - 1;
			end if;
		end if;
	end process;
	
end rtl;
