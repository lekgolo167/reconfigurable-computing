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
	signal op_code : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
	signal tx_busy : std_logic;
	signal tx : std_logic;

	-- stimuli
	signal counter : natural := 0;
begin
	-- generate clock
	clk <= not clk after c_CLK_PERIOD/2;
	reset <= '1' after c_CLK_PERIOD*10;

	-- device under test
	DLX: entity work.DLX_Print_Scan(rtl)
		port map (
			clk => clk,
			rstn => reset,
			print_data => print_data,
uart_rx => '1',
			op_code => op_code,
			tx_busy => tx_busy,
			uart_tx => tx
		);

	GEN_DATA : process(clk)
	begin
	if rising_edge(clk) then
		if counter = 10 then
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