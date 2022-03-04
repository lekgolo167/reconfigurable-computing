library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_package.all;

entity DLX_Execute is
	port
	(
		clk				: in std_logic;
		opcode			: in std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
		wr_en			: in std_logic;
		wr_addr			: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		rs1				: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		rs2				: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		rd_mem			: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		rd_mem_data		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		

		-- ALU operand 0
		-- sel_pc      	: in std_logic;
		pc_counter		: in std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
		operand_0		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		-- ALU operand 1
		sel_immediate	: in std_logic;
		immediate		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		operand_1		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		-- Outputs
		sel_mem_alu		: out std_logic;
		mem_wr_en		: out std_logic;
		mem_data		: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		wr_back_en		: out std_logic;
		wr_back_addr	: out std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		branch_taken 	: out std_logic;
		sel_jump_link 	: out std_logic;
		pc_counter_out	: out std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
		data_out		: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0)
	);
	
end entity;

architecture rtl of DLX_Execute is
	signal alu_out	: std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal alu_in_0	: std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal alu_in_1	: std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal is_zero : std_logic;
	signal mem_en : std_logic;
	signal mem_sel : std_logic;
	signal link_sel : std_logic;
	signal data_hazard_0 : std_logic;
	signal data_hazard_1 : std_logic;
	signal data_hazard_0_0 : std_logic;
	signal data_hazard_1_1 : std_logic;
	signal rd : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal alu_piped_data	: std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
begin

	is_zero <= '1' when ((operand_0 = x"00000000") and (opcode = c_DLX_BEQZ)) or 
						((operand_0 /= x"00000000") and (opcode = c_DLX_BNEZ)) or 
						(opcode >= c_DLX_J) else '0';
	data_hazard_0 <= '1' when rs1 = rd else '0';
	data_hazard_1 <= '1' when rs2 = rd else '0';
	data_hazard_0_0 <= '1' when rs1 = rd_mem else '0';
	data_hazard_1_1 <= '1' when rs2 = rd_mem else '0';
	
	alu_in_0 <= operand_0 when data_hazard_0 = '0' and data_hazard_0_0 = '0' else alu_piped_data when data_hazard_0_0 = '0' else rd_mem_data;
	alu_in_1 <= immediate when sel_immediate = '1' else operand_1 when data_hazard_1 = '0' and data_hazard_1_1 = '0' else alu_piped_data when data_hazard_1_1 = '0' else rd_mem_data;
	mem_en <= '1' when opcode = c_DLX_SW else '0';
	mem_sel <= '1' when opcode = c_DLX_SW or opcode = c_DLX_LW else '0';
	link_sel <= '1' when opcode = c_DLX_JAL or opcode = c_DLX_JALR else '0';
	wr_back_addr <= rd;
	data_out <= alu_piped_data;

	p_PIPELINE_REGISTER : process(clk)
		begin
			if rising_edge(clk) then
				branch_taken <= is_zero;
				alu_piped_data <= alu_out;
				mem_wr_en <= mem_en;
				mem_data <= operand_1;
				wr_back_en <= wr_en;
				rd <= wr_addr;
				sel_mem_alu <= mem_sel;
				sel_jump_link <= link_sel;
				pc_counter_out <= pc_counter;
			end if;
		end process;	

	REG: entity work.DLX_ALU(rtl)
		port map (
			opcode => opcode,
			operand_0 => alu_in_0,
			operand_1 => alu_in_1,
			alu_out => alu_out
		);

end rtl;
