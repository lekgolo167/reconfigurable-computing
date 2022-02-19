
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Memory is
	
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		SW : inout std_logic_vector(9 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		GPIO : inout std_logic_vector(35 downto 0)
	);
end Memory;

architecture behave of Memory is
	signal rstn_btn : std_logic;
	signal q : std_logic_vector(31 downto 0);
	signal qq : std_logic_vector(31 downto 0);

begin

	FTCH: entity work.DLX_Wrapper(behave)
		port map (
			clk => MAX10_CLK1_50,
			rstn => rstn_btn,
			q => q
		);

	p_OUT : process(MAX10_CLK1_50)
	begin
		if rising_edge(MAX10_CLK1_50) then
			if q /= x"0000001F" and q > X"00000000" then
				qq <= q;
			end if;
		end if;
	end process;
	
	rstn_btn <= KEY(0);
	LEDR <= qq(9 downto 0);
	
end behave;
