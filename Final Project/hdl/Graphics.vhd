library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Graphics is
	port (
		vga_clk : in std_logic;
		ball_x : in natural;
		ball_y : in natural;
		paddle_1_y : natural;
		paddle_2_y : natural;
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
	constant objs_top_y : natural := 90;
	constant objs_bot_y : natural := 250;
	constant objs_r1_x : natural := 190;
	constant objs_r2_x : natural := 260;
	constant objs_r3_x : natural := 350;
	constant objs_r4_x : natural := 430;
	constant obj_c_x : natural := 310;
	constant obj_c_y : natural := 170;
	constant paddle_1_x : natural := 40;
	constant paddle_2_x : natural := 595;
	constant paddle_width : natural := 5;
	constant paddle_height : natural := 40;
	constant ball_width : natural := 10;

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
	signal draw_obstacles : std_logic;
	signal draw_obstacle_c : std_logic;
	signal draw_obstacle_1 : std_logic;
	signal draw_obstacle_2 : std_logic;
	signal draw_obstacle_3 : std_logic;
	signal draw_obstacle_4 : std_logic;
	signal draw_obstacle_5 : std_logic;
	signal draw_obstacle_6 : std_logic;
	signal draw_obstacle_7 : std_logic;
	signal draw_obstacle_8 : std_logic;
	signal draw_ball : std_logic;

begin

	update <= '1' when vga_x = vga_max_x and vga_y = vga_max_y else '0';
	
	draw_border <= '1' when ((vga_y = border_top_y or vga_y = border_bottom_y) and -- top/bottom
							(vga_x >= border_left_x and vga_x <= border_right_x)) or
							((vga_x = border_left_x or vga_x = border_right_x) and -- left/right
							((vga_y >= border_top_y and vga_y <= border_goal_y) or
							(vga_y >= border_goal_y + border_goal_height and vga_y <= border_bottom_y)))
						else '0';
	
	draw_obstacles <= draw_obstacle_1 or draw_obstacle_2 or draw_obstacle_3 or draw_obstacle_4 or
						draw_obstacle_5 or draw_obstacle_6 or draw_obstacle_7 or draw_obstacle_8 or draw_obstacle_c;

	draw_obstacle_c <= '1' when (vga_y >= obj_c_y and vga_y <= obj_c_y + obj_width) and
							(vga_x >= obj_c_x and vga_x <= obj_c_x + obj_width) 
						else '0';
	
	draw_obstacle_1 <= '1' when (vga_y >= objs_top_y and vga_y <= objs_top_y + obj_width) and
							(vga_x >= objs_r1_x and vga_x <= objs_r1_x + obj_width) 
						else '0';

	draw_obstacle_2 <= '1' when (vga_y >= objs_top_y and vga_y <= objs_top_y + obj_width) and
							(vga_x >= objs_r2_x and vga_x <= objs_r2_x + obj_width) 
						else '0';

	draw_obstacle_3 <= '1' when (vga_y >= objs_top_y and vga_y <= objs_top_y + obj_width) and
							(vga_x >= objs_r3_x and vga_x <= objs_r3_x + obj_width) 
						else '0';

	draw_obstacle_4 <= '1' when (vga_y >= objs_top_y and vga_y <= objs_top_y + obj_width) and
							(vga_x >= objs_r4_x and vga_x <= objs_r4_x + obj_width) 
						else '0';

	draw_obstacle_5 <= '1' when (vga_y >= objs_bot_y and vga_y <= objs_bot_y + obj_width) and
							(vga_x >= objs_r1_x and vga_x <= objs_r1_x + obj_width) 
						else '0';

	draw_obstacle_6 <= '1' when (vga_y >= objs_bot_y and vga_y <= objs_bot_y + obj_width) and
							(vga_x >= objs_r2_x and vga_x <= objs_r2_x + obj_width) 
						else '0';

	draw_obstacle_7 <= '1' when (vga_y >= objs_bot_y and vga_y <= objs_bot_y + obj_width) and
							(vga_x >= objs_r3_x and vga_x <= objs_r3_x + obj_width) 
						else '0';

	draw_obstacle_8 <= '1' when (vga_y >= objs_bot_y and vga_y <= objs_bot_y + obj_width) and
							(vga_x >= objs_r4_x and vga_x <= objs_r4_x + obj_width) 
						else '0';

	draw_paddle_p1 <= '1' when (vga_y >= paddle_1_y and vga_y <= paddle_1_y + paddle_height) and
							(vga_x >= paddle_1_x and vga_x <= paddle_1_x + paddle_width) 
						else '0';

	draw_paddle_p2 <= '1' when (vga_y >= paddle_2_y and vga_y <= paddle_2_y + paddle_height) and
							(vga_x >= paddle_2_x and vga_x <= paddle_2_x + paddle_width) 
						else '0';

	draw_ball <= '1' when (vga_y >= ball_y and vga_y <= ball_y + ball_width) and
						(vga_x >= ball_x and vga_x <= ball_x + ball_width) 
					else '0';

	p_draw_board : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			if draw_border = '1' or draw_ball = '1' then
				pixel_color <= WHITE;
			elsif draw_obstacles = '1' then
				pixel_color <= CRIMSON;
			elsif draw_paddle_p1 = '1' or draw_paddle_p2 = '1' then
				pixel_color <= ORANGE;
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
