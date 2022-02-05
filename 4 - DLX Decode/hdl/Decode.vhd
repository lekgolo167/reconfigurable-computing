
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Decode is
	
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		SW : inout std_logic_vector(9 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		GPIO : inout std_logic_vector(35 downto 0)
	);
end Decode;

architecture behave of Decode is
	signal rstn_btn : std_logic;
	signal inst : std_logic_vector(31 downto 0);

begin

	FTCH: entity work.DLX_Decode(rtl)
		port map (
			clk => MAX10_CLK1_50,
			rstn => rstn_btn,
			-- inputs
			jump_addr => SW,
			branch_taken => SW(1),
			-- outputs
			pc_counter => LEDR,
			instruction => inst
		);


	rstn_btn <= SW(0);

	GPIO(31 downto 0) <= inst;
	
end behave;
