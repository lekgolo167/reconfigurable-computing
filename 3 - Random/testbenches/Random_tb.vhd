library ieee, std;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Random_tb is
end Random_tb;

architecture behave of Random_tb is

	constant c_CLK_PERIOD : time := 10 ns;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal gen : std_logic := '0';
	signal HEX0 : std_logic_vector(7 downto 0);
	signal HEX1 : std_logic_vector(7 downto 0);
	signal SW : std_logic_vector(9 downto 0 ) := "1000000001";

begin
	-- generate clock
	clk <= not clk after c_CLK_PERIOD/2;

	-- device under test
	dut: entity work.lfsr(behave)
		port map (
			clk => clk,
			rstn => reset,
			en => gen,
			switches => SW,
			HEX0 => HEX0,
			HEX1 => HEX1
		);
			
		p_TEST : process is
		begin
			wait for c_CLK_PERIOD*5;   -- wait for reset off
			reset <= '1';              -- reset off
			wait for c_CLK_PERIOD*5;   -- no buttons pressed
			gen <= '1';                -- gen with reset off
			SW <= "0101010101";        -- change seeds
			wait for c_CLK_PERIOD*2700; -- enough clock cycles to show all combinations
			reset <= '0';              -- gen with reset on
			wait for c_CLK_PERIOD*5;   -- reset to seed value
			reset <= '1';              -- reset off
			wait for c_CLK_PERIOD*5;   -- wait
			gen <= '0';                -- gen off and reset off
			wait for c_CLK_PERIOD*5;   -- wait, no change
		end process;

	p_PRINT : process is
		variable line_v : line;
		file out_file : text open write_mode is "output.txt";
	begin
		wait until clk = '1';
		if gen = '1' then
			-- report "RANDOM = " & to_hstring(<<signal .random_tb.dut.random_number : std_logic_vector(9 downto 0)>>(8 downto 1));
			write(line_v, to_hstring(<<signal .random_tb.dut.random_number : std_logic_vector(9 downto 0)>>(8 downto 1)));
			writeline(out_file, line_v);
		end if;
		wait until clk = '0';
	end process;
		
end behave;
