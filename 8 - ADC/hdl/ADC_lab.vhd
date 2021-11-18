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
	 signal cmd_valid : std_logic := '1';
	 signal cmd_channel : std_logic_vector(4 downto 0) := "00001";
	 signal cmd_start_pack : std_logic := '1';
	 signal cmd_end_pack : std_logic := '1';
	 signal cmd_ready : std_logic := '1';
	 signal resp_valid : std_logic;
	 signal resp_channel : std_logic_vector(4 downto 0);
	 signal resp_data : std_logic_vector(11 downto 0);
	 signal resp_start_pack : std_logic;
	 signal resp_end_pack : std_logic;
	 signal counter : natural;
	 signal adc_voltage_reading : std_logic_vector(11 downto 0);

begin

p_sample : process (adc_clk)
	begin
		if rising_edge(adc_clk) then
			if resp_valid = '1' then
				adc_voltage_reading <= resp_data;
			end if;
		end if;
	end process;
	
p_one_hz : process (adc_clk)
begin
	if rising_edge(adc_clk) then
		if rstn_btn = '0' then
			adc_voltage <= adc_voltage;
		elsif counter >= (10000000 - 1) then
			counter <= 0;
			adc_voltage <= adc_voltage_reading;
		else
			counter <= counter + 1;
		end if;
	end if;
end process;

PL0: entity work.PLL(syn)
	port map (
		inclk0 => ADC_CLK_10,
		c0	=> adc_clk,
		locked => lock
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
	 
adc_0 : entity work.adc(rtl)
	port map (
		clock_clk              => ADC_CLK_10,
		reset_sink_reset_n     => rstn_btn,
		adc_pll_clock_clk      => adc_clk,
		adc_pll_locked_export  => lock,
		command_valid          => cmd_valid,
		command_channel        => cmd_channel,
		command_startofpacket  => cmd_start_pack,
		command_endofpacket    => cmd_end_pack,
		command_ready          => cmd_ready,
		response_valid         => resp_valid,
		response_channel       => resp_channel,
		response_data          => resp_data,
		response_startofpacket => resp_start_pack,
		response_endofpacket   => resp_end_pack
	);

end behave;
