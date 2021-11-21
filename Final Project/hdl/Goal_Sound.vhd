
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Goal_Sound is
    generic(
        ADDR_WIDTH: integer := 2
    );
    port(
        addr: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        data: out std_logic_vector(8 downto 0)
    );
end Goal_Sound;

architecture content of Goal_Sound is
    type tune is array(0 to 2 ** ADDR_WIDTH - 1)
        of std_logic_vector(8 downto 0);
    constant GOAL: tune :=
    (
        "001011010",
        "010011010",
        "011101010",
        "000000000"
    );
begin
    data <= GOAL(conv_integer(addr));
end content;