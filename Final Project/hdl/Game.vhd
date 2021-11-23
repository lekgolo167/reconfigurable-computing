library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Game is
	port (
		clk : in std_logic;
		rst_n : in std_logic;
		update : in std_logic;
		paddle_1_y : in natural;
		paddle_2_y : in natural;
		ball_x_out : out natural;
		ball_y_out : out natural;
		goal_sound : out std_logic;
		wall_sound : out std_logic;
		object_sound : out std_logic;
		paddle_sound : out std_logic
	);
end Game;


architecture behave of Game is
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
	signal ball_x : natural;
	signal ball_y : natural;
	signal y_dir : integer;
	signal x_dir : integer;
	-- collision side
	signal south_collision : std_logic;
	signal north_collision : std_logic;
	signal east_collision : std_logic;
	signal west_collision : std_logic;
	-- boarder
	signal south_boarder_collision : std_logic;
	signal north_boarder_collision : std_logic;
	signal east_boarder_collision : std_logic;
	signal west_boarder_collision : std_logic;
	-- object
	signal south_object_collision : std_logic;
	signal north_object_collision : std_logic;
	signal east_object_collision : std_logic;
	signal west_object_collision : std_logic;
	-- paddle
	signal south_paddle_collision : std_logic;
	signal north_paddle_collision : std_logic;
	signal east_paddle_collision : std_logic;
	signal west_paddle_collision : std_logic;
	-- goals
	signal goal_left : std_logic;
	signal goal_right : std_logic;


begin
	-- sounds
	goal_sound <= goal_left or goal_right;
	wall_sound <= south_boarder_collision or north_boarder_collision or west_boarder_collision or east_boarder_collision;
	paddle_sound <= south_paddle_collision or north_paddle_collision or east_paddle_collision or west_paddle_collision;
	object_sound <= south_object_collision or north_object_collision or east_object_collision or west_object_collision;

	-- collisions
	south_collision <= south_boarder_collision; -- or south_object_collision or south_paddle_collision;
	north_collision <= north_boarder_collision; --  or north_object_collision or north_paddle_collision;
	west_collision <= west_boarder_collision; --  or east_object_collision or east_paddle_collision;
	east_collision <= east_boarder_collision; --  or west_object_collision or west_paddle_collision;

	-- border bounce
	south_boarder_collision <= '1' when (ball_y + ball_width >= border_bottom_y) 
						else '0';
	north_boarder_collision <= '1' when (ball_y <= border_top_y) 
						else '0';
	west_boarder_collision <= '1' when ((ball_x <= border_left_x) and (ball_y <= border_goal_y or ball_y + ball_width >= border_goal_y + border_goal_height)) 
						else '0';
	east_boarder_collision <= '1' when ((ball_x + ball_width >= border_right_x) and (ball_y <= border_goal_y or ball_y + ball_width >= border_goal_y + border_goal_height)) 
						else '0';

	-- object bounce

	-- paddle bounce

	-- goal
	goal_left <= '1' when (ball_x < border_left_x) else '0';
	goal_right <= '1' when (ball_x + ball_width > border_right_x) else '0';

	p_game : process (clk, rst_n)
	begin
		if rst_n = '0' then
			x_dir <= 1;
			y_dir <= 1;
		elsif rising_edge(clk) then
			if north_collision = '1' then
				y_dir <= 1;
			elsif south_collision = '1' then
				y_dir <= -1;
			elsif east_collision = '1' then
				x_dir <= -1;
			elsif west_collision = '1' then
				x_dir <= 1;
			else
				x_dir <= x_dir;
				y_dir <= y_dir;
			end if;
		end if;
	end process;
	
	p_ball : process (clk, rst_n)
	begin
		if rst_n = '0' then
			ball_x <= 315;
			ball_y <= 150;
		elsif rising_edge(clk) then
			if update = '1' then
				ball_x <= ball_x + x_dir;
				ball_y <= ball_y + y_dir;
			end if;
		end if;
	end process;
	
	ball_x_out <= ball_x;
	ball_y_out <= ball_y;

end behave;