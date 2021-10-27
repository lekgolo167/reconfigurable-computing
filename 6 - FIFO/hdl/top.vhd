
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity top is
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
end top;

architecture behave of top is
	type state_type is (IDLE, STORE, HOLD, ACCUM);
	signal write_state : state_type;
	signal read_state : state_type;
	signal accumulator : std_logic_vector(23 downto 0);
	signal write_clk : std_logic;
	signal read_clk : std_logic;
	signal wr_en : std_logic;
	signal rd_en : std_logic;
	signal empty : std_logic;
	signal data : std_logic_vector(9 downto 0);
	signal num : std_logic_vector(2 downto 0);
	signal rstn_btn : std_logic;
	signal store_btn : std_logic;
begin

	WRITE_MACHINE : process (write_clk)
	begin
		store_btn <= not KEY(1);
		if rising_edge(write_clk) then
			case write_state is
				when IDLE =>
					wr_en <= '0';
					if store_btn = '1' then
						write_state <= STORE;
					end if;
				when STORE =>
					wr_en <= '1';
					write_state <= HOLD;
				when HOLD =>
					wr_en <= '0';
					if store_btn = '0' then
						write_state <= IDLE;
					end if;
				when others =>
					write_state <= IDLE;
			end case;
		end if;
	end process;
	
	READ_MACHINE : process (read_clk)
	begin
		if rstn_btn = '0' then
			accumulator <= (others => '0');
		elsif rising_edge(read_clk) then
			case read_state is
				when IDLE =>
					rd_en <= '0';
					if num >= 5 then
						rd_en <= '1';
						read_state <= ACCUM;
					end if;
				when ACCUM =>
					if empty = '1' then
						read_state <= IDLE;
					else
						rd_en <= '1';
						accumulator <= accumulator + data;
					end if;
				when others =>
					read_state <= IDLE;
			end case;
		end if;
	end process;
	
	FF0: entity work.FIFO(syn)
		port map (
			aclr => NOT rstn_btn,
			data => SW,
			rdclk	=> read_clk,
			rdreq	=> rd_en,
			wrclk	=> write_clk,
			wrreq	=> wr_en,
			q => data,
			rdempty => empty,
			rdusedw => num
		);
		
	PL0: entity work.PLL(syn)
		port map	(
			inclk0 => MAX10_CLK1_50,
			c0	=> write_clk,
			c1	=> read_clk
		);



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
	rstn_btn <= KEY(0);

end behave;
