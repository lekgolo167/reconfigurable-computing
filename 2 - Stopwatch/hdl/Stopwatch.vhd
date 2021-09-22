
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Stopwatch is
    generic (
        -- clock cycles per 100ths of a second
		g_clks_per_100th : natural := 500000
	);
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
    -- counter limit per segment
    constant c_counter_limit : natural := 9;
	 
    -- signals for interconnecting modules
    signal go : std_logic;
    signal tick : std_logic;
    signal tick_hundredths : std_logic;
    signal tick_tenths : std_logic;
    signal tick_sec_ones : std_logic;
    signal tick_sec_tens : std_logic;
    signal tick_min_ones : std_logic;

begin

    go <= not KEY(1);
    -- instances

    clk_100th: entity work.Counter(behave)
        generic map (
            g_max_count => g_clks_per_100th
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => go,
            tick => tick
        );

    hundredths: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => tick,
            tick => tick_hundredths,
            hex => HEX0(6 downto 0)
        );
    
    tenths: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => tick_hundredths,
            tick => tick_tenths,
            hex => HEX1(6 downto 0)
        );

    seconds_ones: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => tick_tenths,
            tick => tick_sec_ones,
            hex => HEX2(6 downto 0)
        );

    seconds_tens: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => 5
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => tick_sec_ones,
            tick => tick_sec_tens,
            hex => HEX3(6 downto 0)
        );

    minutes_ones: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => tick_sec_tens,
            tick => tick_min_ones,
            hex => HEX4(6 downto 0)
        );

    minutes_tens: entity work.Seg_Counter(rtl)
        generic map (
            g_max_count => c_counter_limit
        )
        port map (
            clk => MAX10_CLK1_50,
            rstn => KEY(0),
            en => tick_min_ones,
            hex => HEX5(6 downto 0)
        );

    HEX0(7) <= '1';
    HEX1(7) <= '1';
    HEX2(7) <= '0';
    HEX3(7) <= '1';
    HEX4(7) <= '0';
    HEX5(7) <= '1';
    LEDR <= (others => '0');

end behave;