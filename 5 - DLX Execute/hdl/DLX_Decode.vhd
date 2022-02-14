library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_package.all;

entity DLX_Decode is
	port
	(
		clk				: in std_logic;
		instruction		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		wr_en			: in std_logic;
		wr_addr			: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		wr_data			: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		pc_counter  	: in std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
		operand_0		: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		operand_1		: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		immediate		: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		sel_immediate	: out std_logic;
		sel_pc      	: out std_logic;
		inst_opcode		: out std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
		wr_back_addr	: out std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		wr_back_en 		: out std_logic;
		pc_counter_padded : out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0)
	);
	
end entity;

architecture rtl of DLX_Decode is
	signal opcode : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
	signal imm : std_logic_vector(c_DLX_IMM_WIDTH-1 downto 0);
	signal imm_extended : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal rd_addr_0 : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal rd_addr_1 : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal rd_reg : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal imm_detected : std_logic;
	signal label_detected : std_logic;
	signal save_pc : std_logic;
	signal signed_inst_received : std_logic;
	signal is_write_back : std_logic;
begin
	save_pc <= '1' when (opcode >= c_DLX_JAL) else '0';
	
	label_detected <= '1' when ((opcode >= c_DLX_LW and opcode <= c_DLX_SW) or (opcode >= c_DLX_BEQZ and (opcode /= c_DLX_JR and opcode /= c_DLX_JALR))) else '0';

	imm_detected <= '1' when ((opcode >= c_DLX_ADDI and opcode <= c_DLX_SNEI) and (opcode(0) = '0')) else '0';

	signed_inst_received <= '1' when (opcode = c_DLX_ADD or opcode = c_DLX_ADDI or opcode = c_DLX_SUB or opcode = c_DLX_SUBI or 
												opcode = c_DLX_SLT or opcode = c_DLX_SLTI or opcode = c_DLX_SGT or opcode = c_DLX_SGTI or 
												opcode = c_DLX_SLE or opcode = c_DLX_SLEI or opcode = c_DLX_SGE or opcode = c_DLX_SGEI) else '0';
	is_write_back <= '1' when (opcode >= c_DLX_ADD and opcode <= c_DLX_SNEI) or (opcode = c_DLX_LW) or (opcode >= c_DLX_JAL) else '0';
		
	p_SIGN_EXTEND : process(imm)
	begin
		if (imm(c_DLX_IMM_WIDTH-1) = '1') and (signed_inst_received = '1') then -- add signed instruction check
			imm_extended <= std_logic_vector(resize(signed(imm), c_DLX_WORD_WIDTH));
		else
			imm_extended <= std_logic_vector(resize(unsigned(imm), c_DLX_WORD_WIDTH));
		end if;
	end process;

	p_PIPELINE_REGISTER : process(clk)
	begin
		if rising_edge(clk) then
			immediate <= imm_extended;
			sel_immediate <= imm_detected or label_detected;
			sel_pc <= save_pc;
			inst_opcode <= opcode;
			pc_counter_padded <= std_logic_vector(resize(unsigned(pc_counter), c_DLX_WORD_WIDTH));
			wr_back_addr <= rd_reg;
			wr_back_en <= is_write_back;
		end if;
	end process;
	
	opcode <= instruction(31 downto 31-c_DLX_OPCODE_WIDTH+1);
	rd_addr_0 <= instruction(20 downto 20-c_DLX_REG_ADDR_WIDTH+1) when (opcode /= c_DLX_BEQZ and opcode /= c_DLX_BNEZ ) else rd_reg;
	rd_addr_1 <= instruction(15 downto 15-c_DLX_REG_ADDR_WIDTH+1) when (opcode /= c_DLX_SW and opcode < c_DLX_J) else rd_reg;
	imm <= instruction(15 downto 15-c_DLX_IMM_WIDTH+1);
	rd_reg <= instruction(25 downto 25-c_DLX_REG_ADDR_WIDTH+1);

	REG: entity work.DLX_Registers(rtl)
		port map (
			clk => clk,
			wr_en => wr_en,
			wr_addr => wr_addr,
			wr_data => wr_data,
			rd_addr_0 => rd_addr_0,
			rd_addr_1 => rd_addr_1,
			rd_data_0 => operand_0,
			rd_data_1 => operand_1
		);

end rtl;
