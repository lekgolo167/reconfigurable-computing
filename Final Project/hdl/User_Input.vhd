library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity User_Input is
	port (
		adc_clk : in std_logic;
		adc_pll_clk : in std_logic;
		vga_clk : in std_logic;
		rstn : in std_logic;
		lock : in std_logic;
		update : in std_logic;
		paddle_1_y : out natural;
		paddle_2_y : out natural;
		volt_1 : out std_logic_vector(11 downto 0);
		volt_2 : out std_logic_vector(11 downto 0)
	);
end User_Input;


architecture behave of User_Input is

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
	signal channel_1_reading : std_logic_vector(8 downto 0);
	signal channel_2_reading : std_logic_vector(8 downto 0);
	signal player_1_bounded : std_logic_vector(8 downto 0);
	signal player_2_bounded : std_logic_vector(8 downto 0);

begin

p_save : process (vga_clk)
begin
	if rising_edge(vga_clk) then
		if update = '1' then
			paddle_1_y <= to_integer(unsigned(player_1_bounded));
			paddle_2_y <= to_integer(unsigned(player_2_bounded));
		end if;
	end if;
end process;

	volt_1 <= channel_1_reading & "000";
	volt_2 <= channel_2_reading & "000";

p_sample : process (adc_pll_clk)
   begin
	   if rising_edge(adc_pll_clk) then
		   if resp_valid = '1' then
				if resp_channel = "00001" then
					cmd_channel <= "00010";
					channel_1_reading <= resp_data(11 downto 5) & "00";
				else
					cmd_channel <= "00001";
					channel_2_reading <= resp_data(11 downto 5 ) & "00";
				end if;
		   end if;
	   end if;
   end process;
   
p_map : process (adc_pll_clk)
begin
	if rising_edge(adc_pll_clk) then
		if channel_1_reading > "100101100" then
			player_1_bounded <= "100101100";
		elsif channel_1_reading < "000010100" then
			player_1_bounded <= "000010100";
		else
			player_1_bounded <= channel_1_reading;
		end if;

		if channel_2_reading > "100101100" then
			player_2_bounded <= "100101100";
		elsif channel_2_reading < "000010100" then
			player_2_bounded <= "000010100";
		else
			player_2_bounded <= channel_2_reading;
		end if;
	end if;
end process;

	adc_0 : entity work.adc(rtl)
	port map (
		clock_clk              => adc_clk,
		reset_sink_reset_n     => rstn,
		adc_pll_clock_clk      => adc_pll_clk,
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
