library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dlx_package.all;

entity fetch_stage_tb is
end fetch_stage_tb;

architecture behave of fetch_stage_tb is

	constant c_CLK_PERIOD : time := 10 ns;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	-- inputs
	signal branch_taken : std_logic := '0';
	signal jump_addr : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0) := (others => '0');
	-- outputs
	signal pc_counter : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal instruction : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);

begin
	-- generate clock
	clk <= not clk after c_CLK_PERIOD/2;
	reset <= '1' after c_CLK_PERIOD*4;

	-- device under test
	dut: entity work.DLX_Fetch(rtl)
		port map (
			clk => clk,
			rstn => reset,
			branch_taken => branch_taken,
			jump_addr => jump_addr,
			pc_counter => pc_counter,
			instruction => instruction
		);
			
		p_TEST : process(clk)
		begin
		if rising_edge(clk) then
			if instruction(31 downto 26) = "101101" or instruction(31 downto 26) = "101011" or instruction(31 downto 26) = "101100" then
				jump_addr(9 downto 0) <= instruction(9 downto 0);
				branch_taken <= '1';
			else
				branch_taken <= '0';
			end if;
		end if;
		end process;
		
end behave;
