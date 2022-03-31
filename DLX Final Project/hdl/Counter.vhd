
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is
    generic (
        -- limit of the counter
        g_max_count : natural := 15
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        tick : out std_logic;
        count : out natural range 0 to g_max_count
    );
end Counter;

architecture rtl of Counter is
	signal sum : natural range 0 to g_max_count;
begin
    process (clk, rst) is
	begin
        if rst = '1' then --reset
            sum <= 0;
		elsif rising_edge(clk) then
			if en = '1' then
                if sum = g_max_count then
                    sum <= 0;
                    tick <= '1';
                else
                    sum <= sum + 1;
                end if;
            else
                tick <= '0';
			end if;
		end if;
    end process;
    
    count <= sum;
	 
end rtl;

architecture behave of Counter is
	signal sum : natural range 0 to g_max_count;
begin
    process (clk) is
	begin
        if rst = '1' then --reset
            sum <= 0;
		elsif rising_edge(clk) then
			if en = '1' then
                if sum = g_max_count then
                    sum <= 0;
                else
                    sum <= sum + 1;
                end if;
			end if;
		end if;
    end process;
    tick <= '1' when sum = g_max_count else '0';
    
    count <= sum;
	 
end behave;