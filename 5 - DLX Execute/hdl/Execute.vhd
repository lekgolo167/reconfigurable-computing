
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Execute is
	
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		SW : inout std_logic_vector(9 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		GPIO : inout std_logic_vector(35 downto 0)
	);
end Execute;

architecture behave of Execute is
	signal rstn_btn : std_logic;
	signal inst : std_logic_vector(31 downto 0);
	signal mux_out : std_logic_vector(31 downto 0);
	signal d1 : std_logic_vector(31 downto 0);
	signal d2 : std_logic_vector(31 downto 0);
	signal d3 : std_logic_vector(31 downto 0);
	signal d4 : std_logic_vector(31 downto 0);
	signal sel : std_logic_vector(1 downto 0);
	signal sel_immediate : std_logic;
	signal sel_pc : std_logic;
	signal wr_addr_out : std_logic_vector(4 downto 0);
	signal pc_counter : std_logic_vector(9 downto 0);
begin

	FTCH: entity work.DLX_Fetch(rtl)
		port map (
			clk => MAX10_CLK1_50,
			rstn => rstn_btn,
			-- inputs
			jump_addr => inst(9 downto 0),
			branch_taken => SW(0),
			-- outputs
			pc_counter => pc_counter,
			instruction => inst
		);

	DCD: entity work.DLX_Execute(rtl)
		port map (
			clk => MAX10_CLK1_50,
			instruction => inst,
			wr_en => SW(1),
			wr_addr => SW(6 downto 2),
			wr_data => inst,
			operand_0 => d1,
			operand_1 => d2,
			immediate => d3,
			sel_immediate => sel_immediate,
			pc_counter => pc_counter,
			pc_counter_padded => open,
			sel_pc => sel_pc,
			wr_addr_out => wr_addr_out,
			inst_opcode => d4(5 downto 0)
		);

	mux_out <= d1 when sel = "00" else d2 when sel = "01" else d3 when sel = "10" else d4;
	rstn_btn <= KEY(0);
	GPIO(31 downto 0) <= mux_out;
	sel <= SW(8 downto 7);
	
end behave;
