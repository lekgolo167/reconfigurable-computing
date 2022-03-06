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
	signal mem_wb_opcode : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
	signal ex_mem_opcode : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);

	signal wr_en_to_execute : std_logic;
	signal wr_addr_to_execute : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal wr_en_to_memory : std_logic;
	signal wr_addr_to_memory : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal wr_back_en : std_logic;
	signal wr_back_addr : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal wr_back_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal lw_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal is_load : std_logic;
	signal rs1 : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal rs2 : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);

	signal pc_to_decode : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal pc_to_execute : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal pc_to_memory : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);

	signal operand_0 : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal operand_1 : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal immediate : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);

	signal sel_immediate : std_logic;
	signal sel_jump_link : std_logic;
	signal sel_mem_alu : std_logic;
	signal stall : std_logic;

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
		stall => stall,
		branch_taken => branch_taken,
		jump_addr => jump_addr,
		pc_counter => pc_to_decode,
		instruction => instruction
	);

	DCD: entity work.DLX_Decode(rtl)
	port map (
		clk => clk,
		stall => stall,
		instruction => instruction,
		wr_en => wr_back_en,
		wr_addr => wr_back_addr,
		wr_data => wr_back_data,
		pc_counter => pc_to_decode,
		rs1 => rs1,
		rs2 => rs2,
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
		id_ex_rd_en => wr_en_to_execute,
		id_ex_rd => wr_addr_to_execute,
		pc_counter => pc_to_execute,
		id_ex_rs1 => rs1,
		id_ex_rs2 => rs2,
		mem_wb_opcode => mem_wb_opcode,
		mem_wb_rd => wr_back_addr,
		rd_mem_data => wr_back_data,
		lw_data => lw_data,
		is_load => is_load,
		operand_0 => operand_0,
		operand_1 => operand_1,
		sel_immediate => sel_immediate,
		immediate => immediate,
		stall => stall,
		ex_mem_opcode => ex_mem_opcode,
		sel_mem_alu => sel_mem_alu,
		mem_wr_en => mem_wr_en,
		mem_data => mem_data,
		ex_mem_rd_en => wr_en_to_memory,
		ex_mem_rd => wr_addr_to_memory,
		branch_taken => branch_taken,
		sel_jump_link => sel_jump_link,
		pc_counter_out => pc_to_memory,
		data_out => alu_out
	);
	
	MEM: entity work.DLX_Memory_Writeback(rtl)
	port map (
		clk => clk,
		pc_counter => pc_to_memory,
		ex_mem_opcode => ex_mem_opcode,
		sel_mem_alu => sel_mem_alu,
		sel_jump_link => sel_jump_link,
		mem_wr_en => mem_wr_en,
		mem_data => mem_data,
		wr_en => wr_en_to_memory,
		wr_addr => wr_addr_to_memory,
		alu_data => alu_out,
		wr_back_en => wr_back_en,
		wr_back_addr => wr_back_addr,
		mem_wb_opcode => mem_wb_opcode,
		lw_data => lw_data,
		is_load => is_load,
		wr_back_data => wr_back_data
	);
	
	q <= wr_back_data;
	
end behave;
