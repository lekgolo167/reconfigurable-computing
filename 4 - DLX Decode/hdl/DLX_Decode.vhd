library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_package.all;

entity DLX_Decode is
	port
	(
		clk			: in std_logic;
		instruction	: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		wr_en		: in std_logic;
		wr_addr		: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		wr_data		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		pc_counter  : in std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
		operand_0	: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		operand_1	: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		immediate	: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		inst_opcode	: out std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
		pc_counter_padded : out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0)
	);
	
end entity;

architecture rtl of DLX_Decode is
	signal opcode : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
	signal imm : std_logic_vector(c_DLX_IMM_WIDTH-1 downto 0);
	signal imm_extended : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal rd_addr_0 : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal rd_addr_1 : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal rd_data_0 : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal rd_data_1 : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
begin

	p_SIGN_EXTEND : process(imm)
	begin
		if imm(c_DLX_IMM_WIDTH-1) = '1' then -- add signed instruction check
			imm_extended <= std_logic_vector(resize(signed(imm), c_DLX_WORD_WIDTH));
		else
			imm_extended <= std_logic_vector(resize(unsigned(imm), c_DLX_WORD_WIDTH));
		end if;
	end process;

	p_PIPELINE_REGISTER : process(clk)
	begin
		if rising_edge(clk) then
			operand_0 <= rd_data_0;
			operand_1 <= rd_data_1;
			immediate <= imm_extended;
			inst_opcode <= opcode;
			pc_counter_padded <= std_logic_vector(resize(unsigned(pc_counter), c_DLX_WORD_WIDTH));
		end if;
	end process;
	
	opcode <= instruction(31 downto 31-c_DLX_OPCODE_WIDTH+1);
	rd_addr_0 <= instruction(25 downto 25-c_DLX_REG_ADDR_WIDTH+1);
	rd_addr_1 <= instruction(20 downto 20-c_DLX_REG_ADDR_WIDTH+1);
	imm <= instruction(15 downto 15-c_DLX_IMM_WIDTH+1);

	REG: entity work.DLX_Registers(rtl)
		port map (
			clk => clk,
			wr_en => wr_en,
			wr_addr => wr_addr,
			wr_data => wr_data,
			rd_addr_0 => rd_addr_0,
			rd_addr_1 => rd_addr_1,
			rd_data_0 => rd_data_0,
			rd_data_1 => rd_data_1
		);

end rtl;
