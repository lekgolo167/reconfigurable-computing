
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Stopwatch is
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
        HEX0 : out std_logic_vector(7 downto 0);
        HEX1 : out std_logic_vector(7 downto 0);
        HEX2 : out std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(7 downto 0);
        HEX4 : out std_logic_vector(7 downto 0);
        HEX5 : out std_logic_vector(7 downto 0);
		KEY : in std_logic_vector(1 downto 0);
		LEDR : out std_logic_vector(9 downto 0)
	);
end Stopwatch;

architecture behave of Stopwatch is
    -- clock cycles per 100ths of a second
    constant c_clks_per_100th : natural := 500000;
    -- counter limit per segment
    constant c_counter_limit : natural := 9;

    -- signals for interconnecting modules

begin
    -- instances

    clk_100th: entity work.Counter(rtl)
        generic map (
            g_max_count => c_clks_per_100th
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => KEY(1),
            tick => 
        );

    hundredths: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => ,
            tick => ,
            hex => HEX0
        );
    
    tenths: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => ,
            tick => ,
            hex => HEX1
        );

    seconds_ones: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => ,
            tick => ,
            hex => HEX2
        );

    seconds_tens: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => ,
            tick => ,
            hex => HEX3
        );

    minutes_ones: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => ,
            tick => ,
            hex => HEX4
        );

    minutes_tens: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => ,
            tick => ,
            hex => HEX5
        );

end behave;