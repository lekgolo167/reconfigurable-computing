library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.P.all;

entity lfsr is
	port (
		clk : in std_logic;
		rstn : in std_logic;
		en : in std_logic;
		switches : in std_logic_vector(9 downto 0);
		HEX1 : out std_logic_vector(7 downto 0);
		HEX0 : out std_logic_vector(7 downto 0)
	);
end lfsr;

architecture behave of lfsr is
	-- decoder declaration
	type memory is array (0 to 15) of std_logic_vector(7 downto 0);
	constant seg_decoder : memory := (x"3F", x"06", x"5B", x"4F", x"66", x"6D", x"7D", x"07", x"7F", x"67", -- 0-9
												 x"77", x"7C", x"39", x"5E", x"79", x"71"); -- A-F
	
	signal random_number : std_logic_vector(9 downto 0);
	signal random_bit : std_logic;
	
begin
	process (clk) is
		begin
		if rising_edge(clk) then
			if rstn = '0' then --reset
				random_number <= switches;
				random_bit <= '0';
			elsif en = '1' then
				random_bit <= random_number(1) xor random_number(4) xor random_number(6) xor random_number(9); --taps:3 6 8 9
				random_number <= random_number(8 downto 0) & random_bit;
			
			end if;
		end if;
	end process;

	HEX1 <= not seg_decoder(to_integer(unsigned(random_number(8 downto 5))));
	HEX0 <= not seg_decoder(to_integer(unsigned(random_number(4 downto 1))));

end behave;
