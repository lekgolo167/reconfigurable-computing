
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		GPIO : inout std_logic_vector(35 downto 0);
		LEDR : out std_logic_vector(9 downto 0)
	);
end top;

architecture behave of top is
	signal rx_pin : std_logic;
	signal tx_pin : std_logic;
	signal data_valid : std_logic;
	signal tx_busy : std_logic;
	signal byte : std_logic_vector(7 downto 0);
begin

	UART1: entity work.uart(rtl)
		generic map (
			-- clk_freq / BAUD = clks_per_bit
			-- 50MHz / 19200 = 2604
			clks_per_bit => 2604
		)
		port map (
			clk => MAX10_CLK1_50,
			-- rx
			rx_serial => rx_pin,
			rx_data_valid => data_valid,
			rx_byte => byte,
			-- tx
			tx_serial => tx_pin,
			tx_data_valid => data_valid,
			tx_byte => byte,
			tx_busy => tx_busy
		);

	rx_pin <= GPIO(0);
	GPIO(1) <= tx_pin;
	LEDR(0) <= tx_busy;
	LEDR(9 downto 1) <= (others => '0');
	
end behave;
