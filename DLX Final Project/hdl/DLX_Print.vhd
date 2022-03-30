library ieee, lpm, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use lpm.lpm_components.all;
use work.dlx_package.all;

entity DLX_Print is
	generic (
		g_UART_WIDTH : natural := 8;
		g_TX_DEPTH : natural := 16;
		g_DEPTH : natural := 64;
		g_FIFO_WIDTH : natural := 34
	);
	port
	(
		clk	: in std_logic;
		clk_io	: in std_logic;
		rstn : in std_logic;
		invalid : in std_logic;
		print_data : in std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
		op_code : in std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
		tx_busy : in std_logic;
		tx_data_valid : out std_logic;
		tx_byte : out std_logic_vector(g_UART_WIDTH-1 downto 0)
	);
		
	end entity;
	
architecture rtl of DLX_Print is

	component LPM_DIVIDE
		generic (LPM_WIDTHN : natural;
			LPM_WIDTHD : natural;
			LPM_NREPRESENTATION : string := "UNSIGNED";
			LPM_DREPRESENTATION : string := "UNSIGNED";
			LPM_PIPELINE : natural := 0;
			LPM_TYPE : string := L_DIVIDE;
			LPM_HINT : string := "UNUSED");
		port (NUMER : in std_logic_vector(LPM_WIDTHN-1 downto 0);
			DENOM : in std_logic_vector(LPM_WIDTHD-1 downto 0);
			ACLR : in std_logic := '0';
			CLOCK : in std_logic := '0';
			CLKEN : in std_logic := '1';
			QUOTIENT : out std_logic_vector(LPM_WIDTHN-1 downto 0);
			REMAIN : out std_logic_vector(LPM_WIDTHD-1 downto 0));
	end component;
	
	-- 2's complelent
	signal twos_complement : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal data_in : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	-- divider
	signal div_input : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal quotient : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal cmd : std_logic_vector(1 downto 0);
	signal is_negative : std_logic;
	signal sign_bit : std_logic;
	signal div_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);

	-- FIFO
	-- write
	signal fifo_full : std_logic;
	signal fifo_wr_en : std_logic;
	-- read
	signal fifo_empty : std_logic;
	signal fifo_rd_en : std_logic;
	signal fifo_rd_data : std_logic_vector(g_FIFO_WIDTH-1 downto 0);
	signal fifo_wr_data : std_logic_vector(g_FIFO_WIDTH-1 downto 0);

	-- LIFO
	-- write
	signal lifo_full : std_logic;
	signal lifo_wr_en : std_logic;
	signal lifo_wr_data : std_logic_vector(g_UART_WIDTH-1 downto 0);
	signal div_char : std_logic_vector(g_UART_WIDTH-1 downto 0);
	-- read
	signal lifo_empty : std_logic;
	signal lifo_rd_en : std_logic;
	
	-- State Machine
	type state_type is (s_IDLE, s_READ, s_CHAR, s_SIGNED, s_DIVIDE, s_DELAY, s_POP, s_WAIT);
	signal print_state : state_type;
	signal lifo_in_sel : std_logic;

begin
	twos_complement <= (not fifo_rd_data(31 downto 0)) + '1';
	data_in <= twos_complement when (fifo_rd_data(33 downto 32) = c_DLX_PD(1 downto 0) and fifo_rd_data(3) = '1') else fifo_rd_data(31 downto 0);
	process(clk)
	begin
		if(rising_edge(clk)) then
			if op_code >= c_DLX_PCH and op_code <= c_DLX_PDU and invalid = '0' then
				fifo_wr_data <= op_code(1 downto 0) & print_data;
				fifo_wr_en <= not fifo_full;
			else
				fifo_wr_en <= '0';
			end if;
		end if;
	end process;
	
	process(clk_io)
	begin
		if(rising_edge(clk_io)) then
			case print_state is
				when s_IDLE =>
					if fifo_empty = '0' then
						fifo_rd_en <= '1';
						div_data <= data_in;
						sign_bit <= fifo_rd_data(31);
						cmd <= fifo_rd_data(33 downto 32);
						print_state <= s_READ;
					else
						fifo_rd_en <= '0';
						print_state <= s_IDLE;
					end if;	
					
				when s_READ =>
					fifo_rd_en <= '0';
					if cmd = c_DLX_PCH(1 downto 0) then
						print_state <= s_CHAR;
					else
						print_state <= s_DIVIDE;
						lifo_wr_en <= '1';
						if cmd = c_DLX_PD(1 downto 0) then
							is_negative <= sign_bit;
						else
							is_negative <= '0';
						end if;
					end if;
					
				when s_CHAR =>
					print_state <= s_DELAY;
					lifo_in_sel <= '1';
					lifo_wr_en <= '1';
				
				when s_SIGNED =>
				    lifo_wr_en <= '0';
					print_state <= s_DELAY;
					
				when s_DIVIDE =>
					if quotient = x"00000000" then
						if is_negative = '1' then
							print_state <= s_SIGNED;
						else
							lifo_wr_en <= '0';
							print_state <= s_DELAY;
						end if;
					else 
						lifo_wr_en <= '1';
						print_state <= s_DIVIDE;
					end if;

				when s_DELAY =>
					lifo_wr_en <= '0';
					lifo_in_sel <= '0';
					print_state <= s_POP;

				when s_POP =>
					lifo_rd_en <= '1';
					tx_data_valid <= '0';
					if lifo_empty = '1' and tx_busy = '0' then
						print_state <= s_IDLE;
					else
						print_state <= s_WAIT;
					end if;

				when s_WAIT =>
					lifo_rd_en <= '0';
					tx_data_valid <= '1';
					if lifo_empty = '0' and tx_busy = '0' then
						print_state <= s_POP;
					elsif lifo_empty = '1' and tx_busy = '0' then
						tx_data_valid <= '0';
						print_state <= s_IDLE;
					end if;
					
				when others =>
					print_state <= s_IDLE;
			end case;
		end if;
	end process;

	PRINT_BUF: entity work.FIFO(rtl)
		generic map (
			g_WIDTH => g_FIFO_WIDTH,
			g_DEPTH => g_DEPTH
		)
		port map (
			clk => clk,
			rstn => rstn,
			full => fifo_full,
			wr_en => fifo_wr_en,
			wr_data => fifo_wr_data,
			empty => fifo_empty,
			rd_en => fifo_rd_en,
			rd_data => fifo_rd_data
	);

	div_input <= div_data when fifo_rd_en = '1' else quotient;
	
	DIV: component LPM_DIVIDE
	generic	map (
		LPM_WIDTHN => c_DLX_WORD_WIDTH,
		LPM_WIDTHD => g_UART_WIDTH,
		LPM_PIPELINE => 1
	)
	port map (
		clock => clk_io,
		clken => '1',
		aclr => not rstn,
		numer => div_input,
		denom => std_logic_vector(to_unsigned(10, g_UART_WIDTH)),
		quotient => quotient,
		remain => div_char
	);
 
	lifo_wr_data <= div_data(7 downto 0) when lifo_in_sel = '1' else x"2D" when (print_state = s_SIGNED) else div_char + x"30";
	
	TX_BUF: entity work.LIFO(rtl)
	generic map (
		g_WIDTH => g_UART_WIDTH,
		g_DEPTH => g_TX_DEPTH
	)
	port map (
		clk => clk_io,
		rstn => rstn,
		full => lifo_full,
		wr_en => lifo_wr_en,
		wr_data => lifo_wr_data,
		empty => lifo_empty,
		rd_en => lifo_rd_en,
		rd_data => tx_byte
	);

end rtl;
