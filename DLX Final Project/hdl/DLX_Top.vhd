library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity DLX_Top is
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
		GPIO : inout std_logic_vector(35 downto 0);
		LEDR : out std_logic_vector(9 downto 0)
	);
end DLX_Top;

architecture behave of DLX_Top is
	signal clk_sys : std_logic;
	signal clk_io : std_logic;
	signal rstn_btn : std_logic;
	-- uart signals
	signal tx_busy : std_logic;
	signal rx_pin : std_logic;
	signal tx_pin : std_logic;

	-- stop watch
	-- clock cycles per 100ths of a second
	constant g_clks_per_100th : natural := 100000;
	-- counter limit per segment
    constant c_counter_limit : natural := 9;
	-- interconnects
	signal timer_en : std_logic;
	signal periph_rst : std_logic;
    signal tick : std_logic;
    signal tick_hundredths : std_logic;
    signal tick_tenths : std_logic;
    signal tick_sec_ones : std_logic;
    signal tick_sec_tens : std_logic;
    signal tick_min_ones : std_logic;

begin
	PL0: entity work.PLL(syn)
	port map (
		inclk0 => MAX10_CLK1_50,
		c0	=> clk_sys,
		c1 => clk_io
	);

	WRP: entity work.DLX_Wrapper(behave)
	port map (
		clk => clk_sys,
		clk_io => clk_io,
		rstn => rstn_btn,
		periph_rst => periph_rst,
		timer_en => timer_en,
		uart_rx => rx_pin,
		tx_busy => tx_busy,
		uart_tx => tx_pin
	);
	
	rstn_btn <= KEY(0);
	rx_pin <= GPIO(0);
	GPIO(1) <= tx_pin;  -- white pin
	LEDR(0) <= tx_busy;
	LEDR(9 downto 1) <= (others => '0');
	
	-- white on top far left
	-- green on bottom far left
	-- black 6 from left on top
	
	clk_100th: entity work.Counter(behave)
	generic map (
		g_max_count => g_clks_per_100th
	)
	port map (
		clk => clk_io,
		rst => periph_rst,
		en => timer_en,
		tick => tick
	);

	ms_ones: entity work.Seg_Counter(rtl)
	generic map (
		g_max_count => c_counter_limit
	)
	port map (
		clk => clk_io,
		rst => periph_rst,
		en => tick,
		tick => tick_hundredths,
		hex => HEX0(6 downto 0)
	);

	ms_tenths: entity work.Seg_Counter(rtl)
	generic map (
		g_max_count => c_counter_limit
	)
	port map (
		clk => clk_io,
		rst => periph_rst,
		en => tick_hundredths,
		tick => tick_tenths,
		hex => HEX1(6 downto 0)
	);

	ms_hundredths: entity work.Seg_Counter(rtl)
	generic map (
		g_max_count => c_counter_limit
	)
	port map (
		clk => clk_io,
		rst => periph_rst,
		en => tick_tenths,
		tick => tick_sec_ones,
		hex => HEX2(6 downto 0)
	);

	seconds_ones: entity work.Seg_Counter(rtl)
	generic map (
		g_max_count => 5
	)
	port map (
		clk => clk_io,
		rst => periph_rst,
		en => tick_sec_ones,
		tick => tick_sec_tens,
		hex => HEX3(6 downto 0)
	);

	seconds_tens: entity work.Seg_Counter(rtl)
	generic map (
		g_max_count => c_counter_limit
	)
	port map (
		clk => clk_io,
		rst => periph_rst,
		en => tick_sec_tens,
		tick => tick_min_ones,
		hex => HEX4(6 downto 0)
	);

	minutes_ones: entity work.Seg_Counter(rtl)
	generic map (
		g_max_count => c_counter_limit
	)
	port map (
		clk => clk_io,
		rst => periph_rst,
		en => tick_min_ones,
		hex => HEX5(6 downto 0)
	);

	HEX0(7) <= '1';
	HEX1(7) <= '1';
	HEX2(7) <= '0';
	HEX3(7) <= '1';
	HEX4(7) <= '0';
	HEX5(7) <= '1';

end behave;
