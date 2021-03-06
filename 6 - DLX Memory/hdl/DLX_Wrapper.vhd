library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dlx_package.all;

entity DLX_Wrapper is
	
	port (
		clk : in std_logic;
		rstn : in std_logic;
		q : out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0)
	);
end DLX_Wrapper;

architecture behave of DLX_Wrapper is

	signal branch_taken : std_logic;
	signal jump_addr : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal instruction : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal inst_opcode : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
	
	signal wr_en_to_execute : std_logic;
	signal wr_addr_to_execute : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal wr_en_to_memory : std_logic;
	signal wr_addr_to_memory : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal wr_back_en : std_logic;
	signal wr_back_addr : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal wr_back_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);

	signal pc_to_decode : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal pc_to_execute : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal pc_to_memory : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);

	signal operand_0 : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal operand_1 : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal immediate : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);

	signal sel_immediate : std_logic;
	signal sel_jump_link : std_logic;
	signal sel_mem_alu : std_logic;

	signal mem_wr_en : std_logic;
	signal mem_addr : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal mem_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	
	signal alu_out : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);

begin

	jump_addr <= alu_out(c_DLX_PC_WIDTH-1 downto 0);

	FTCH: entity work.DLX_Fetch(rtl)
	port map (
		clk => clk,
		rstn => rstn,
		branch_taken => branch_taken,
		jump_addr => jump_addr,
		pc_counter => pc_to_decode,
		instruction => instruction
	);

	DCD: entity work.DLX_Decode(rtl)
	port map (
		clk => clk,
		instruction => instruction,
		wr_en => wr_back_en,
		wr_addr => wr_back_addr,
		wr_data => wr_back_data,
		pc_counter => pc_to_decode,
		operand_0 => operand_0,
		operand_1 => operand_1,
		immediate => immediate,
		sel_immediate => sel_immediate,
		inst_opcode => inst_opcode,
		wr_back_en => wr_en_to_execute,
		wr_back_addr => wr_addr_to_execute,
		pc_counter_padded => pc_to_execute
	);

	EXC: entity work.DLX_Execute(rtl)
	port map (
		clk => clk,
		opcode => inst_opcode,
		wr_en => wr_en_to_execute,
		wr_addr => wr_addr_to_execute,
		pc_counter => pc_to_execute,
		operand_0 => operand_0,
		sel_immediate => sel_immediate,
		immediate => immediate,
		operand_1 => operand_1,
		sel_mem_alu => sel_mem_alu,
		mem_wr_en => mem_wr_en,
		mem_data => mem_data,
		wr_back_en => wr_en_to_memory,
		wr_back_addr => wr_addr_to_memory,
		branch_taken => branch_taken,
		sel_jump_link => sel_jump_link,
		pc_counter_out => pc_to_memory,
		data_out => alu_out
	);
	
	MEM: entity work.DLX_Memory_Writeback(rtl)
	port map (
		clk => clk,
		pc_counter => pc_to_memory,
		sel_mem_alu => sel_mem_alu,
		sel_jump_link => sel_jump_link,
		mem_wr_en => mem_wr_en,
		mem_data => mem_data,
		wr_en => wr_en_to_memory,
		wr_addr => wr_addr_to_memory,
		alu_data => alu_out,
		wr_back_en => wr_back_en,
		wr_back_addr => wr_back_addr,
		wr_back_data => wr_back_data
	);
	
	q <= wr_back_data;
	
end behave;
