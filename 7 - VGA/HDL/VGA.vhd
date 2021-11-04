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
	signal vga_x : natural;
	signal vga_y : natural;
begin

	p_hs_count : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			if vga_x < 200 then
				VGA_R <= (others => '1');
				VGA_B <= (others => '0');
				VGA_G <= (others => '0');
			elsif vga_x < 440 then
				VGA_R <= (others => '1');
				VGA_B <= (others => '1');
				VGA_G <= (others => '1');
			elsif vga_x < 640 then
				VGA_R <= (others => '0');
				VGA_B <= (others => '1');
				VGA_G <= (others => '0');
			else
				VGA_R <= (others => '0');
				VGA_B <= (others => '0');
				VGA_G <= (others => '0');
			end if;
		end if;
	end process;
	
	rstn_btn <= KEY(0);
	next_btn <= KEY(1);

	VG0: entity work.VGA_Sync(behave)
	port map (
		vga_clk => vga_clk,
		rstn => rstn_btn,
		vga_hs => VGA_HS,
		vga_x => vga_x,
		vga_vs => VGA_VS,
		vga_y => vga_y
	);

	PL0: entity work.PLL(syn)
	port map (
		inclk0 => MAX10_CLK1_50,
		c0	=> vga_clk
	);

end behave;



















