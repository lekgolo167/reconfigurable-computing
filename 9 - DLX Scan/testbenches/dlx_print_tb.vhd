library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dlx_package.all;

entity dlx_print_tb is
end dlx_print_tb;

architecture behave of dlx_print_tb is

	constant c_CLK_PERIOD : time := 10 ns;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal print_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0) := x"00000021";
	signal scan_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal op_code : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
	signal tx_busy : std_logic;
	signal scan_valid : std_logic;
	signal tx : std_logic;
	signal rx : std_logic;

	-- stimuli
	signal counter : natural := 0;

	constant c_CLKS_PER_BIT : integer := 5;
	
	constant c_BIT_PERIOD : time := 50 ns;

	  -- Low-level byte-write
	  procedure UART_WRITE_BYTE (
		i_data_in       : in  std_logic_vector(7 downto 0);
		signal o_serial : out std_logic) is
	  begin
	 
		-- Send Start Bit
		o_serial <= '0';
		wait for c_BIT_PERIOD;
	 
		-- Send Data Byte
		for ii in 0 to 7 loop
		  o_serial <= i_data_in(ii);
		  wait for c_BIT_PERIOD;
		end loop;  -- ii
	 
		-- Send Stop Bit
		o_serial <= '1';
		wait for c_BIT_PERIOD;
	  end UART_WRITE_BYTE;

begin
	-- generate clock
	clk <= not clk after c_CLK_PERIOD/2;

	process is
	begin
	reset <= '1' after c_CLK_PERIOD*10;
	
	wait until reset = '1';

	-- send the string number 1234
	wait until rising_edge(clk);
	UART_WRITE_BYTE(x"31", rx);
	wait for c_CLK_PERIOD*15;
	wait until rising_edge(clk);
	UART_WRITE_BYTE(x"32", rx);
	wait for c_CLK_PERIOD*15;
	wait until rising_edge(clk);
	UART_WRITE_BYTE(x"33", rx);
	wait for c_CLK_PERIOD*15;
	wait until rising_edge(clk);
	UART_WRITE_BYTE(x"34", rx);
	wait for c_CLK_PERIOD*15;
	-- send enter key
	wait until rising_edge(clk);
	UART_WRITE_BYTE(x"0D", rx);
	wait for c_CLK_PERIOD*15;
	wait until rising_edge(clk);
	UART_WRITE_BYTE(x"0A", rx);
	wait for c_CLK_PERIOD*15;
	end process;
	
	-- device under test
	DLX: entity work.DLX_Print_Scan(rtl)
		generic map (
			clks_per_bit => c_CLKS_PER_BIT
		)
		port map (
			clk => clk,
			rstn => reset,
			invalid => '0',
			print_data => print_data,
			uart_rx => rx,
			scan_data => scan_data,
			scan_valid => scan_valid,
			op_code => op_code,
			tx_led => tx_busy,
			uart_tx => tx
		);

	GEN_DATA : process(clk)
	begin
	if rising_edge(clk) then
		if counter = 50 then
			counter <= 0;
			op_code <= c_DLX_PCH;
			print_data <= print_data + '1';
		else
			op_code <= c_DLX_NOP;
			counter <= counter + 1;
		end if;
	end if;
	end process;
end behave;