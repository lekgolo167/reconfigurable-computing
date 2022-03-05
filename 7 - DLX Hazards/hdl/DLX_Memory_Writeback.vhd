library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_package.all;

entity DLX_Memory_Writeback is
	port
	(
		clk				: in std_logic;
		pc_counter		: in std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
		sel_mem_alu		: in std_logic;
		sel_jump_link 	: in std_logic;
		mem_wr_en		: in std_logic;
		mem_data		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		wr_en			: in std_logic;
		wr_addr			: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		alu_data		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		-- Outputs
		wr_back_en		: out std_logic;
		wr_back_addr	: out std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		wr_back_data	: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0)--;
		--lw_data			: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		--is_load			: out std_logic
		);
		
	end entity;
	
	architecture rtl of DLX_Memory_Writeback is
		signal mem_addr	: std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
		signal tmp	: std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		signal data	: std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		signal loaded_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		signal pc_to_writeback : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
		signal mem_sel : std_logic;
		signal link_sel : std_logic;
begin
	mem_addr <= alu_data(c_DLX_PC_WIDTH-1 downto 0);

	p_PIPELINE_REGISTER : process(clk)
		begin
			if rising_edge(clk) then
				data <= alu_data;
				wr_back_en <= wr_en;
				wr_back_addr <= wr_addr;
				mem_sel <= sel_mem_alu;
				link_sel <= sel_jump_link;
				pc_to_writeback <= pc_counter;
			end if;
		end process;	

	REG: entity work.Data_Memory(SYN)
		port map (
			clock => clk,
			address => mem_addr,
			wren => mem_wr_en,
			data => mem_data,
			q => loaded_data
		);

	-- writeback stage
	--is_load <= mem_sel;
	--lw_data <= loaded_data;
	tmp <= loaded_data when mem_sel = '1' else data;
	wr_back_data <= std_logic_vector(resize(unsigned(pc_to_writeback), c_DLX_WORD_WIDTH)) when link_sel = '1' else tmp;

end rtl;
