
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Seg_Decoder is
    port (
        binary : in std_logic_vector(3 downto 0);
        dp : in std_logic;
        hex : out std_logic_vector(7 downto 0)
    );
end Seg_Decoder;

architecture rtl of Seg_Decoder is

    -- decoder declaration
    type memory is array (0 to 15) of std_logic_vector(7 downto 0);
    constant seg_decoder : memory := (x"3F", x"06", x"5B", x"4F", x"66", x"6D", x"7D", x"07", x"7F", x"67", -- 0-9
                                        x"77", x"7C", x"39", x"5E", x"79", x"71"); -- A-F
begin

    hex(6 downto 0) <= not seg_decoder(to_integer(unsigned(binary)))(6 downto 0);
    hex(7) <= not dp;

end rtl;