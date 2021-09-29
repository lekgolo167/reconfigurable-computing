library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Random is
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
	   HEX0 : out std_logic_vector(7 downto 0);
	   HEX1 : out std_logic_vector(7 downto 0);
	   HEX2 : out std_logic_vector(7 downto 0);
	   HEX3 : out std_logic_vector(7 downto 0);
	   HEX4 : out std_logic_vector(7 downto 0);
	   HEX5 : out std_logic_vector(7 downto 0);
		KEY : in std_logic_vector(1 downto 0);
		SW : in std_logic_vector(9 downto 0);
		LEDR : out std_logic_vector(9 downto 0)
	);
end Random;

architecture behave of Random is
	
	signal en : std_logic; 
	

begin

	en <= not KEY(1);

	shift: entity work.lfsr(behave)
		port map(
			clk => MAX10_CLK1_50,
			rstn => KEY(0),
			en => en,
			switches => SW,
			HEX1 => HEX1,
			HEX0 => HEX0
		);
	
   HEX2 <= (others => '1');
   HEX3 <= (others => '1');
   HEX4 <= (others => '1');
   HEX5 <= (others => '1');
	LEDR <= (others => '0');  -- to drive the LEDs to zeros

end behave;