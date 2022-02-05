library ieee;
use ieee.math_real.all;

package dlx_package is

	constant c_DLX_PC_WIDTH : integer := 10;
	constant c_DLX_WORD_WIDTH : integer := 32;
	constant c_NUM_OF_REGISTERS : integer := 32;
	constant c_DLX_REG_ADDR_WIDTH : integer := integer(ceil(log2(real(c_NUM_OF_REGISTERS))));
	constant c_DLX_IMM_WIDTH : integer := 16;
	constant c_DLX_OPCODE_WIDTH : integer := 6;
	
end package dlx_package;

package body dlx_package is

end package body dlx_package;