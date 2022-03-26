library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity DLX_Top is
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		GPIO : inout std_logic_vector(35 downto 0);
		LEDR : out std_logic_vector(9 downto 0)
	);
end DLX_Top;

architecture behave of DLX_Top is
	signal rstn_btn : std_logic;
	-- uart signals
	signal tx_busy : std_logic;
	signal rx_pin : std_logic;
	signal tx_pin : std_logic;

begin

	WRP: entity work.DLX_Wrapper(behave)
	port map (
		clk => ADC_CLK_10,
		rstn => rstn_btn,
		uart_rx => rx_pin,
		tx_busy => tx_busy,
		uart_tx => tx_pin
	);
	
	rstn_btn <= KEY(0);
	rx_pin <= GPIO(0);
	GPIO(1) <= tx_pin;  -- white pin
	LEDR(0) <= tx_busy;
	LEDR(9 downto 1) <= (others => '0');
	
	-- white on top far left
	-- green on bottom far left
	-- black 6 from left on top
	
end behave;
