
library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dlx_package.all;

entity DLX_Fetch is
	port (
		clk : in std_logic;
		rstn : in std_logic;
		stall : in std_logic;
		branch_taken : in std_logic;
		jump_addr : in std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
		pc_counter : out std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
		instruction : out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0)
	);
end DLX_Fetch;

architecture rtl of DLX_Fetch is
	signal r_pc_counter : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal next_pc_count : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal address : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);

begin

	p_2_TO_2_MUX : process (branch_taken, r_pc_counter, next_pc_count, jump_addr)
	begin
		if branch_taken = '1' then
			next_pc_count <= jump_addr;
		elsif stall = '1' then
			next_pc_count <= r_pc_counter;
		else
			next_pc_count <= r_pc_counter + '1';
		end if;
	end process;

	p_PC_COUNTER : process(clk)
	begin
		if rising_edge(clk) then
			if rstn = '0' then
				r_pc_counter <= (others => '0');
			elsif stall = '1' then
				r_pc_counter <= r_pc_counter;
			else
				r_pc_counter <= next_pc_count;
			end if;
		end if;
	end process;

	p_PIPELINE_REGISTER : process(clk)
	begin
		if rising_edge(clk) then
			-- if stall = '1' then
			-- 	pc_counter <= pc_counter;
			-- else
				pc_counter <= next_pc_count;
			--end if;
		end if;
	end process;

	address <= r_pc_counter when stall = '0' else r_pc_counter-'1';

	ROM: entity work.Instruction_Memory(SYN)
		port map (
			address => address,
			clock => clk,
			q => instruction
		);
		
end rtl;
