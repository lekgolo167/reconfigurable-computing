
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity DE10_LITE is
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		LEDR : out std_logic_vector(9 downto 0)
	);
end DE10_LITE;

architecture rtl of DE10_LITE is
	-- clk frequency
	constant c_50MHZ  : natural := 50000000;
	-- signal for when 1 second passes
	signal one_Hz_tick : std_logic;
	-- signal to count to 50 M
	signal one_Hz_counter : natural range 0 to c_50MHZ;
	-- seconds counter 10 bits
	signal ten_bit_counter : std_logic_vector(9 downto 0);
begin
	
	p_1_HZ : process (MAX10_CLK1_50) is
	begin
		if rising_edge(MAX10_CLK1_50) then
			if one_Hz_counter = c_50MHZ-1 then -- one second has passed
				one_Hz_counter <= 0;
				one_Hz_tick <= '1';
			else
				one_Hz_counter <= one_Hz_counter + 1;
				one_Hz_tick <= '0';
			end if;
		end if;
	end process;

	p_10_bit : process (MAX10_CLK1_50, KEY(0)) is
	begin
		if rising_edge(MAX10_CLK1_50) then
			if KEY(0) = '0' then -- reset
				ten_bit_counter <= (others => '0');
			elsif one_Hz_tick = '1' then -- increment every second
				ten_bit_counter <= ten_bit_counter + '1';
			end if; 
		end if;
	end process;

	-- connect the counter to the LEDs
	LEDR <= ten_bit_counter;
end rtl;