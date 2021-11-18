library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Graphics is
	port (
		vga_clk : in std_logic;
		vga_red : out std_logic_vector(3 downto 0);
		vga_green : out std_logic_vector(3 downto 0);
		vga_blue : out std_logic_vector(3 downto 0);
		vga_hs : out std_logic;
		vga_vs : out std_logic;
		update : out std_logic
	);
end Graphics;


architecture behave of Graphics is
	constant vga_max_x : natural := 640;
	constant vga_max_y : natural := 480;
	constant border_top_y : natural := 20;
	constant border_bottom_y : natural := 340;
	constant border_left_x : natural := 20;
	constant border_right_x : natural := 620;
	constant border_goal_y : natural := 145;
	constant border_goal_height : natural := 70;
	constant obj_width : natural := 20;
	constant obj_1_x : natural := 310;
	constant obj_1_y :natural := 170;

	constant WHITE : std_logic_vector(11 downto 0) := x"FFF";
	constant BLACK : std_logic_vector(11 downto 0) := x"000";
	constant RED : std_logic_vector(11 downto 0) := x"F00";
	constant GREEN : std_logic_vector(11 downto 0) := x"095";
	constant BLUE : std_logic_vector(11 downto 0) := x"00F";
	constant YELLOW : std_logic_vector(11 downto 0) := x"FF0";
	constant ORANGE : std_logic_vector(11 downto 0) := x"F70";
	constant LIME : std_logic_vector(11 downto 0) := x"3F3";
	constant CRIMSON : std_logic_vector(11 downto 0) := x"B11";
	constant BANANA : std_logic_vector(11 downto 0) := x"DC2";
	constant AZULE : std_logic_vector(11 downto 0) := x"109";

	signal vga_x : natural;
	signal vga_y : natural;
	signal pixel_color : std_logic_vector(11 downto 0);
	signal draw_border : std_logic;
	signal draw_paddle_p1 : std_logic;
	signal draw_paddle_p2 : std_logic;
	signal draw_obstacle : std_logic;
	signal draw_ball : std_logic;

begin

	update <= '1' when vga_x = vga_max_x and vga_y = vga_max_y else '0';
	
	draw_border <= '1' when ((vga_y = border_top_y or vga_y = border_bottom_y) and -- top/bottom
							(vga_x >= border_left_x and vga_x <= border_right_x)) or
							((vga_x = border_left_x or vga_x = border_right_x) and -- left/right
							((vga_y >= border_top_y and vga_y <= border_goal_y) or
							(vga_y >= border_goal_y + border_goal_height and vga_y <= border_bottom_y)))
						else '0';

	draw_obstacle <= '1' when (vga_y >= obj_1_y and vga_y <= obj_1_y + obj_width) and
							(vga_x >= obj_1_x and vga_x <= obj_1_x + obj_width) 
						else '0';

	-- draw_paddle_p1 <= '1' when else '0';
	-- draw_paddle_p2 <= '1' when else '0';
	-- draw_ball <= '1' when else '0';

	p_draw_board : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			if draw_border = '1' then
				pixel_color <= WHITE;
			elsif draw_obstacle = '1' then
				pixel_color <= CRIMSON;
			else
				pixel_color <= BLACK;
			end if;
		end if;
	end process;
	
	p_vga_driver : process (vga_clk)
		begin
			if rising_edge(vga_clk) then
				if vga_x < vga_max_x then
					vga_red <= pixel_color(11 downto 8);
					vga_green <= pixel_color(7 downto 4);
					vga_blue <= pixel_color(3 downto 0);
				else
					vga_red <= "0000";
					vga_green <= "0000";
					vga_blue <= "0000";
				end if;
			end if;
		end process;
		
	VG0: entity work.VGA_Sync(behave)
	port map (
		vga_clk => vga_clk,
		vga_hs => vga_hs,
		vga_x => vga_x,
		vga_vs => vga_vs,
		vga_y => vga_y
	);

end behave;
