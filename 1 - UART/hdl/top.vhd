
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity top is
	
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		rstn : in std_logic;
		GPIO : inout std_logic_vector(35 downto 0);
		LEDR : out std_logic_vector(9 downto 0)
	);
end top;

architecture behave of top is
	type state_type is (s_IDLE, s_SEND);
	signal convert_state : state_type;
	signal rx_pin : std_logic;
	signal tx_pin : std_logic;
	signal rx_data_valid : std_logic;
	signal tx_data_valid : std_logic;
	signal tx_busy : std_logic;
	signal saved_byte : std_logic_vector(7 downto 0);
	signal received_byte : std_logic_vector(7 downto 0);

begin

	UART1: entity work.uart(rtl)
		generic map (
			-- clk_freq / BAUD = clks_per_bit
			-- 50MHz / 19200 = 2604
			clks_per_bit => 2604
		)
		port map (
			clk => MAX10_CLK1_50,
			-- rx
			rx_serial => rx_pin,
			rx_data_valid => rx_data_valid,
			rx_byte => received_byte,
			-- tx
			tx_serial => tx_pin,
			tx_data_valid =>tx_data_valid,
			tx_byte => saved_byte,
			tx_busy => tx_busy
		);

	p_TRANSLATE : process (MAX10_CLK1_50)
	begin
		if rstn = '0' then
			convert_state <= s_IDLE;
		elsif rising_edge(MAX10_CLK1_50) then
			case convert_state is
				when s_IDLE =>
					if rx_data_valid = '1' then
						convert_state <= s_SEND;
						tx_data_valid <= '1';

						if received_byte >= "01000001" and received_byte <= "01011010" then
							saved_byte <= received_byte + "00100000";
						elsif received_byte >= "01100001" and received_byte <= "01111010" then
							saved_byte <= received_byte - "00100000";
						else
							saved_byte <= "01000101";
						end if;
					else
						tx_data_valid <= '0';
					end if;

				when s_SEND =>
					tx_data_valid <= '0';
					if tx_busy = '0' then
						convert_state <= s_IDLE;
					end if;
			end case;
		end if;
	end process;

	rx_pin <= GPIO(0);
	GPIO(1) <= tx_pin;
	LEDR(0) <= tx_busy;
	LEDR(9 downto 1) <= (others => '0');
	
end behave;
