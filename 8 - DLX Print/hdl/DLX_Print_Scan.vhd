library ieee, lpm, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use lpm.lpm_components.all;
use work.dlx_package.all;

entity DLX_Print_Scan is
	generic (
		g_UART_WIDTH : natural := 8;
		g_TX_DEPTH : natural := 16;
		g_DEPTH : natural := 64
	)
	port
	(
		clk	: in std_logic;
		rstn : in std_logic;
		print_data : in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		uart_rx : in std_logic;
		tx_busy : out std_logic;
		uart_tx : out std_logic
	);
		
	end entity;
	
architecture rtl of DLX_Print_Scan is
	-- divider
	signal numer : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal quotient : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);

	-- FIFO
	-- write
	signal fifo_full : std_logic;
	signal fifo_wr_en : std_logic;
	-- read
	signal fifo_empty : std_logic;
	signal fifo_rd_en : std_logic;
	signal fifo_rd_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);

	-- LIFO
	-- write
	signal lifo_full : std_logic;
	signal lifo_wr_en : std_logic;
	signal lifo_wr_data : std_logic_vector(g_UART_WIDTH-1 downto 0);
	-- read
	signal lifo_empty : std_logic;
	signal lifo_rd_en : std_logic;

	-- UART
	signal rx_data_valid : std_logic;
	signal tx_data_valid : std_logic;
	signal tx_byte : std_logic_vector(g_UART_WIDTH-1 downto 0);
	signal received_byte : std_logic_vector(g_UART_WIDTH-1 downto 0);

begin

	process(clk, rstn)
	begin
		if rstn = '0' then
		elsif(rising_edge(clk)) then
		end if;
	end process;

	PRINT_BUF: entity work.FIFO(rtl)
		generic map (
			g_WIDTH => c_DLX_WORD_WIDTH,
			g_DEPTH => g_DEPTH
		)
		port map (
			clk => clk,
			rstn => rstn,
			full => fifo_full,
			wr_en => fifo_wr_en,
			wr_data => print_data,
			empty => fifo_empty,
			rd_en => fifo_rd_en,
			rd_data => fifo_rd_data
	);

	numer <= fifo_rd_data when else quotient;
	DIV: entity lpm.LPM_DIVIDE
	generic	map (
		LPM_WIDTHN => c_DLX_WORD_WIDTH,
		LPM_WIDTHD => g_UART_WIDTH,
		LPM_PIPELINED => 1
	)
	port map (
		clock => ,
		clken => '1',
		aclr => rstn,
		numer => numer,
		denom => std_logic_vector(to_unsigned(10, g_UART_WIDTH)),
		quotient => quotient,
		remain => lifo_wr_data,
	);

	TX_BUF: entity work.LIFO(rtl)
	generic map (
		g_WIDTH => g_UART_WIDTH,
		g_DEPTH => g_TX_DEPTH
	)
	port map (
		clk => clk,
		rstn => rstn,
		full => lifo_full,
		wr_en => lifo_wr_en,
		wr_data => lifo_wr_data,
		empty => lifo_empty,
		rd_en => lifo_rd_en,
		rd_data => tx_byte
	);

	tx_data_valid <= not lifo_empty;

	UART1: entity work.uart(rtl)
	generic map (
		-- clk_freq / BAUD = clks_per_bit
		-- 50MHz / 19200 = 2604
		clks_per_bit => 2604
	)
	port map (
		clk => clk,
		-- rx
		rx_serial => uart_rx,
		rx_data_valid => rx_data_valid,
		rx_byte => received_byte,
		-- tx
		tx_serial => uart_tx,
		tx_start => lifo_rd_en,
		tx_data_valid =>tx_data_valid,
		tx_byte => tx_byte,
		tx_busy => tx_busy
	);

end rtl;
