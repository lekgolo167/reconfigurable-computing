
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
	signal opcode : std_logic_vector(5 downto 0);
	signal operand_0 : std_logic_vector(31 downto 0);
	signal operand_1 : std_logic_vector(31 downto 0);
	signal immediate : std_logic_vector(31 downto 0);
	signal mem_data : std_logic_vector(31 downto 0);
	signal pc_counter_padded : std_logic_vector(31 downto 0);
	signal data_out : std_logic_vector(31 downto 0);
	signal sel_immediate : std_logic;
	signal sel_pc : std_logic;
	signal mem_wr_en : std_logic;
	signal branch_taken : std_logic;
	signal wr_en : std_logic;
	signal wr_addr : std_logic_vector(4 downto 0);
	signal wr_back_addr : std_logic_vector(4 downto 0);
	signal wr_back_en : std_logic;
	signal pc_counter : std_logic_vector(9 downto 0);
begin

	FTCH: entity work.DLX_Fetch(rtl)
		port map (
			clk => MAX10_CLK1_50,
			rstn => rstn_btn,
			-- inputs
			jump_addr => data_out(9 downto 0),
			branch_taken => branch_taken,
			-- outputs
			pc_counter => pc_counter,
			instruction => inst
		);

	DCD: entity work.DLX_Decode(rtl)
		port map (
			clk => MAX10_CLK1_50,
			instruction => inst,
			wr_en => wr_en,
			wr_addr => wr_addr,
			wr_data => data_out,
			pc_counter => pc_counter,
			operand_0 => operand_0,
			operand_1 => operand_1,
			immediate => immediate,
			sel_immediate => sel_immediate,
			sel_pc => sel_pc,
			inst_opcode => opcode,
			wr_back_addr => wr_back_addr,
			wr_back_en => wr_back_en,
			pc_counter_padded => pc_counter_padded
		);

		EXC: entity work.DLX_Execute(rtl)
		port map (
			clk => MAX10_CLK1_50,
			opcode => opcode,
			wr_en => wr_back_en,
			wr_addr => wr_back_addr,
			sel_pc => sel_pc,
			pc_counter => pc_counter_padded,
			operand_0 => operand_0,
			sel_immediate => sel_immediate,
			immediate => immediate,
			operand_1 => operand_1,
			mem_wr_en => mem_wr_en,
			mem_data => mem_data,
			wr_back_en => wr_en,
			wr_back_addr => wr_addr,
			branch_taken => branch_taken,
			data_out => data_out
		);

	rstn_btn <= KEY(0);
	GPIO(31 downto 0) <= mem_data;
	LEDR(0) <= mem_wr_en;
	
end behave;
