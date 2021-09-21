B
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
    -- output of counter to decoder
    signal value : unsigned;

    -- counter instance
    cntr: entity work.Counter(rtl)
    generic map (
        g_max_count => g_max_count
    )
    port map (
        clk => clk,
        rstn => rstn,
        en => en,
        tick => tick,
        count => value
    );

    -- decoder declaration
    type memory is array (0 to 15) of std_logic_vector( 7 downto 0);
    constant seg_decoder : memory := (x"0A", x"9B", x"42", x"00", x"88", x"23", x"24", x"FF", x"82", x"99", -- 0-9
                                        x"88", x"23", x"24", x"FF", x"82", x"99"); -- A-F
begin

    hex <= seg_decoder(value);

end rtl;