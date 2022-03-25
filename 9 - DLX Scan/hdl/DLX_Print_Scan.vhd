library ieee, lpm, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use lpm.lpm_components.all;
use work.dlx_package.all;

entity DLX_Print_Scan is
	generic (
		g_UART_WIDTH : natural := 8;
		g_TXRX_DEPTH : natural := 16;
		g_DEPTH : natural := 64;
		g_FIFO_WIDTH : natural := c_DLX_WORD_WIDTH + 2;
		clks_per_bit : integer := 434
	);
	port
	(
		clk	: in std_logic;
		rstn : in std_logic;
		invalid : in std_logic;
		print_data : in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		op_code : in std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
		uart_rx : in std_logic;
		scan_data : out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		scan_valid : out std_logic;
		tx_led : out std_logic;
		uart_tx : out std_logic
	);
		
	end entity;
	
architecture rtl of DLX_Print_Scan is

	-- UART
	signal rx_data_valid : std_logic;
	signal tx_data_valid : std_logic;
	signal tx_busy : std_logic;
	signal tx_byte : std_logic_vector(g_UART_WIDTH-1 downto 0);
	signal received_byte : std_logic_vector(g_UART_WIDTH-1 downto 0);

begin
	tx_led <= tx_busy;

	PRNT: entity work.DLX_Print(rtl)
	generic map (
		g_UART_WIDTH => g_UART_WIDTH,
		g_TX_DEPTH => g_TXRX_DEPTH,
		g_DEPTH => g_DEPTH,
		g_FIFO_WIDTH => g_FIFO_WIDTH
	)
	port map (
		clk => clk,
		rstn => rstn,
		invalid => invalid,
		print_data => print_data,
		op_code => op_code,
		tx_busy => tx_busy,
		tx_data_valid => tx_data_valid,
		tx_byte => tx_byte
	);

	SCN: entity work.DLX_Scan(rtl)
	generic map (
		g_DEPTH => g_TXRX_DEPTH,
		g_UART_WIDTH => g_UART_WIDTH
	)
	port map (
		clk => clk,
		rstn => rstn,
		rx_data_valid => rx_data_valid,
		rx_byte => received_byte,
		scan_valid => scan_valid,
		scan_data => scan_data
	);

	UART1: entity work.uart(rtl)
	generic map (
		-- clk_freq / BAUD = clks_per_bit
		-- 50MHz / 19200 = 2604
		clks_per_bit => clks_per_bit
	)
	port map (
		clk => clk,
		-- rx
		rx_serial => uart_rx,
		rx_data_valid => rx_data_valid,
		rx_byte => received_byte,
		-- tx
		tx_serial => uart_tx,
		tx_data_valid => tx_data_valid,
		tx_byte => tx_byte,
		tx_busy => tx_busy
	);

end rtl;
