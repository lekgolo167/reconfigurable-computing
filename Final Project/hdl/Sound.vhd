library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Sound is
	port (
		clk : in std_logic;
		obstacle : in std_logic;
		goal : in std_logic;
		paddle : in std_logic;
		wall : in std_logic;
		speaker : out std_logic
	);
end Sound;


architecture behave of Sound is

begin

	p_sound : process (clk)
	begin
		if rising_edge(clk) then

		end if;
	end process;

end behave;
