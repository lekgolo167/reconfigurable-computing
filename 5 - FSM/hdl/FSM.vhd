
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity FSM is
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
		SW : in std_logic_vector(9 downto 0);
		LEDR : out std_logic_vector(9 downto 0)
	);
end FSM;

architecture behave of FSM is
	type state_type is (IDLE, ACCUM);
	signal state : state_type;
	signal accumulator : std_logic_vector(23 downto 0);
	signal rstn_btn : std_logic;
	signal add_btn : std_logic;
begin

	STATE_MACHINE : process (MAX10_CLK1_50)
	begin
		if rising_edge(MAX10_CLK1_50) then
			if (rstn_btn = '0') then
				state <= IDLE;
				accumulator <= (others => '0');
			else
				case state is
					when IDLE =>
						if add_btn = '1' then
							accumulator <= accumulator + SW;
							state <= ACCUM;
						end if;
					when ACCUM =>
						if add_btn = '0' then
							state <= IDLE;
						end if;
				end case;
			end if;
		end if;
	end process;

    HX0: entity work.Seg_Decoder(rtl)
        port map (
            binary => accumulator(3 downto 0),
            dp => '0',
            hex => HEX0
        );

	HX1: entity work.Seg_Decoder(rtl)
        port map (
            binary => accumulator(7 downto 4),
            dp => '0',
            hex => HEX1
        );

	HX2: entity work.Seg_Decoder(rtl)
        port map (
            binary => accumulator(11 downto 8),
            dp => '0',
            hex => HEX2
        );

	HX3: entity work.Seg_Decoder(rtl)
        port map (
            binary => accumulator(15 downto 12),
            dp => '0',
            hex => HEX3
        );

	HX4: entity work.Seg_Decoder(rtl)
        port map (
            binary => accumulator(19 downto 16),
            dp => '0',
            hex => HEX4
        );

	HX5: entity work.Seg_Decoder(rtl)
        port map (
            binary => accumulator(23 downto 20),
            dp => '0',
            hex => HEX5
        );

	LEDR <= SW;
	add_btn <= not KEY(1);
	rstn_btn <= KEY(0);

end behave;

------------------------------
--
-- BROKEN
--
-------------------------------
-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- use ieee.std_logic_unsigned.all;

-- entity FSM is
-- 	port (
-- 		ADC_CLK_10 : in std_logic;
-- 		MAX10_CLK1_50 : in std_logic;
-- 		MAX10_CLK2_50 : in std_logic;
--         HEX0 : out std_logic_vector(7 downto 0);
--         HEX1 : out std_logic_vector(7 downto 0);
--         HEX2 : out std_logic_vector(7 downto 0);
--         HEX3 : out std_logic_vector(7 downto 0);
--         HEX4 : out std_logic_vector(7 downto 0);
--         HEX5 : out std_logic_vector(7 downto 0);
-- 		KEY : in std_logic_vector(1 downto 0);
-- 		SW : in std_logic_vector(9 downto 0);
-- 		LEDR : out std_logic_vector(9 downto 0)
-- 	);
-- end FSM;

-- architecture behave of FSM is
-- 	type state_type is (IDLE, ACCUM, CLEAN);
-- 	signal state : state_type;
-- 	signal accumulator : std_logic_vector(23 downto 0);
-- 	signal rstn_btn : std_logic;
-- 	signal add_btn : std_logic;
-- begin

-- 	STATE_MACHINE_3 : process (MAX10_CLK1_50)
-- 	begin
-- 		if rising_edge(MAX10_CLK1_50) then
-- 			if (rstn_btn = '0') then
-- 				state <= CLEAN;
-- 			else
-- 				case state is
-- 					when IDLE =>
-- 					if add_btn = '1' then
-- 						accumulator <= accumulator + SW;
-- 						state <= ACCUM;
-- 					end if;
-- 					when ACCUM =>
-- 					if add_btn = '0' then
-- 						state <= IDLE;
-- 					end if;
-- 					when CLEAN =>
-- 						accumulator <= (others => '0');
-- 						state <= IDLE;
-- 					when others =>
-- 						state <= IDLE;
-- 				end case;
-- 			end if;
-- 		end if;
-- 	end process;

--     HX0: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(3 downto 0),
--             dp => '0',
--             hex => HEX0
--         );

-- 	HX1: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(7 downto 4),
--             dp => '0',
--             hex => HEX1
--         );

-- 	HX2: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(11 downto 8),
--             dp => '0',
--             hex => HEX2
--         );

