library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Bumper_Pool is
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		ARDUINO_IO : inout std_logic_vector(15 downto 0);
		ARDUINO_RESET_N : inout std_logic;
		KEY : in std_logic_vector(1 downto 0);
		SW : in std_logic_vector(9 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		HEX0 : out std_logic_vector(7 downto 0);
		HEX1 : out std_logic_vector(7 downto 0);
		HEX2 : out std_logic_vector(7 downto 0);
		HEX3 : out std_logic_vector(7 downto 0);
		HEX4 : out std_logic_vector(7 downto 0);
		HEX5 : out std_logic_vector(7 downto 0);
		VGA_B : out std_logic_vector(3 downto 0);
		VGA_G : out std_logic_vector(3 downto 0);
		VGA_R : out std_logic_vector(3 downto 0);
		VGA_HS : out std_logic;
		VGA_VS : out std_logic
	);
end Bumper_Pool;


architecture behave of Bumper_Pool is

	signal rstn_btn : std_logic;
	signal next_ball : std_logic;
	signal adc_clk : std_logic;
	signal vga_clk : std_logic;
	signal lock : std_logic;
	signal update : std_logic;
	signal new_ball_btn : std_logic;
	signal new_ball_delay : std_logic;
	signal new_ball_pulse : std_logic;
	signal paddle_1_y : natural;
	signal paddle_2_y : natural;
	signal ball_x : natural;
	signal ball_y : natural;
	signal goal_sound : std_logic;
	signal wall_sound : std_logic;
	signal object_sound : std_logic;
	signal paddle_sound : std_logic;
	signal score_1 : std_logic_vector(3 downto 0);
	signal score_2 : std_logic_vector(3 downto 0);
begin

	p_btn : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			new_ball_btn <= KEY(1);
			new_ball_delay <= new_ball_btn;
		end if;
	end process;

PL0: entity work.PLL(syn)
	port map (
		inclk0 => ADC_CLK_10,
		c0	=> adc_clk,
		c1 => vga_clk,
		locked => lock
	);

GAM: entity work.Game(behave)
	port map (
		clk => vga_clk,
		rst_n => rstn_btn,
		update => update,
		new_ball => new_ball_pulse,
		score_1_out => score_1,
		score_2_out => score_2,
		paddle_1_y => paddle_1_y,
		paddle_2_y => paddle_2_y,
		ball_x_out => ball_x,
		ball_y_out => ball_y,
		goal_sound => goal_sound,
		wall_sound => wall_sound,
		object_sound => object_sound,
		paddle_sound => paddle_sound 
	);

GPH: entity work.Graphics(behave)
		port map (
			vga_clk => vga_clk,
			ball_x => ball_x,
			ball_y => ball_y,
			paddle_1_y => paddle_1_y,
			paddle_2_y => paddle_2_y,
			score_1 => "00000" & score_1,
			score_2 => "00000" & score_2,
			vga_red => VGA_R,
			vga_green => VGA_G,
			vga_blue => VGA_B,
			vga_hs => VGA_HS,
			vga_vs => VGA_VS,
			update => update
		);

UIP: entity work.User_Input(behave)
	port map (
		adc_clk => ADC_CLK_10,
		adc_pll_clk => adc_clk,
		vga_clk => vga_clk,
		rstn => rstn_btn,
		lock => lock,
		update => update,
		paddle_1_y => paddle_1_y,
		paddle_2_y => paddle_2_y
	);
		 
SND: entity work.Sound(behave)
	port map (
		clk => vga_clk,
		rstn => rstn_btn,
		goal => goal_sound,
		obstacle => '0',
		wall => wall_sound,
		paddle => '0',
		speaker => ARDUINO_IO(0)
	);

HX0: entity work.Seg_Decoder(rtl)
    port map (
        en => '0',
        binary => "0000",
        dp => '0',
        hex => HEX0
    );

HX1: entity work.Seg_Decoder(rtl)
    port map (
        en => '0',
        binary => "0000",
        dp => '0',
        hex => HEX1
    );

HX2: entity work.Seg_Decoder(rtl)
    port map (
        en => '0',
        binary => "0000",
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

	LEDR <= (others => '0');
    rstn_btn <= KEY(0);
	new_ball_pulse <= (not new_ball_btn) and new_ball_delay;

end behave;
