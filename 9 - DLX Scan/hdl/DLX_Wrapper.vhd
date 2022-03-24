library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dlx_package.all;

entity DLX_Wrapper is
	
	port (
		clk : in std_logic;
		rstn : in std_logic;
		uart_rx : in std_logic;
		tx_busy : out std_logic;
		uart_tx : out std_logic
	);
end DLX_Wrapper;

architecture behave of DLX_Wrapper is

	signal branch_taken : std_logic;
	signal jump_addr : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal instruction : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal inst_opcode : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
	signal ex_mem_opcode : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);

	signal wr_en_to_execute : std_logic;
	signal wr_addr_to_execute : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal ex_mem_rd_en : std_logic;
	signal ex_mem_rd : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal wb_id_rd_en : std_logic;
	signal wb_id_rd : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal wr_back_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal clear : std_logic;
	signal invalid : std_logic;
	signal ex_mem_invalid : std_logic;

	signal rs1 : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal rs2 : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);

	signal if_id_pc : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal id_ex_pc : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal ex_mem_pc : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);

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
		clear => clear,
		if_id_pc => if_id_pc,
		instruction => instruction
	);

	DCD: entity work.DLX_Decode(rtl)
	port map (
		clk => clk,
		clear => clear,
		stall => stall,
		instruction => instruction,
		wr_en => wb_id_rd_en,
		wr_addr => wb_id_rd,
		wr_data => wr_back_data,
		if_id_pc => if_id_pc,
		invalid => invalid,
		rs1 => rs1,
		rs2 => rs2,
		operand_0 => operand_0,
		operand_1 => operand_1,
		immediate => immediate,
		sel_immediate => sel_immediate,
		inst_opcode => inst_opcode,
		wr_back_en => wr_en_to_execute,
		wr_back_addr => wr_addr_to_execute,
		id_ex_pc => id_ex_pc
	);

	EXC: entity work.DLX_Execute(rtl)
	port map (
		clk => clk,
		id_ex_invalid => invalid,
		opcode => inst_opcode,
		id_ex_rd_en => wr_en_to_execute,
		id_ex_rd => wr_addr_to_execute,
		id_ex_pc => id_ex_pc,
		id_ex_rs1 => rs1,
		id_ex_rs2 => rs2,
		mem_wb_rd => wb_id_rd,
		rd_mem_data => wr_back_data,
		operand_0 => operand_0,
		operand_1 => operand_1,
		sel_immediate => sel_immediate,
		immediate => immediate,
		stall => stall,
		ex_mem_invalid => ex_mem_invalid,
		sel_mem_alu => sel_mem_alu,
		mem_wr_en => mem_wr_en,
		mem_data => mem_data,
		ex_mem_opcode => ex_mem_opcode,
		ex_mem_rd_en => ex_mem_rd_en,
		ex_mem_rd => ex_mem_rd,
		branch_taken => branch_taken,
		sel_jump_link => sel_jump_link,
		ex_mem_pc => ex_mem_pc,
		data_out => alu_out
	);
	
	MEM: entity work.DLX_Memory_Writeback(rtl)
	port map (
		clk => clk,
		ex_mem_invalid => ex_mem_invalid,
		pc_counter => ex_mem_pc,
		sel_mem_alu => sel_mem_alu,
		sel_jump_link => sel_jump_link,
		mem_wr_en => mem_wr_en,
		mem_data => mem_data,
		ex_mem_rd_en => ex_mem_rd_en,
		ex_mem_rd => ex_mem_rd,
		alu_data => alu_out,
		wb_id_rd_en => wb_id_rd_en,
		wb_id_rd => wb_id_rd,
		wr_back_data => wr_back_data
	);
	
	PRT: entity work.DLX_Print_Scan(rtl)
	port map (
		clk => clk,
		rstn => rstn,
		invalid => ex_mem_invalid,
		uart_rx => uart_rx,
		uart_tx => uart_tx,
		tx_busy => tx_busy,
		print_data => alu_out,
		op_code => ex_mem_opcode
	);
	
end behave;