-- 	HX3: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(15 downto 12),
--             dp => '0',
--             hex => HEX3
--         );

-- 	HX4: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(19 downto 16),
--             dp => '0',
--             hex => HEX4
--         );

-- 	HX5: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(23 downto 20),
--             dp => '0',
--             hex => HEX5
--         );

-- 	LEDR <= SW;
-- 	add_btn <= not KEY(1);
-- 	rstn_btn <= KEY(0);

-- end behave;

------------------------------
--
-- FIXED
--
-------------------------------
-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- use ieee.std_logic_unsigned.all;

-- entity FSM is
-- 	port (
-- 		ADC_CLK_10 : in std_logic;
-- 		MAX10_CLK1_50 : in std_logic;
-- 		MAX10_CLK2_50 : in std_logic;
--         HEX0 : out std_logic_vector(7 downto 0);
--         HEX1 : out std_logic_vector(7 downto 0);
--         HEX2 : out std_logic_vector(7 downto 0);
--         HEX3 : out std_logic_vector(7 downto 0);
--         HEX4 : out std_logic_vector(7 downto 0);
--         HEX5 : out std_logic_vector(7 downto 0);
-- 		KEY : in std_logic_vector(1 downto 0);
-- 		SW : in std_logic_vector(9 downto 0);
-- 		LEDR : out std_logic_vector(9 downto 0)
-- 	);
-- end FSM;

-- architecture behave of FSM is
-- 	type state_type is (IDLE, ACCUM, CLEAN);
-- 	signal state : state_type;
-- 	signal accumulator : std_logic_vector(23 downto 0);
-- 	signal rstn_btn : std_logic;
-- 	signal add_btn : std_logic;
-- 	signal sync_add_btn: std_logic;
-- begin

-- 	STATE_MACHINE_3 : process (MAX10_CLK1_50)
		
-- 	begin
-- 		if rising_edge(MAX10_CLK1_50) then
-- 			sync_add_btn <= add_btn;
-- 			if (rstn_btn = '0') then
-- 				state <= CLEAN;
-- 			else
-- 				case state is
-- 					when IDLE =>
-- 					if sync_add_btn = '1' then
-- 						accumulator <= accumulator + SW;
-- 						state <= ACCUM;
-- 					end if;
-- 					when ACCUM =>
-- 					if sync_add_btn = '0' then
-- 						state <= IDLE;
-- 					end if;
-- 					when CLEAN =>
-- 						accumulator <= (others => '0');
-- 						state <= IDLE;
-- 					when others =>
-- 						state <= IDLE;
-- 				end case;
-- 			end if;
-- 		end if;
-- 	end process;

--     HX0: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(3 downto 0),
--             dp => '0',
--             hex => HEX0
--         );

-- 	HX1: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(7 downto 4),
--             dp => '0',
--             hex => HEX1
--         );

-- 	HX2: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(11 downto 8),
--             dp => '0',
--             hex => HEX2
--         );

-- 	HX3: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(15 downto 12),
--             dp => '0',
--             hex => HEX3
--         );

-- 	HX4: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(19 downto 16),
--             dp => '0',
--             hex => HEX4
--         );

-- 	HX5: entity work.Seg_Decoder(rtl)
--         port map (
--             binary => accumulator(23 downto 20),
--             dp => '0',
--             hex => HEX5
--         );

-- 	LEDR <= SW;
-- 	add_btn <= not KEY(1);
-- 	rstn_btn <= KEY(0);

-- end behave;

