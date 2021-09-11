library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
 
entity ten_bit_counter_tb is
end ten_bit_counter_tb;

architecture behave of ten_bit_counter_tb is

	constant c_CLK_FREQ : natural := 5;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal LEDs : std_logic_vector(9 downto 0);

begin
	-- generate clock
	clk <= not clk after 5 ns;
	
	-- device under test
	dut: entity work.DE10_LITE(rtl)
		generic map (
			-- override for simulation
			g_CLK_FREQ => c_ClK_FREQ
		)
		port map (
			ADC_CLK_10 => '0',
			MAX10_CLK1_50 => clk,
			MAX10_CLK2_50 => '0',
			KEY(0) => reset,
			KEY(1) => '0',
			LEDR => LEDs
		);
			
		p_TEST : process is
		begin
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
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
			reset <= '0';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			reset <= '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
			wait until clk = '1';
		end process;
			
end behave;