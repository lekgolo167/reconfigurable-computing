library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity VGA is
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		VGA_B : out std_logic_vector(3 downto 0);
		VGA_G : out std_logic_vector(3 downto 0);
		VGA_R : out std_logic_vector(3 downto 0);
		VGA_HS : out std_logic;
		VGA_VS : out std_logic
	);
end VGA;


architecture behave of VGA is
	signal rstn_btn : std_logic;
	signal next_btn : std_logic;
	signal vga_clk : std_logic;
	constant hs_count_max : natural := 800;
	constant hs_porch_max : natural := 160;
	signal hs_count : natural := 0;
	constant vs_count_max : natural := 416800;
	constant vs_porch_max : natural := 32800;
	signal vs_count : natural := 0;
	signal vs : std_logic;
begin

	p_hs_count : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			if vs = '1' then
				if hs_count >= hs_count_max then
					hs_count <= 0;
				elsif hs_count < hs_porch_max then
					hs_count <= hs_count + 1;
					VGA_HS <= '0';
					VGA_R <= (others => '0');
				else
					hs_count <= hs_count + 1;
					VGA_HS <= '1';
					VGA_R <= (others => '1');
				end if;
			else
				hs_count <= 0;
				VGA_HS <= '0';
				VGA_R <= (others => '0');
			end if;
		end if;
	end process;
	
	p_vs_count : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			if vs_count >= vs_count_max then
				vs_count <= 0;
			elsif vs_count < vs_porch_max then
				vs_count <= vs_count + 1;
				vs <= '0';
			else
				vs_count <= vs_count + 1;
				vs <= '1';
			end if;
		end if;
	end process;
	
	rstn_btn <= KEY(0);
--	VGA_R <= (others => '0');
	VGA_B <= (others => '0');
	VGA_G <= (others => '0');
	VGA_VS <= vs;
	PL0: entity work.PLL(syn)
	port map	(
		inclk0 => MAX10_CLK1_50,
		c0	=> vga_clk
	);
end behave;



















