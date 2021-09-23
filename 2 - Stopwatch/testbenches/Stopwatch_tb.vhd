library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
 
entity Stopwatch_tb is
end Stopwatch_tb;

architecture behave of Stopwatch_tb is

	constant c_CLK_FREQ : natural := 5;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal go : std_logic := '1';
	signal HEX0 : std_logic_vector(7 downto 0);
	signal HEX1 : std_logic_vector(7 downto 0);
	signal HEX2 : std_logic_vector(7 downto 0);
	signal HEX3 : std_logic_vector(7 downto 0);
	signal HEX4 : std_logic_vector(7 downto 0);
	signal HEX5 : std_logic_vector(7 downto 0);
begin
	-- generate clock
	clk <= not clk after 5 ns;
	
	-- device under test
	dut: entity work.Stopwatch(behave)
		generic map (
			-- override for simulation
			g_clks_per_100th => c_ClK_FREQ
		)
		port map (
			ADC_CLK_10 => '0',
			MAX10_CLK1_50 => clk,
			MAX10_CLK2_50 => '0',
			KEY(0) => reset,
			KEY(1) => go,
			HEX0 => HEX0,
			HEX1 => HEX1,
			HEX2 => HEX2,
			HEX3 => HEX3,
			HEX4 => HEX4,
			HEX5 => HEX5
		);
			
		p_TEST : process is
		begin
			wait until clk = '1';  -- 3 counts of being in reset
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			
			-- hitting go and reset at the same time, releasing reset first
			reset <= '1';
			wait until clk = '1';  -- 3 counts of reset off
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			go <= '0';             -- go with reset off
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			reset <= '0';          -- go with reset on
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			reset <= '1';          -- go with reset off
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			
			-- check that go starts counting from where it left off
			go <= '1';             -- go off with reset off
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			go <= '0';             -- go on with reset off
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			
			-- having go and reset pushed at the same time, releasing go first
			reset <= '0';          -- go on with reset on
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			go <= '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			
			-- let go continue with reset off
			reset <= '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			go <= '0';
			wait for 500 ns;
		end process;
			
end behave;