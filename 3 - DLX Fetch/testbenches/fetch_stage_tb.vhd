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
	-- variables
	signal loop_counter : natural := 0;
	signal func_counter : natural := 0;
	signal took_jal : std_logic := '0';
	signal took_bnez : std_logic := '0';
	signal jal_counter : natural := 0;

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
			
		-- Compute 3 factorial
		p_TEST : process(clk)
		begin
		if rising_edge(clk) then
			if instruction(31 downto 26) = "101101" and took_jal = '0' then  -- if instruction == J
				jump_addr(9 downto 0) <= instruction(9 downto 0);
				branch_taken <= '1';
			elsif (instruction(31 downto 26) = "101100") and (loop_counter < 1) then  -- else if instruction == BNEZ
				jump_addr(9 downto 0) <= instruction(9 downto 0);
				branch_taken <= '1';
				took_bnez <= '1';
				loop_counter <= loop_counter + 1;
			elsif (instruction(31 downto 26) = "101011") and (func_counter >= 1) then  -- else if instruction == BEQZ
				jump_addr(9 downto 0) <= instruction(9 downto 0);
				branch_taken <= '1';
			elsif instruction(31 downto 26) = "101111" and (jal_counter < 1) then  -- else if instruction == JAL
				jump_addr(9 downto 0) <= instruction(9 downto 0);
				branch_taken <= '1';
				func_counter <= func_counter + 1;
				took_jal <= '1';
				jal_counter <= 1;
			elsif instruction(31 downto 26) = "101110" and took_bnez = '0' then  -- else if instruction == JR
				jump_addr(9 downto 0) <= "0000000011";  -- jump back to address 0x005
				branch_taken <= '1';
				loop_counter <= 0;
			else
				branch_taken <= '0';
				took_jal <= '0';
				took_bnez <= '0';
			end if;
		end if;
		end process;
		
end behave;
