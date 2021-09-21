
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Seg_Counter is
    generic (
        -- limit of the counter
        g_max_count : natural := 15
    );
    port (
        clk : in std_logic;
        rstn : in std_logic;
        en : in std_logic;
        tick : out std_logic;
        hex : out std_logic_vector(7 downto 0);
    );
end Seg_Counter;

architecture rtl of Seg_Counter is

end rtl;