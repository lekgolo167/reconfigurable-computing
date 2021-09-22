
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is
    generic (
        -- limit of the counter
        g_max_count : unsigned := 15
    );
    port (
        clk : in std_logic;
        rstn : in std_logic;
        en : in std_logic;
        tick : out std_logic;
        count : out unsigned range 0 to g_max_count
    );
end Counter;

architecture rtl of Counter is

    process (clk) is
	begin
		if rising_edge(clk) then
            if rstn = '0' then --reset
                count <= (others => '0');
			elsif en = '1' then
                if count = g_max_count then
                    count <= (others => '0');
                    tick <= '1';
                else
                    count <= count + 1;
                end if;
            else
                tick <= '0';
			end if;
		end if;
	end process;
end rtl;