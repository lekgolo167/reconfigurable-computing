
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
	generic (
        -- clk_freq / BAUD = clks_per_bit
        clks_per_bit : integer := 11
    );
	port (
		clk : in std_logic;
		-- rx
		rx_serial : in std_logic;
		rx_data_valid : out std_logic;
		rx_byte : out std_logic_vector(7 downto 0);
		-- tx
		tx_serial : out std_logic;
		tx_busy : out std_logic;
		tx_data_valid : in std_logic;
		tx_byte : in std_logic_vector(7 downto 0)
	);
end uart;

architecture rtl of uart is
	type state_type is (s_IDLE, s_START_BIT, s_DATA_BITS, s_STOP_BIT);
	signal tx_state : state_type;
	signal rx_state : state_type;
	-- rx
	signal rx_data_raw : std_logic;
	signal rx_data : std_logic;
	signal rx_clock_count : integer range 0 to clks_per_bit-1 := 0;
	signal rx_bit_index : integer range 0 to 7 := 0;
	-- tx
	signal tx_data : std_logic_vector(7 downto 0);
	signal tx_clock_count : integer range 0 to clks_per_bit-1 := 0;
	signal tx_bit_index : integer range 0 to 7 := 0;
begin

	-- double-register incoming data to synchronize it to this clock domain
	-- removes metastability
	p_SYNC : process (clk)
	begin
		if rising_edge(clk) then
			rx_data_raw <= rx_serial;
			rx_data <= rx_data_raw;
		end if;
	end process;

	------------------------------
	-- RX PROCESS
	------------------------------

	p_RX : process (clk)
	begin
		if rising_edge(clk) then
			case rx_state is
				when s_IDLE =>
					rx_data_valid <= '0';
					rx_clock_count <= 0;
					rx_bit_index <= 0;

					if rx_data = '0' then -- start bit detected
						rx_state <= s_START_BIT;
					end if;

				when s_START_BIT =>
					if rx_clock_count = ((clks_per_bit-1)/2) then -- count to the middle of the stop bit
						if rx_data = '0' then -- still low = valid start bit
							rx_clock_count <= 0;
							rx_state <= s_DATA_BITS;
						else -- bad stop bit go back to IDLE
							rx_state <= s_IDLE;
						end if;
					else
						rx_clock_count <= rx_clock_count + 1;
					end if;

				when s_DATA_BITS =>
					if rx_clock_count < clks_per_bit - 1 then
						rx_clock_count <= rx_clock_count + 1;
					else
						rx_clock_count <= 0;
						rx_byte(rx_bit_index) <= rx_data; -- save the bit
						
						if rx_bit_index < 7 then -- check how many bits have been saved
							rx_bit_index <= rx_bit_index + 1;
						else
							rx_bit_index <= 0;
							rx_state <= s_STOP_BIT;
						end if;
					end if;

				when s_STOP_BIT =>
					if rx_clock_count < clks_per_bit - 1 then
						rx_clock_count <= rx_clock_count + 1;
					else
						rx_data_valid <= '1';
						rx_state <= s_IDLE;
					end if;

				when others =>
						rx_state <= s_IDLE;

			end case;
		end if;
	end process;

	------------------------------
	-- TX PROCESS
	------------------------------

	p_TX : process (clk)
	begin
		if rising_edge(clk) then
			case tx_state is
				when s_IDLE =>
					tx_serial <= '1';
					tx_busy <= '0';
					tx_clock_count <= 0;
					tx_bit_index <= 0;

					if tx_data_valid = '1' then
						tx_busy <= '1';
						tx_data <= tx_byte;
						tx_state <= s_START_BIT;
					end if;

				when s_START_BIT =>
					tx_serial <= '0';

					if tx_clock_count < clks_per_bit - 1 then
						tx_clock_count <= tx_clock_count + 1;
					else
						tx_clock_count <= 0;
						tx_state <= s_DATA_BITS;
					end if;

				when s_DATA_BITS =>
					tx_serial <= tx_data(tx_bit_index);

					if tx_clock_count < clks_per_bit - 1 then
						tx_clock_count <= tx_clock_count + 1;
					else
						tx_clock_count <= 0;

						if tx_bit_index < 7 then
							tx_bit_index <= tx_bit_index + 1;
						else
							tx_bit_index <= 0;
							tx_state <= s_STOP_BIT;
						end if;
					end if;

				when s_STOP_BIT =>
					tx_serial <= '1';

					if tx_clock_count < clks_per_bit - 1 then
						tx_clock_count <= tx_clock_count + 1;
					else
						tx_state <= s_IDLE;
					end if;

				when others =>
					tx_state <= s_IDLE;

			end case;
		end if;
	end process;
end rtl;
