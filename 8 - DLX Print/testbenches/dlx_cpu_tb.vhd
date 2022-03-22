library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dlx_package.all;

entity dlx_cpu_tb is
end dlx_cpu_tb;

architecture behave of dlx_cpu_tb is

	constant c_CLK_PERIOD : time := 10 ns;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal tx_busy : std_logic;
	signal tx : std_logic;

begin
	-- generate clock
	clk <= not clk after c_CLK_PERIOD/2;
	reset <= '1' after c_CLK_PERIOD*10;

	-- device under test
	DLX: entity work.DLX_Wrapper(behave)
		port map (
			clk => clk,
			rstn => reset,
			uart_rx => '1',
			tx_busy => tx_busy,
			uart_tx => tx
		);

end behave;