------------------------------
--
-- 2 state machines async
--
-------------------------------
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--
--entity FSM is
--	port (
--		ADC_CLK_10 : in std_logic;
--		MAX10_CLK1_50 : in std_logic;
--		MAX10_CLK2_50 : in std_logic;
--        HEX0 : out std_logic_vector(7 downto 0);
--        HEX1 : out std_logic_vector(7 downto 0);
--        HEX2 : out std_logic_vector(7 downto 0);
--        HEX3 : out std_logic_vector(7 downto 0);
--        HEX4 : out std_logic_vector(7 downto 0);
--        HEX5 : out std_logic_vector(7 downto 0);
--		KEY : in std_logic_vector(1 downto 0);
--		SW : in std_logic_vector(9 downto 0);
--		LEDR : out std_logic_vector(9 downto 0)
--	);
--end FSM;
--
--architecture behave of FSM is
--	type state_type is (IDLE, ACCUM, CLEAN);
--	signal state : state_type;
--	signal next_state : state_type;
--	signal accumulator : std_logic_vector(23 downto 0);
--	signal rstn_btn : std_logic;
--	signal add_btn : std_logic;
--begin
--
--	NXT_STATE : process (MAX10_CLK1_50)
--		
--	begin
--		if rising_edge(MAX10_CLK1_50) then
--			if (rstn_btn = '0') then
--				state <= CLEAN;
--			else
--				state <= next_state;
--			end if;
--		end if;
--	end process;
--
--	COMBIN_STATE : process (state, add_btn)
--		
--	begin
--		case state is
--			when IDLE =>
--			if add_btn = '1' then
--				accumulator <= accumulator + SW;
--				next_state <= ACCUM;
--			end if;
--			when ACCUM =>
--			if add_btn = '0' then
--				next_state <= IDLE;
--			end if;
--			when CLEAN =>
--				accumulator <= (others => '0');
--				next_state <= IDLE;
--			when others =>
--				next_state <= IDLE;
--		end case;
--	end process;
--
--    HX0: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(3 downto 0),
--            dp => '0',
--            hex => HEX0
--        );
--
--	HX1: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(7 downto 4),
--            dp => '0',
--            hex => HEX1
--        );
--
--	HX2: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(11 downto 8),
--            dp => '0',
--            hex => HEX2
--        );
--
--	HX3: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(15 downto 12),
--            dp => '0',
--            hex => HEX3
--        );
--
--	HX4: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(19 downto 16),
--            dp => '0',
--            hex => HEX4
--        );
--
--	HX5: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(23 downto 20),
--            dp => '0',
--            hex => HEX5
--        );
--
--	LEDR <= SW;
--	add_btn <= not KEY(1);
--	rstn_btn <= KEY(0);
--
--end behave;

------------------------------
--
-- 2 state machines sync
--
---------------------------------
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--
--entity FSM is
--	port (
--		ADC_CLK_10 : in std_logic;
--		MAX10_CLK1_50 : in std_logic;
--		MAX10_CLK2_50 : in std_logic;
--        HEX0 : out std_logic_vector(7 downto 0);
--        HEX1 : out std_logic_vector(7 downto 0);
--        HEX2 : out std_logic_vector(7 downto 0);
--        HEX3 : out std_logic_vector(7 downto 0);
--        HEX4 : out std_logic_vector(7 downto 0);
--        HEX5 : out std_logic_vector(7 downto 0);
--		KEY : in std_logic_vector(1 downto 0);
--		SW : in std_logic_vector(9 downto 0);
--		LEDR : out std_logic_vector(9 downto 0)
--	);
--end FSM;
--
--architecture behave of FSM is
--	type state_type is (IDLE, ACCUM, CLEAN);
--	signal state : state_type;
--	signal next_state : state_type;
--	signal accumulator : std_logic_vector(23 downto 0);
--	signal rstn_btn : std_logic;
--	signal add_btn : std_logic;
--begin
--
--	NXT_STATE : process (MAX10_CLK1_50)
--		
--	begin
--		if rising_edge(MAX10_CLK1_50) then
--			if (rstn_btn = '0') then
--				state <= CLEAN;
--			else
--				state <= next_state;
--			end if;
--		end if;
--	end process;
--
--	COMBIN_STATE : process (MAX10_CLK1_50)
--		
--	begin
--		if rising_edge(MAX10_CLK1_50) then
--			case state is
--				when IDLE =>
--				if add_btn = '1' then
--					accumulator <= accumulator + SW;
--					next_state <= ACCUM;
--				end if;
--				when ACCUM =>
--				if add_btn = '0' then
--					next_state <= IDLE;
--				end if;
--				when CLEAN =>
--					accumulator <= (others => '0');
--					next_state <= IDLE;
--				when others =>
--					next_state <= IDLE;
--			end case;
--		end if;
--	end process;
--
--    HX0: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(3 downto 0),
--            dp => '0',
--            hex => HEX0
--        );
--
--	HX1: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(7 downto 4),
--            dp => '0',
--            hex => HEX1
--        );
--
--	HX2: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(11 downto 8),
--            dp => '0',
--            hex => HEX2
--        );
--
--	HX3: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(15 downto 12),
--            dp => '0',
--            hex => HEX3
--        );
--
--	HX4: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(19 downto 16),
--            dp => '0',
--            hex => HEX4
--        );
--
--	HX5: entity work.Seg_Decoder(rtl)
--        port map (
--            binary => accumulator(23 downto 20),
--            dp => '0',
--            hex => HEX5
--        );
--
--	LEDR <= SW;
--	add_btn <= not KEY(1);
--	rstn_btn <= KEY(0);
--
--end behave;