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
		new_ball : in std_logic;
		ball_x_out : out natural;
		ball_y_out : out natural;
		goal_sound : out std_logic;
		wall_sound : out std_logic;
		object_sound : out std_logic;
		paddle_sound : out std_logic;
		score_1_out : out std_logic_vector(3 downto 0);
	   score_2_out : out std_logic_vector(3 downto 0)
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
	constant objs_r2_x : natural := 270;
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
	signal x_dir_init : integer;
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
	
	-- game play
	type state_type is (INIT, PLAY, HOLD, OVER);
	signal game_state : state_type;
	signal score_1 : std_logic_vector(3 downto 0);
	signal score_2 : std_logic_vector(3 downto 0);


begin
	-- sounds
	goal_sound <= goal_left or goal_right;
	wall_sound <= south_boarder_collision or north_boarder_collision or west_boarder_collision or east_boarder_collision;
	paddle_sound <= south_paddle_collision or north_paddle_collision or east_paddle_collision or west_paddle_collision;
	object_sound <= south_object_collision or north_object_collision or east_object_collision or west_object_collision;

	-- collisions
	south_collision <= south_boarder_collision or south_object_collision or south_paddle_collision;
	north_collision <= north_boarder_collision or north_object_collision or north_paddle_collision;
	west_collision <= west_boarder_collision or west_object_collision or west_paddle_collision;
	east_collision <= east_boarder_collision or east_object_collision or east_paddle_collision;

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
	south_object_collision <= '1' when (((ball_y < objs_top_y and ball_y + ball_width >= objs_top_y) or             -- top row
													 (ball_y < objs_bot_y and ball_y + ball_width >= objs_bot_y)) and           -- bottom row
												   ((ball_x + ball_width > objs_r1_x and ball_x < objs_r1_x + obj_width) or    -- first object
												    (ball_x + ball_width > objs_r2_x and ball_x < objs_r2_x + obj_width) or    -- second object
												    (ball_x + ball_width > objs_r3_x and ball_x < objs_r3_x + obj_width) or    -- third object
												    (ball_x + ball_width > objs_r4_x and ball_x < objs_r4_x + obj_width))) or  -- fourth object
													((ball_y < obj_c_y and ball_y + ball_width >= obj_c_y) and                -- center row
												    (ball_x + ball_width > obj_c_x and ball_x < obj_c_x + obj_width))        -- center column
						else '0';
	north_object_collision <= '1' when (((ball_y <= objs_top_y + obj_width and ball_y + ball_width > objs_top_y + obj_width) or    -- top row
													 (ball_y <= objs_bot_y + obj_width and ball_y + ball_width > objs_bot_y + obj_width)) and  -- bottom row
												   ((ball_x + ball_width > objs_r1_x and ball_x < objs_r1_x + obj_width) or                   -- first object
												    (ball_x + ball_width > objs_r2_x and ball_x < objs_r2_x + obj_width) or                   -- second object
												    (ball_x + ball_width > objs_r3_x and ball_x < objs_r3_x + obj_width) or                   -- third object
												    (ball_x + ball_width > objs_r4_x and ball_x < objs_r4_x + obj_width))) or                 -- fourth object
													((ball_y <= obj_c_y + obj_width and ball_y + ball_width > obj_c_y + obj_width) and       -- center row
												    (ball_x + ball_width > obj_c_x and ball_x < obj_c_x + obj_width))                       -- center column
						else '0';
	east_object_collision <= '1' when (((ball_y < objs_top_y + obj_width and ball_y + ball_width > objs_top_y) or       -- top row
													(ball_y < objs_bot_y + obj_width and ball_y + ball_width > objs_bot_y)) and     -- bottom row
												  ((ball_x + ball_width >= objs_r1_x and ball_x < objs_r1_x) or                    -- first object
												   (ball_x + ball_width >= objs_r2_x and ball_x < objs_r2_x) or                    -- second object
												   (ball_x + ball_width >= objs_r3_x and ball_x < objs_r3_x) or                    -- third object
												   (ball_x + ball_width >= objs_r4_x and ball_x < objs_r4_x))) or                  -- fourth object
												  ((ball_y < obj_c_y + obj_width and ball_y + ball_width > obj_c_y) and          -- center row
												   (ball_x + ball_width >= obj_c_x and ball_x < obj_c_x))                        -- center column
						else '0';
	west_object_collision <= '1' when (((ball_y < objs_top_y + obj_width and ball_y + ball_width > objs_top_y) or               -- top row
													(ball_y < objs_bot_y + obj_width and ball_y + ball_width > objs_bot_y)) and             -- bottom row
												  ((ball_x + ball_width > objs_r1_x + obj_width and ball_x <= objs_r1_x + obj_width) or    -- first object
												   (ball_x + ball_width > objs_r2_x + obj_width and ball_x <= objs_r2_x + obj_width) or    -- second object
												   (ball_x + ball_width > objs_r3_x + obj_width and ball_x <= objs_r3_x + obj_width) or    -- third object
												   (ball_x + ball_width > objs_r4_x + obj_width and ball_x <= objs_r4_x + obj_width))) or  -- fourth object
												  ((ball_y < obj_c_y + obj_width and ball_y + ball_width > obj_c_y) and                  -- center row
												   (ball_x + ball_width > obj_c_x + obj_width and ball_x <= obj_c_x + obj_width))        -- center column
						else '0';

	-- paddle bounce
	south_paddle_collision <= '1' when ((ball_y < paddle_1_y and ball_y + ball_width >= paddle_1_y) and
												(ball_x + ball_width > paddle_1_x and ball_x < paddle_1_x + paddle_width))or
											  ((ball_y < paddle_2_y and ball_y + ball_width >= paddle_2_y) and
												(ball_x + ball_width > paddle_2_x and ball_x < paddle_1_x + paddle_width))
						else '0';
	north_paddle_collision <= '1' when ((ball_y <= paddle_1_y + paddle_height and ball_y + ball_width > paddle_1_y + paddle_height) and
												(ball_x + ball_width > paddle_1_x and ball_x < paddle_1_x + paddle_width))or
											  ((ball_y <= paddle_2_y + paddle_height and ball_y + ball_width > paddle_2_y + paddle_height) and
												(ball_x + ball_width > paddle_2_x and ball_x < paddle_2_x + paddle_width))
						else '0';
	east_paddle_collision <= '1' when ((ball_y < paddle_1_y + paddle_height and ball_y + ball_width > paddle_1_y) and
												  (ball_x < paddle_1_x and ball_x + ball_width >= paddle_1_x)) or
												 ((ball_y < paddle_2_y + paddle_height and ball_y + ball_width > paddle_2_y) and
												  (ball_x < paddle_2_x and ball_x + ball_width >= paddle_2_x))
						else '0';
	west_paddle_collision <= '1' when ((ball_y < paddle_1_y + paddle_height and ball_y + ball_width > paddle_1_y) and
												  (ball_x <= paddle_1_x + paddle_width and ball_x + ball_width > paddle_1_x + paddle_width)) or
												 ((ball_y < paddle_2_y + paddle_height and ball_y + ball_width > paddle_2_y) and
												  (ball_x <= paddle_2_x + paddle_width and ball_x + ball_width > paddle_2_x + paddle_width))
						else '0';

	-- goal
	goal_left <= '1' when ((ball_x < (border_left_x)) and (west_boarder_collision = '0')) else '0';
	goal_right <= '1' when ((ball_x + ball_width > (border_right_x)) and (east_boarder_collision = '0')) else '0';

	p_game : process (clk, rst_n, new_ball)
	begin
		if new_ball = '1' then
			x_dir <= x_dir_init;
			y_dir <= 1;
		elsif rising_edge(clk) then
			if north_collision = '1' then
				y_dir <= 4;
			elsif south_collision = '1' then
				y_dir <= -4;
			elsif east_collision = '1' then
				x_dir <= -5;
			elsif west_collision = '1' then
				x_dir <= 5;
			else
				x_dir <= x_dir;
				y_dir <= y_dir;
			end if;
		end if;
	end process;
	
	p_ball : process (clk, new_ball)
	begin
		if new_ball = '1' then
			ball_x <= 315;
			ball_y <= 50;
		elsif rising_edge(clk) then
			if update = '1' then
				if game_state = HOLD or game_state = OVER then
					ball_x <= 800;
					ball_y <= 525;
				elsif game_state = INIT then
					ball_x <= 315;
					ball_y <= 50;
				else	
					ball_x <= ball_x + x_dir;
					ball_y <= ball_y + y_dir;
				end if;
			end if;
		end if;
	end process;
	
	game_play : process (clk, rst_n)
	begin
		if rst_n = '0' then
			game_state <= INIT;
			score_1 <= "0000";
			score_2 <= "0000";
			x_dir_init <= 1;
		elsif rising_edge(clk) then
			case game_state is
				when INIT =>
					score_1 <= "0000";      -- not sure how to set the score to zero
					score_2 <= "0000";
					if new_ball = '1' then
						game_state <= PLAY;
					end if;
				when PLAY =>
					if goal_right = '1' then
						game_state <= HOLD;
						score_1 <= score_1 + "0001";
						x_dir_init <= -1;
					elsif goal_left = '1' then
						game_state <= HOLD;
						score_2 <= score_2 + "0001";
						x_dir_init <= 1;
					else
						game_state <= PLAY;
					end if;
				when HOLD =>
					if score_1 = "0101" then
						game_state <= OVER;
					elsif score_2 = "0101" then
						game_state <= OVER;
					elsif new_ball = '1' then
						game_state <= PLAY;
					else
						game_state <= HOLD;
					end if;
				when OVER =>
					game_state <= OVER;
				when others =>
					game_state <= INIT;
			end case;
		end if;
	end process;
	
	ball_x_out <= ball_x;
	ball_y_out <= ball_y;
	score_1_out <= score_1;
	score_2_out <= score_2;

end behave;
