library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

package dlx_package is

	constant c_DLX_PC_WIDTH : integer := 10;
	constant c_DLX_MEM_ADDR_WIDTH : integer := 10;
	constant c_DLX_WORD_WIDTH : integer := 32;
	constant c_NUM_OF_REGISTERS : integer := 32;
	constant c_DLX_REG_ADDR_WIDTH : integer := integer(ceil(log2(real(c_NUM_OF_REGISTERS))));
	constant c_DLX_IMM_WIDTH : integer := 16;
	constant c_DLX_OPCODE_WIDTH : integer := 6;

	-- Instructions

	constant c_DLX_NOP		: std_logic_vector(5 downto 0) := "000000";
	constant c_DLX_TR		: std_logic_vector(5 downto 0) := "110110";
	constant c_DLX_TGO		: std_logic_vector(5 downto 0) := "110111";
	constant c_DLX_TSP		: std_logic_vector(5 downto 0) := "111000";
	constant c_DLX_LW		: std_logic_vector(5 downto 0) := "000001";
	constant c_DLX_SW		: std_logic_vector(5 downto 0) := "000010";
	constant c_DLX_ADD		: std_logic_vector(5 downto 0) := "000011";
	constant c_DLX_ADDI		: std_logic_vector(5 downto 0) := "000100";
	constant c_DLX_ADDU		: std_logic_vector(5 downto 0) := "000101";
	constant c_DLX_ADDUI	: std_logic_vector(5 downto 0) := "000110";
	constant c_DLX_SUB		: std_logic_vector(5 downto 0) := "000111";
	constant c_DLX_SUBI		: std_logic_vector(5 downto 0) := "001000";
	constant c_DLX_SUBU		: std_logic_vector(5 downto 0) := "001001";
	constant c_DLX_SUBUI	: std_logic_vector(5 downto 0) := "001010";
	constant c_DLX_AND		: std_logic_vector(5 downto 0) := "001011";
	constant c_DLX_ANDI		: std_logic_vector(5 downto 0) := "001100";
	constant c_DLX_OR		: std_logic_vector(5 downto 0) := "001101";
	constant c_DLX_ORI		: std_logic_vector(5 downto 0) := "001110";
	constant c_DLX_XOR		: std_logic_vector(5 downto 0) := "001111";
	constant c_DLX_XORI		: std_logic_vector(5 downto 0) := "010000";
	constant c_DLX_SLL		: std_logic_vector(5 downto 0) := "010001";
	constant c_DLX_SLLI		: std_logic_vector(5 downto 0) := "010010";
	constant c_DLX_SRL		: std_logic_vector(5 downto 0) := "010011";
	constant c_DLX_SRLI		: std_logic_vector(5 downto 0) := "010100";
	constant c_DLX_SRA		: std_logic_vector(5 downto 0) := "010101";
	constant c_DLX_SRAI		: std_logic_vector(5 downto 0) := "010110";
	constant c_DLX_SLT		: std_logic_vector(5 downto 0) := "010111";
	constant c_DLX_SLTI		: std_logic_vector(5 downto 0) := "011000";
	constant c_DLX_SLTU		: std_logic_vector(5 downto 0) := "011001";
	constant c_DLX_SLTUI	: std_logic_vector(5 downto 0) := "011010";
	constant c_DLX_SGT		: std_logic_vector(5 downto 0) := "011011";
	constant c_DLX_SGTI		: std_logic_vector(5 downto 0) := "011100";
	constant c_DLX_SGTU		: std_logic_vector(5 downto 0) := "011101";
	constant c_DLX_SGTUI	: std_logic_vector(5 downto 0) := "011110";
	constant c_DLX_SLE		: std_logic_vector(5 downto 0) := "011111";
	constant c_DLX_SLEI		: std_logic_vector(5 downto 0) := "100000";
	constant c_DLX_SLEU		: std_logic_vector(5 downto 0) := "100001";
	constant c_DLX_SLEUI	: std_logic_vector(5 downto 0) := "100010";
	constant c_DLX_SGE		: std_logic_vector(5 downto 0) := "100011";
	constant c_DLX_SGEI		: std_logic_vector(5 downto 0) := "100100";
	constant c_DLX_SGEU		: std_logic_vector(5 downto 0) := "100101";
	constant c_DLX_SGEUI	: std_logic_vector(5 downto 0) := "100110";
	constant c_DLX_SEQ		: std_logic_vector(5 downto 0) := "100111";
	constant c_DLX_SEQI		: std_logic_vector(5 downto 0) := "101000";
	constant c_DLX_SNE		: std_logic_vector(5 downto 0) := "101001";
	constant c_DLX_SNEI		: std_logic_vector(5 downto 0) := "101010";
	constant c_DLX_BEQZ		: std_logic_vector(5 downto 0) := "101011";
	constant c_DLX_BNEZ		: std_logic_vector(5 downto 0) := "101100";
	constant c_DLX_J		: std_logic_vector(5 downto 0) := "101101";
	constant c_DLX_JR		: std_logic_vector(5 downto 0) := "101110";
	constant c_DLX_JAL		: std_logic_vector(5 downto 0) := "101111";
	constant c_DLX_JALR		: std_logic_vector(5 downto 0) := "110000";
	constant c_DLX_PCH		: std_logic_vector(5 downto 0) := "110001";
	constant c_DLX_PD		: std_logic_vector(5 downto 0) := "110010";
	constant c_DLX_PDU		: std_logic_vector(5 downto 0) := "110011";
	constant c_DLX_GD		: std_logic_vector(5 downto 0) := "110100";
	constant c_DLX_GDU		: std_logic_vector(5 downto 0) := "110101";

end package dlx_package;

package body dlx_package is

end package body dlx_package;