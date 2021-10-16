library ieee, std;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity fsm_tb is
end fsm_tb;

architecture behave of fsm_tb is

	constant c_CLK_PERIOD : time := 10 ns;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal adder : std_logic := '1';
	signal HEX0 : std_logic_vector(7 downto 0);
	signal HEX1 : std_logic_vector(7 downto 0);
	signal HEX2 : std_logic_vector(7 downto 0);
	signal HEX3 : std_logic_vector(7 downto 0);
	signal HEX4 : std_logic_vector(7 downto 0);
	signal HEX5 : std_logic_vector(7 downto 0);
	signal SW : std_logic_vector(9 downto 0 ) := "0000000001";
	signal LEDR : std_logic_vector(9 downto 0);

begin
	-- generate clock
	clk <= not clk after c_CLK_PERIOD/2;

	-- device under test
	dut: entity work.FSM(behave)
		port map (
			ADC_CLK_10 => '0',
			MAX10_CLK1_50 => clk,
			MAX10_CLK2_50 => '0',
			KEY(0) => reset,
			KEY(1) => adder,
			SW => SW,
			HEX0 => HEX0,
			HEX1 => HEX1,
			HEX2 => HEX2,
			HEX3 => HEX3,
			HEX4 => HEX4,
			HEX5 => HEX5,
			LEDR => LEDR
		);
			
		p_TEST : process is
		begin
			wait for c_CLK_PERIOD*5;   -- wait for reset off
			reset <= '1';              -- reset off
			wait for c_CLK_PERIOD*5;
			adder <= '0';
			wait for c_CLK_PERIOD*50;
			adder <= '1';
			wait for c_CLK_PERIOD*10;
		end process;
		
end behave;
