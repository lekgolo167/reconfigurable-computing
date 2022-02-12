library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_package.all;

entity DLX_ALU is
	port
	(
		opcode		: in std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
		operand_0	: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		operand_1	: in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		alu_out		: out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0)
	);
end entity;

architecture rtl of DLX_ALU is

begin

	process(opcode, operand_0, operand_1)
	begin
		case opcode is
			when c_DLX_NOP	 =>
				alu_out <= x"00000000";
			when c_DLX_LW	 =>
				alu_out <= operand_0 + operand_1;
			when c_DLX_SW	 =>
				alu_out <= operand_0 + operand_1;
			when c_DLX_ADD	 =>
				alu_out <= operand_0 + operand_1;
			when c_DLX_ADDI	 =>
				alu_out <= operand_0 + operand_1;
			when c_DLX_ADDU	 =>
				alu_out <= operand_0 + operand_1;
			when c_DLX_ADDUI =>
				alu_out <= operand_0 + operand_1;
			when c_DLX_SUB	 =>
				alu_out <= operand_0 - operand_1;
			when c_DLX_SUBI	 =>
				alu_out <= operand_0 - operand_1;
			when c_DLX_SUBU	 =>
				alu_out <= operand_0 - operand_1;
			when c_DLX_SUBUI =>
				alu_out <= operand_0 - operand_1;
			when c_DLX_AND	 =>
				alu_out <= operand_0 and operand_1;
			when c_DLX_ANDI	 =>
				alu_out <= operand_0 and operand_1;
			when c_DLX_OR	 =>
				alu_out <= operand_0 or operand_1;
			when c_DLX_ORI	 =>
				alu_out <= operand_0 or operand_1;
			when c_DLX_XOR	 =>
				alu_out <= operand_0 xor operand_1;
			when c_DLX_XORI	 =>
				alu_out <= operand_0 xor operand_1;
			when c_DLX_SLL	 =>
				alu_out <= shift_left(unsigned(operand_0), operand_1);
			when c_DLX_SLLI	 =>
				alu_out <= shift_left(unsigned(operand_0), operand_1);
			when c_DLX_SRL	 =>
				alu_out <= shift_right(unsigned(operand_0), operand_1);
			when c_DLX_SRLI	 =>
				alu_out <= shift_right(unsigned(operand_0), operand_1);
			when c_DLX_SRA	 =>
				alu_out <= shift_right(signed(operand_0), operand_1);
			when c_DLX_SRAI	 =>
				alu_out <= shift_right(signed(operand_0), operand_1);
			when c_DLX_SLT	 =>
				alu_out <= x"00000001" when signed(operand_0) < signed(operand_1) else x"00000000";
			when c_DLX_SLTI	 =>
				alu_out <= x"00000001" when signed(operand_0) < signed(operand_1) else x"00000000";
			when c_DLX_SLTU	 =>
				alu_out <= x"00000001" when unsigned(operand_0) < unsigned(operand_1) else x"00000000";
			when c_DLX_SLTUI =>
				alu_out <=  x"00000001" when unsigned(operand_0) < unsigned(operand_1) else x"00000000";
			when c_DLX_SGT	 =>
				alu_out <= x"00000001" when signed(operand_0) > signed(operand_1) else x"00000000";
			when c_DLX_SGTI	 =>
				alu_out <= x"00000001" when signed(operand_0) > signed(operand_1) else x"00000000";
			when c_DLX_SGTU	 =>
				alu_out <=  x"00000001" when unsigned(operand_0) > unsigned(operand_1) else x"00000000";
			when c_DLX_SGTUI =>
				alu_out <=  x"00000001" when unsigned(operand_0) > unsigned(operand_1) else x"00000000";
			when c_DLX_SLE	 =>
				alu_out <= x"00000001" when signed(operand_0) <= signed(operand_1) else x"00000000";
			when c_DLX_SLEI	 =>
				alu_out <= x"00000001" when signed(operand_0) <= signed(operand_1) else x"00000000";
			when c_DLX_SLEU	 =>
				alu_out <=  x"00000001" when unsigned(operand_0) <= unsigned(operand_1) else x"00000000";
			when c_DLX_SLEUI =>
				alu_out <=  x"00000001" when unsigned(operand_0) <= unsigned(operand_1) else x"00000000";
			when c_DLX_SGE	 =>
				alu_out <= x"00000001" when signed(operand_0) >= signed(operand_1) else x"00000000";
			when c_DLX_SGEI	 =>
				alu_out <= x"00000001" when signed(operand_0) >= signed(operand_1) else x"00000000";
			when c_DLX_SGEU	 =>
				alu_out <=  x"00000001" when unsigned(operand_0) >= unsigned(operand_1) else x"00000000";
			when c_DLX_SGEUI =>
				alu_out <=  x"00000001" when unsigned(operand_0) >= unsigned(operand_1) else x"00000000";
			when c_DLX_SEQ	 =>
				alu_out <= x"00000001" when operand_0 = operand_1 else x"00000000";
			when c_DLX_SEQI	 =>
				alu_out <= x"00000001" when operand_0 = operand_1 else x"00000000";
			when c_DLX_SNE	 =>
				alu_out <= x"00000001" when operand_0 /= operand_1 else x"00000000";
			when c_DLX_SNEI	 =>
				alu_out <= x"00000001" when operand_0 /= operand_1 else x"00000000";
			when c_DLX_BEQZ	 =>
				alu_out <= operand_1;
			when c_DLX_BNEZ	 =>
				alu_out <= operand_1;
			when c_DLX_J	 =>
				alu_out <= operand_1;
			when c_DLX_JR	 =>
				alu_out <= operand_1;
			when c_DLX_JAL	 =>
				alu_out <= operand_1;
			when c_DLX_JALR	 =>
				alu_out <= operand_1;
			when others =>
				alu_out <= x"00000000";

		end case;
	end process;
	
end rtl;
