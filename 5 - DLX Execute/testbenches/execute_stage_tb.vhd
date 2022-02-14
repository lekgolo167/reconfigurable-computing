library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dlx_package.all;

entity execute_stage_tb is
end execute_stage_tb;

architecture behave of execute_stage_tb is

	constant c_CLK_PERIOD : time := 10 ns;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	-- inputs for fetch
	signal branch_taken : std_logic;
	signal jump_addr : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	
	-- inputs for decode
	signal wr_en : std_logic;
	signal wr_addr : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal wr_en_1 : std_logic;
	signal wr_addr_1 : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	-- outputs for fetch/ inputs for decode
	signal pc_to_decode : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal instruction : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	
	-- outputs for decode/ inputs for execute
	signal operand_0 : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal operand_1 : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal immediate : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal sel_immediate : std_logic;
	signal sel_pc : std_logic;
	signal inst_opcode : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
	signal wr_back_en : std_logic;
	signal wr_back_addr : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal pc_to_execute : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal data_out : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal alu_out : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal write_back_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal mem_wr_en : std_logic;
	signal mem_sel : std_logic;
	signal sel_mem_alu : std_logic;
	signal mem_data_in : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal mem_data_out : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal mem : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal mem_addr : std_logic_vector(1 downto 0);
	-- Build a 2-D array type for the data memory
	subtype word_t is std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	type memory_t is array(4-1 downto 0) of word_t;
	
	-- Declare the RAM signal.
	signal data_mem : memory_t := (others => (x"00000005"));
begin
	-- generate clock
	clk <= not clk after c_CLK_PERIOD/2;
	reset <= '1' after c_CLK_PERIOD*4;
	jump_addr <= alu_out(9 downto 0);
	-- device under test
	FTCH: entity work.DLX_Fetch(rtl)
		port map (
			clk => clk,
			rstn => reset,
			branch_taken => branch_taken,
			jump_addr => jump_addr,
			pc_counter => pc_to_decode,
			instruction => instruction
		);

	DCD: entity work.DLX_Decode(rtl)
		port map (
			clk => clk,
			instruction => instruction,
			wr_en => wr_en,
			wr_addr => wr_addr,
			wr_data => write_back_data,
			pc_counter => pc_to_decode,
			operand_0 => operand_0,
			operand_1 => operand_1,
			immediate => immediate,
			sel_immediate => sel_immediate,
			sel_pc => sel_pc,
			inst_opcode => inst_opcode,
			wr_back_en => wr_back_en,
			wr_back_addr => wr_back_addr,
			pc_counter_padded => pc_to_execute
		);
	
	EXC: entity work.DLX_Execute(rtl)
		port map (
			clk => clk,
			opcode => inst_opcode,
			wr_en => wr_back_en,
			wr_addr => wr_back_addr,
			sel_pc => sel_pc,
			pc_counter => pc_to_execute,
			operand_0 => operand_0,
			sel_immediate => sel_immediate,
			immediate => immediate,
			operand_1 => operand_1,
			sel_mem_alu => mem_sel,
			mem_wr_en => mem_wr_en,
			mem_data => mem_data_in,
			wr_back_en => wr_en_1,
			wr_back_addr => wr_addr_1,
			branch_taken => branch_taken,
			data_out => alu_out
		);

	mem_addr <= alu_out(1 downto 0);

	process(clk)
	begin
	if(rising_edge(clk)) then
		if(mem_wr_en = '1') then
			data_mem(to_integer(unsigned(mem_addr))) <= mem_data_in;
		end if;
			
		mem_data_out <= data_mem(to_integer(unsigned(mem_addr)));
	end if;
	end process;

	memory_writeback_SIM : process(clk)
	begin
	if rising_edge(clk) then
		sel_mem_alu <= mem_sel;
		data_out <= alu_out;
		mem <= mem_data_out;
		wr_en <= wr_en_1;
		wr_addr <= wr_addr_1;
	end if;
	end process;

	write_back_data <= mem when sel_mem_alu = '1' else data_out;

end behave;