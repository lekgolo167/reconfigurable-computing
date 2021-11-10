library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ADC_lab is
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
        ARDUINO_IO : inout std_logic_vector(15 downto 0);
        ARDUINO_RESET_N : inout std_logic;
		KEY : in std_logic_vector(1 downto 0);
		HEX0 : out std_logic_vector(7 downto 0);
        HEX1 : out std_logic_vector(7 downto 0);
        HEX2 : out std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(7 downto 0);
        HEX4 : out std_logic_vector(7 downto 0);
        HEX5 : out std_logic_vector(7 downto 0)
	);
end ADC_lab;


architecture behave of ADC_lab is

	signal rstn_btn : std_logic;
	signal adc_clk : std_logic;
    signal lock : std_logic;
    signal adc_voltage : std_logic_vector(11 downto 0);

begin

p_ : process ()
	begin
		if rising_edge() then

		end if;
	end process;

PL0: entity work.PLL(syn)
	port map (
		inclk0 => ADC_CLK_10,
		c0	=> adc_clk
	);

HX0: entity work.Seg_Decoder(rtl)
    port map (
        en => '1',
        binary => adc_voltage(3 downto 0),
        dp => '0',
        hex => HEX0
    );

HX1: entity work.Seg_Decoder(rtl)
    port map (
        en => '1',
        binary => adc_voltage(7 downto 4),
        dp => '0',
        hex => HEX1
    );

HX2: entity work.Seg_Decoder(rtl)
    port map (
        en => '1',
        binary => adc_voltage(11 downto 8),
        dp => '0',
        hex => HEX2
    );

HX3: entity work.Seg_Decoder(rtl)
    port map (
        en => '0',
        binary => "0000",
        dp => '0',
        hex => HEX3
    );

HX4: entity work.Seg_Decoder(rtl)
    port map (
        en => '0',
        binary => "0000",
        dp => '0',
        hex => HEX4
    );

HX5: entity work.Seg_Decoder(rtl)
    port map (
        en => '0',
        binary => "0000",
        dp => '0',
        hex => HEX5
    );

    rstn_btn <= KEY(0);

end behave;



















