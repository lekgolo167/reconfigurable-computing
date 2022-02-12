library ieee, work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.dlx_package.all;

entity decode_stage_tb is
end decode_stage_tb;

architecture behave of decode_stage_tb is

	constant c_CLK_PERIOD : time := 10 ns;

	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	-- inputs for fetch
	signal branch_taken : std_logic := '0';
	signal jump_addr : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0) := (others => '0');
	
	-- inputs for decode
	signal wr_en : std_logic := '0';
	signal wr_addr : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0) := (others => '0');
	signal wr_data : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0) := (others => '0');
	
	-- outputs for fetch/ inputs for decode
	signal pc_to_decode : std_logic_vector(c_DLX_PC_WIDTH-1 downto 0);
	signal instruction : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	
	-- outputs for decode/ inputs for execute
	signal operand_0 : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal operand_1 : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal immediate : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	signal sel_immediate : std_logic;
	signal sel_pc : std_logic;
	signal inst_opcode : std_logic_vector(c_DLX_OPCODE_WIDTH-1 downto 0);
	signal wr_addr_out : std_logic_vector(c_DLX_REG_ADDR_WIDTH-1 downto 0);
	signal pc_to_execute : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0);
	
	-- variables for simulating fetch
	signal loop_counter : natural := 0;
	signal func_counter : natural := 0;
	signal took_jal : std_logic := '0';
	signal took_bnez : std_logic := '0';
	signal jal_counter : natural := 0;
	
	-- variables for simulating decode
	signal data_to_write : std_logic_vector(c_DLX_WORD_WIDTH-1 downto 0) := x"00000001";

begin
	-- generate clock
	clk <= not clk after c_CLK_PERIOD/2;
	reset <= '1' after c_CLK_PERIOD*4;

	-- device under test
	FTCH: entity work.DLX_Fetch(rtl)
		port map (
			clk => clk,
			rstn => reset,
			branch_taken => branch_taken,
			jump_addr => jump_addr,
			pc_counter => pc_to_decode,
			instruction => instruction
		);
	DCD: entity work.DLX_Decode(rtl)
		port map (
			clk => clk,
			instruction => instruction,
			wr_en => wr_en,
			wr_addr => wr_addr,
			wr_data => wr_data,
			pc_counter => pc_to_decode,
			operand_0 => operand_0,
			operand_1 => operand_1,
			immediate => immediate,
			sel_immediate => sel_immediate,
			sel_pc => sel_pc,
			inst_opcode => inst_opcode,
			wr_addr_out => wr_addr_out,
			pc_counter_padded => pc_to_execute
		);
	

			
		-- Simulate all of the jump and loop states for the fetch stage
		fetch_TEST : process(clk)
		begin
		if rising_edge(clk) then
			if instruction(31 downto 26) = "101101" and took_jal = '0' then  -- if instruction == J
				jump_addr(9 downto 0) <= instruction(9 downto 0);
				branch_taken <= '1';
			elsif (instruction(31 downto 26) = "101100") and (loop_counter < 1) then  -- else if instruction == BNEZ
				jump_addr(9 downto 0) <= instruction(9 downto 0);
				branch_taken <= '1';
				took_bnez <= '1';
				loop_counter <= loop_counter + 1;
			elsif (instruction(31 downto 26) = "101011") and (func_counter >= 1) then  -- else if instruction == BEQZ
				jump_addr(9 downto 0) <= instruction(9 downto 0);
				branch_taken <= '1';
			elsif instruction(31 downto 26) = "101111" and (jal_counter < 1) then  -- else if instruction == JAL
				jump_addr(9 downto 0) <= instruction(9 downto 0);
				branch_taken <= '1';
				func_counter <= func_counter + 1;
				took_jal <= '1';
				jal_counter <= 1;
			elsif instruction(31 downto 26) = "101110" and took_bnez = '0' then  -- else if instruction == JR
				jump_addr(9 downto 0) <= "0000000011";  -- jump back to address 0x005
				branch_taken <= '1';
				loop_counter <= 0;
			else
				branch_taken <= '0';
				took_jal <= '0';
				took_bnez <= '0';
			end if;
		end if;
		end process;

		decode_TEST : process(clk)
		begin
		if rising_edge(clk) then
			if ((inst_opcode >= c_DLX_LW) and (inst_opcode <= c_DLX_SNEI)) then
				wr_en <= '1';
				wr_addr <= wr_addr_out;
				wr_data <= wr_data + data_to_write;
			elsif inst_opcode >= c_DLX_JAL then
				wr_en <= '1';
				wr_addr <= "11111";
				wr_data <= pc_to_execute;
			else
				wr_en <='0';
			end if;
		end if;
		end process;
		
end behave;
