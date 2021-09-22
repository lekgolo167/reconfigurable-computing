
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
        hex : out std_logic_vector(6 downto 0)
    );
end Seg_Counter;

architecture rtl of Seg_Counter is
    -- output of counter to decoder
    signal index : natural range 0 to g_max_count;

    -- decoder declaration
    type memory is array (0 to 15) of std_logic_vector(7 downto 0);
    constant seg_decoder : memory := (x"3F", x"06", x"5B", x"4F", x"66", x"6D", x"7D", x"07", x"7F", x"67", -- 0-9
                                        x"40", x"40", x"40", x"40", x"40", x"40"); -- A-F
begin
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
			count => index
    	);
    hex <= not seg_decoder(index)(6 downto 0);

end rtl;