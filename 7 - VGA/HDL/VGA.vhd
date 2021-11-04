library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity VGA is
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		VGA_B : out std_logic_vector(3 downto 0);
		VGA_G : out std_logic_vector(3 downto 0);
		VGA_R : out std_logic_vector(3 downto 0);
		VGA_HS : out std_logic;
		VGA_VS : out std_logic
	);
end VGA;


architecture behave of VGA is
	constant vga_max_x : natural := 640;
	constant vga_max_y : natural := 480;
	constant flag_v_x1 : natural := 200;
	constant flag_v_x2 : natural := 440;
	constant flag_h_y1 : natural := 128000;
	constant flag_h_mid : natural := 192000;
	constant flag_h_y2 : natural := 256000;

	constant WHITE : std_logic_vector(11 downto 0) := x"FFF";
	constant BLACK : std_logic_vector(11 downto 0) := x"000";
	constant RED : std_logic_vector(11 downto 0) := x"F00";
	constant GREEN : std_logic_vector(11 downto 0) := x"095";
	constant BLUE : std_logic_vector(11 downto 0) := x"00F";
	constant YELLOW : std_logic_vector(11 downto 0) := x"FF0";
	constant ORANGE : std_logic_vector(11 downto 0) := x"F70";
	constant LIME : std_logic_vector(11 downto 0) := x"3F3";
	constant CRIMSON : std_logic_vector(11 downto 0) := x"B11";
	constant BANANA : std_logic_vector(11 downto 0) := x"DD2";
	constant AZULE : std_logic_vector(11 downto 0) := x"109";

	type state_type is (FRANCE, ITALY, IRELAND, BELGIUM, MALI, CHAD, NIGERIA, IVORY, POLAND, GERMANY, AUSTRIA, CONGO);
	signal flag_state : state_type;

	signal rstn_btn : std_logic;
	signal next_btn : std_logic;
	signal next_delay : std_logic;
	signal next_pulse : std_logic;

	signal vga_clk : std_logic;
	signal vga_x : natural;
	signal vga_y : natural;
	signal pixel_color : std_logic_vector(11 downto 0);
begin

	p_next : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			next_btn <= KEY(1);
			next_delay <= next_btn;
			next_pulse <= (not next_btn) and next_delay;
		end if;
	end process;

	p_blanking : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			if vga_x < vga_max_x then
				VGA_R <= pixel_color(11 downto 8);
				VGA_G <= pixel_color(7 downto 4);
				VGA_B <= pixel_color(3 downto 0);
			else
				VGA_R <= "0000";
				VGA_G <= "0000";
				VGA_B <= "0000";
			end if;
		end if;
	end process;

	p_state_machine : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			

			case flag_state is
				when FRANCE =>
					if next_pulse = '1' then
						flag_state <= ITALY;
					end if;
					if vga_x < flag_v_x1 then
						pixel_color <= BLUE;
					elsif vga_x < flag_v_x2 then
						pixel_color <= WHITE;
					else
						pixel_color <= RED;
					end if;
				when ITALY =>
					if next_pulse = '1' then
						flag_state <= IRELAND;
					end if;
					if vga_x < flag_v_x1 then
						pixel_color <= GREEN;
					elsif vga_x < flag_v_x2 then
						pixel_color <= WHITE;
					else
						pixel_color <= RED;
					end if;
				when IRELAND =>
					if next_pulse = '1' then
						flag_state <= BELGIUM;
					end if;
					if vga_x < flag_v_x1 then
						pixel_color <= GREEN;
					elsif vga_x < flag_v_x2 then
						pixel_color <= WHITE;
					else
						pixel_color <= ORANGE;
					end if;
				when BELGIUM =>
					if next_pulse = '1' then
						flag_state <= MALI;
					end if;
					if vga_x < flag_v_x1 then
						pixel_color <= BLACK;
					elsif vga_x < flag_v_x2 then
						pixel_color <= YELLOW;
					else
						pixel_color <= RED;
					end if;
				when MALI =>
					if next_pulse = '1' then
						flag_state <= CHAD;
					end if;
					if vga_x < flag_v_x1 then
						pixel_color <= LIME;
					elsif vga_x < flag_v_x2 then
						pixel_color <= BANANA;
					else
						pixel_color <= RED;
					end if;
				when CHAD =>
					if next_pulse = '1' then
						flag_state <= NIGERIA;
					end if;
					if vga_x < flag_v_x1 then
						pixel_color <= AZULE;
					elsif vga_x < flag_v_x2 then
						pixel_color <= BANANA;
					else
						pixel_color <= CRIMSON;
					end if;
				when NIGERIA =>
					if next_pulse = '1' then
						flag_state <= IVORY;
					end if;
					if vga_x < flag_v_x1 then
						pixel_color <= GREEN;
					elsif vga_x < flag_v_x2 then
						pixel_color <= WHITE;
					else
						pixel_color <= GREEN;
					end if;
				when IVORY =>
					if next_pulse = '1' then
						flag_state <= POLAND;
					end if;
					if vga_x < flag_v_x1 then
						pixel_color <= ORANGE;
					elsif vga_x < flag_v_x2 then
						pixel_color <= WHITE;
					else
						pixel_color <= GREEN;
					end if;
				when POLAND =>
					if next_pulse = '1' then
						flag_state <= GERMANY;
					end if;
					if vga_y < flag_h_mid then
						pixel_color <= WHITE;
					else
						pixel_color <= RED;
					end if;
				when GERMANY =>
					if next_pulse = '1' then
						flag_state <= AUSTRIA;
					end if;
					if vga_y < flag_h_y1 then
						pixel_color <= BLACK;
					elsif vga_y < flag_h_y2 then
						pixel_color <= RED;
					else
						pixel_color <= BANANA;
					end if;
				when AUSTRIA =>
					if next_pulse = '1' then
						flag_state <= FRANCE;
					end if;
					if vga_y < flag_h_y1 then
						pixel_color <= RED;
					elsif vga_y < flag_h_y2 then
						pixel_color <= WHITE;
					else
						pixel_color <= RED;
					end if;
				when others =>
					flag_state <= FRANCE;
			end case;
		end if;
	end process;
	
	rstn_btn <= KEY(0);

	VG0: entity work.VGA_Sync(behave)
	port map (
		vga_clk => vga_clk,
		rstn => rstn_btn,
		vga_hs => VGA_HS,
		vga_x => vga_x,
		vga_vs => VGA_VS,
		vga_y => vga_y
	);

	PL0: entity work.PLL(syn)
	port map (
		inclk0 => MAX10_CLK1_50,
		c0	=> vga_clk
	);

end behave;



















