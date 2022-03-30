library ieee, lpm, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use lpm.lpm_components.all;
use work.dlx_package.all;

entity DLX_Scan is
	generic (
		g_DEPTH : natural := 16;
		g_UART_WIDTH : natural := 8
	);
	port
	(
		clk	: in std_logic;
		clk_io	: in std_logic;
		rstn : in std_logic;
		rx_data_valid : in std_logic;
		rx_byte : in std_logic_vector(g_UART_WIDTH-1 downto 0);
		scan_valid : out std_logic;
		scan_data : out std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0)
	);
		
	end entity;
	
architecture rtl of DLX_Scan is

	component LPM_MULT
        generic ( LPM_WIDTHA : natural; 
			LPM_WIDTHB : natural;
			LPM_WIDTHS : natural := 1;
			LPM_WIDTHP : natural;
			LPM_REPRESENTATION : string := "UNSIGNED";
			LPM_PIPELINE : natural := 0;
			LPM_TYPE: string := L_MULT;
			LPM_HINT : string := "UNUSED");
		port ( DATAA : in std_logic_vector(LPM_WIDTHA-1 downto 0);
			DATAB : in std_logic_vector(LPM_WIDTHB-1 downto 0);
			ACLR : in std_logic := '0';
			CLOCK : in std_logic := '0';
			CLKEN : in std_logic := '1';
			SUM : in std_logic_vector(LPM_WIDTHS-1 downto 0) := (OTHERS => '0');
			RESULT : out std_logic_vector(LPM_WIDTHP-1 downto 0));
	end component;

	-- multiplyer
	signal mult_result : std_logic_vector((c_DLX_WORD_WIDTH * 2)-1 downto 0);
	signal mult_accum : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	
	
	-- 2's complelent
	signal twos_complement : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal data_out : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);

	-- FIFO
	-- write
	signal fifo_full : std_logic;
	signal fifo_wr_en : std_logic;
	-- read
	signal fifo_empty : std_logic;
	signal fifo_rd_en : std_logic;
	signal fifo_rd_data : std_logic_vector(g_UART_WIDTH-1 downto 0);
	signal fifo_wr_data : std_logic_vector(g_UART_WIDTH-1 downto 0);

	-- State Machine
	type state_type is (s_IDLE, s_READ, s_SAVE, s_MULT, s_ADD);
	signal scan_state : state_type;
	signal mult_en : std_logic;
	signal is_negative : std_logic;
	signal number_char : std_logic;
	signal escape_char : std_logic;

	signal is_valid : std_logic;
	signal is_valid_dly : std_logic;

begin
	
	twos_complement <= (not mult_accum) + '1';
	data_out <= mult_accum when is_negative = '0' else twos_complement;
	
	scan_valid <= is_valid and not is_valid_dly;
	process(clk)
	begin
		if(rising_edge(clk)) then
			is_valid_dly <= is_valid;
		end if;
	end process;
	process(clk_io)
	begin
		if(rising_edge(clk_io)) then
			if mult_en = '1' then
				mult_accum <= mult_result(c_DLX_WORD_WIDTH-1 downto 0) + fifo_rd_data;
			else
				mult_accum <= (others => '0');
			end if;
			scan_data <= data_out;
		end if;
	end process;
	
	number_char <= '1' when rx_byte >= x"30" and rx_byte <= x"39" else '0';
	escape_char <= '1' when rx_byte = x"0A" or rx_byte = x"0D" else '0';

	process(clk_io)
	begin
		if(rising_edge(clk_io)) then
			case scan_state is
				when s_IDLE =>
					if rx_data_valid = '1' then
						if rx_byte = x"2D" then
							is_negative <= '1';
							scan_state <= s_READ;
						elsif number_char = '1' then
							scan_state <= s_READ;
							fifo_wr_en <= '1';
						end if;
					else
						scan_state <= s_IDLE;
						is_negative <= '0';
						is_valid <= '0';
						mult_en <= '0';
						fifo_rd_en <= '0';
						fifo_wr_en <= '0';
					end if;

				when s_READ =>
					if escape_char = '1' then
						scan_state <= s_MULT;
						mult_en <= '1';
					elsif rx_data_valid = '1' then
						if number_char = '1' then
							fifo_wr_en <= '1';
							scan_state <= s_SAVE;
						elsif (number_char = '0' or fifo_full = '1') then
							scan_state <= s_IDLE;
						end if;
					else
						fifo_wr_en <= '0';
						scan_state <= s_READ;
					end if;

				when s_SAVE =>
					scan_state <= s_READ;
					fifo_wr_en <= '0';
					
				when s_MULT =>
					fifo_rd_en <= '1';
					if fifo_empty = '1' then
						is_valid <= '1';
						scan_state <= s_IDLE;
					else
						scan_state <= s_ADD;
					end if;
					
				when s_ADD =>
					scan_state <= s_MULT;
					fifo_rd_en <= '0';
					
				when others =>
					scan_state <= s_IDLE;
			end case;
		end if;
	end process;

	fifo_wr_data <= rx_byte - x"30";
	SCAN_BUF: entity work.FIFO(rtl)
		generic map (
			g_WIDTH => g_UART_WIDTH,
			g_DEPTH => g_DEPTH
		)
		port map (
			clk => clk_io,
			rstn => rstn,
			full => fifo_full,
			wr_en => fifo_wr_en,
			wr_data => fifo_wr_data,
			empty => fifo_empty,
			rd_en => fifo_rd_en and not fifo_empty,
			rd_data => fifo_rd_data
	);

	MUL: component LPM_MULT
		generic	map (
			LPM_WIDTHA => c_DLX_WORD_WIDTH,
			LPM_WIDTHB => c_DLX_WORD_WIDTH,
			LPM_WIDTHP => c_DLX_WORD_WIDTH * 2,
			LPM_PIPELINE => 1
		)
		port map (
			clock => clk_io,
			clken => '1',
			aclr => not rstn,
			dataa => x"0000000A",
			datab => mult_accum,
			result => mult_result
		);

end rtl;
