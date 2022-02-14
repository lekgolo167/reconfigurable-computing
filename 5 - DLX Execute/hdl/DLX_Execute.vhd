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
		-- ALU operand 0
		sel_pc      	: in std_logic;
		pc_counter		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
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
begin

	is_zero <= '1' when ((operand_0 = x"00000000") and (opcode = c_DLX_BEQZ)) or 
						((operand_0 /= x"00000000") and (opcode = c_DLX_BNEZ)) or 
						(opcode >= c_DLX_J) else '0';
	alu_in_0 <= pc_counter when sel_pc = '1' else operand_0;
	alu_in_1 <= immediate when sel_immediate = '1' else operand_1;
	mem_en <= '1' when opcode = c_DLX_SW else '0';
	mem_sel <= '1' when opcode = c_DLX_SW or opcode = c_DLX_LW else '0';
	
	p_PIPELINE_REGISTER : process(clk)
		begin
			if rising_edge(clk) then
				branch_taken <= is_zero;
				data_out <= alu_out;
				mem_wr_en <= mem_en;
				mem_data <= operand_1;
				wr_back_en <= wr_en;
				wr_back_addr <= wr_addr;
				sel_mem_alu <= mem_sel;
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
