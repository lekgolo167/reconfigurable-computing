library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Sound is
	port (
		clk : in std_logic;
		rstn : in std_logic;
		goal : in std_logic;
		obstacle : in std_logic;
		wall : in std_logic;
		paddle : in std_logic;
		speaker : out std_logic
	);
end Sound;


architecture behave of Sound is
	signal period : std_logic_vector(18 downto 0);
	signal duration : std_logic_vector(25 downto 0);
	signal volume : std_logic_vector(2 downto 0);
	signal enable : std_logic;
	signal d_counter, de_counter_next : std_logic_vector(25 downto 0);
	signal note, note_next : std_logic_vector(8 downto 0);
	signal note_addr, note_addr_next : std_logic_vector(1 downto 0);
	signal change_note : std_logic;
	signal source, source_next : std_logic_vector(1 downto 0);
	signal data, sound_1, sound_2, sound_3, sound_4 : std_logic_vector(8 downto 0);
	type state_type is (OFF, PLAYING);
	signal state, state_next : state_type;
	signal start : std_logic;
	signal counter, counter_next : std_logic_vector(18 downto 0);
	signal pulse_width : std_logic_vector(18 downto 0);

begin

	p_sound : process (clk, rstn)
	begin
		if rstn = '0' then
			state <= OFF;
			source <= "00";
			note_addr <= (others => '0');
			note <= (others => '0');
			d_counter <= (others => '0');
		elsif rising_edge(clk) then
			state <= state_next;
			source <= source_next;
			note_addr <= note_addr_next;
			note <= note_next;
			d_counter <= de_counter_next;
		end if;
	end process;

	p_sounds : process (state, start, enable, duration, d_counter, note_addr, change_note)
	begin
		state_next <= state;
		note_addr_next <= note_addr;

		case state is
			when OFF =>
				note_addr_next <= (others => '0');
				
				if start = '1' then
					state_next <= PLAYING;
				end if;
			when PLAYING =>
				if duration = 0 then
					state_next <= OFF;
				elsif change_note = '1' then
					note_addr_next <= note_addr + 1;
				end if;
			end case;
	end process;

	enable <= '1' when state = playing else '0';
	change_note <= '1' when d_counter = duration else '0';
	de_counter_next <= d_counter + '1' when (enable = '1' and d_counter < duration) else (others => '0');
	
	with note(8 downto 6) select
		period <= "1101110111110010001" when "001", --  110 Hz
				"0110111011111001000" when "010", --  220 Hz
				"0011011101111100100" when "011", --  440 Hz
				"0001101110111110010" when "100", --  880 Hz
				"0000110111011111001" when "101", -- 1760 Hz
				"0000011011101111100" when "110", -- 3520 Hz
				"0000001101110111110" when "111", -- 7040 Hz
				"0000000000000000000" when others;
	
	with note(5 downto 3) select
		duration <= "00000010111110101111000010" when "001", -- 1/64
					"00000101111101011110000100" when "010", -- 1/32
					"00001011111010111100001000" when "011", -- 1/16
					"00010111110101111000010000" when "100", -- 1/8
					"00101111101011110000100000" when "101", -- 1/4
					"01011111010111100001000000" when "110", -- 1/2
					"10111110101111000010000000" when "111", -- 1/1
					"00000000000000000000000000" when others;

	volume <= note(2 downto 0);
	start <= '1' when (obstacle = '1' or goal = '1' or paddle = '1' or wall = '1') else '0';
	source_next <= "00" when goal = '1' else "01" when obstacle = '1' else "10" when wall = '1' else "11" when paddle = '1' else source;
	data <= sound_1 when source = "00" else sound_2 when source = "01" else sound_3 when source = "10" else sound_4 when source = "11";
	note_next <= data;
				
	process(clk, rstn)
	begin
		if rstn = '0' then
			counter <= (others => '0');
		elsif rising_edge(clk) then
			counter <= counter_next;
		end if;
	end process;

	-- duty cycle:
	--    max:   50% (18 downto 1)
	--    min: 0.78% (18 downto 7)
	--    off when given 0 (18 downto 0)!
	with volume select
		pulse_width <= ("0" & period(18 downto 1)) when "001",
			("00" & period(18 downto 2)) when "010",
			("000" & period(18 downto 3)) when "011",
			("0000" & period(18 downto 4)) when "100",
			("00000" & period(18 downto 5)) when "101",
			("000000" & period(18 downto 6)) when "110",
			("0000000" & period(18 downto 7)) when "111",
			period when others;

	counter_next <= (others => '0') when counter = period else
					counter + 1;

	speaker <= '1' when (enable = '1' and counter < pulse_width) else '0';

	gol:
		entity work.Goal_Sound(content)
		port map(
			addr => note_addr,
			data => sound_1
		);
	
	bmp:
		entity work.Obstacle_Sound(content)
		port map(
			addr => note_addr,
			data => sound_2
		);
	
	wll:
		entity work.Wall_Sound(content)
		port map(
			addr => note_addr,
			data => sound_3
		);

	pad:
		entity work.Paddle_Sound(content)
		port map(
			addr => note_addr,
			data => sound_4
		);

	end behave;
