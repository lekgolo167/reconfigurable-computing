library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_tb is
end UART_tb;

architecture behave of UART_tb is

	constant c_CLK_PERIOD : time := 10 ns;
	constant c_CLKS_PER_BIT : integer := 5;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal rx_serial : std_logic := '1';
	signal rx_data_valid : std_logic;
	signal rx_byte : std_logic_vector(7 downto 0);
	signal tx_serial : std_logic;
	signal tx_busy : std_logic;
	signal tx_data_valid : std_logic := '0';
	signal tx_byte : std_logic_vector(7 downto 0) := "11011001";

begin
	-- generate clock
	clk <= not clk after c_CLK_PERIOD/2;

	-- device under test
	dut: entity work.uart(rtl)
		generic map (
			clks_per_bit => c_CLKS_PER_BIT
		)
		port map (
			clk => clk,
			rx_serial => rx_serial,
			rx_data_valid => rx_data_valid,
			rx_byte => rx_byte,
			tx_serial => tx_serial,
			tx_busy => tx_busy,
			tx_data_valid => tx_data_valid,
			tx_byte => tx_byte
		);
			
		p_TEST : process is
		begin
			wait for c_CLK_PERIOD*3;   -- wait for reset off
			tx_data_valid <= '1';              -- reset off
			wait for c_CLK_PERIOD;
			tx_data_valid <= '0'; 
			wait for c_CLK_PERIOD*50;
		end process;
		
end behave;
