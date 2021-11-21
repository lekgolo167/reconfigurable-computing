library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Paddle_Sound is
    generic(
        ADDR_WIDTH: integer := 2
    );
    port(
        addr: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        data: out std_logic_vector(8 downto 0)
    );
end Paddle_Sound;

architecture content of Paddle_Sound is
    type tune is array(0 to 2 ** ADDR_WIDTH - 1)
        of std_logic_vector(8 downto 0);
    constant PADDLE: tune :=
    (
        "100001100",
        "011010011",
        "101001010",
        "000000000"
    );
begin
    data <= PADDLE(conv_integer(addr));
end content;