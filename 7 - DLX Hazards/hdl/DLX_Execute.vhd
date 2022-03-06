library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_package.all;

entity DLX_Execute is
	port
	(
		clk				: in std_logic;
		opcode			: in std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
		id_ex_rd_en		: in std_logic;
		id_ex_rd		: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);

		-- data hazards
		mem_wb_opcode	: in std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
		id_ex_rs1		: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		id_ex_rs2		: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);

		mem_wb_rd		: in std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		rd_mem_data		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		lw_data		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		is_load			: in std_logic;
		
		-- ALU operand 0
		-- sel_pc      	: in std_logic;
		pc_counter		: in std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
		operand_0		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		
		-- ALU operand 1
		sel_immediate	: in std_logic;
		immediate		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		operand_1		: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		-- Outputs
		ex_mem_opcode	: out std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
		stall			: out std_logic;
		sel_mem_alu		: out std_logic;
		ex_mem_rd		: out std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
		ex_mem_rd_en	: out std_logic;
		mem_wr_en		: out std_logic;
		mem_data		: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
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
	signal reg_to_reg_alu : std_logic;
	signal data_hazard_0 : std_logic;
	signal data_hazard_1 : std_logic;
	signal data_hazard_0_0 : std_logic;
	signal data_hazard_1_1 : std_logic;
	signal alu_piped_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal fast_forward_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
begin

	is_zero <= '1' when ((operand_0 = x"00000000") and (opcode = c_DLX_BEQZ)) or 
						((operand_0 /= x"00000000") and (opcode = c_DLX_BNEZ)) or 
						(opcode >= c_DLX_J) else '0';

	reg_to_reg_alu <= '1' when sel_immediate = '0' and opcode >= c_DLX_ADD and opcode <= c_DLX_SNEI else '0';
	data_hazard_0 <= '1' when id_ex_rs1 = ex_mem_rd and opcode /= "000000" else '0';
	data_hazard_1 <= '1' when id_ex_rs2 = ex_mem_rd and reg_to_reg_alu = '1' else '0';
	data_hazard_0_0 <= '1' when id_ex_rs1 = mem_wb_rd and opcode /= "000000" else '0';
	data_hazard_1_1 <= '1' when id_ex_rs2 = mem_wb_rd and reg_to_reg_alu = '1' else '0';
	stall <= '1' when (data_hazard_0_0 = '1' or data_hazard_1_1 = '1') and is_load = '1' and reg_to_reg_alu = '1' else '0';
	--fast_forward_data <= lw_data when is_load = '1' else rd_mem_data;
	alu_in_0 <= operand_0 when data_hazard_0 = '0' and data_hazard_0_0 = '0' else alu_piped_data when data_hazard_0_0 = '0' else rd_mem_data;
	alu_in_1 <= immediate when sel_immediate = '1' else operand_1 when data_hazard_1 = '0' and data_hazard_1_1 = '0' else alu_piped_data when data_hazard_1_1 = '0' else rd_mem_data;
	
	mem_en <= '1' when opcode = c_DLX_SW else '0';
	mem_sel <= '1' when opcode = c_DLX_LW else '0';
	link_sel <= '1' when opcode = c_DLX_JAL or opcode = c_DLX_JALR else '0';
	data_out <= alu_piped_data;

	p_PIPELINE_REGISTER : process(clk)
		begin
			if rising_edge(clk) then
				-- if stalls = '1' then
				-- 	branch_taken <= branch_taken;
				-- 	alu_piped_data <= alu_piped_data;
				-- 	mem_wr_en <= mem_wr_en;
				-- 	mem_data <= mem_data;
				-- 	wr_back_en <= wr_back_en;
				-- 	rd <= rd;
				-- 	sel_mem_alu <= '0';
				-- 	sel_jump_link <= sel_jump_link;
				-- 	pc_counter_out <= pc_counter_out;
				-- else
					branch_taken <= is_zero;
					alu_piped_data <= alu_out;
					mem_wr_en <= mem_en;
					mem_data <= operand_1;
					ex_mem_rd_en <= id_ex_rd_en;
					ex_mem_rd <= id_ex_rd;
					sel_mem_alu <= mem_sel;
					sel_jump_link <= link_sel;
					pc_counter_out <= pc_counter;
					ex_mem_opcode <= opcode;
				-- end if;
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
