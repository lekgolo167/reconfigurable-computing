library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Game is
	port (
		clk : in std_logic
	);
end Game;


architecture behave of Game is

begin

	p_game : process (clk)
	begin
		if rising_edge(clk) then

		end if;
	end process;

end behave;
