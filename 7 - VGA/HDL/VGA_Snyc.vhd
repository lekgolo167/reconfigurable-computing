library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity VGA_Sync is
	port (
		vga_clk : in std_logic;
		rstn : in std_logic;
		vga_hs : out std_logic;
		vga_x : out natural;
		vga_vs : out std_logic;
		vga_y : out natural
	);
end VGA_Sync;


architecture behave of VGA_Sync is
	
	constant hs_count_max : natural := 800;
	constant hs_disp : natural := 640;
	constant hs_fp : natural := 18;
	constant hs_sync : natural := 92;
	constant hs_bp : natural := 50;
	signal hs_count : natural := 0;
	
	constant vs_count_max : natural := 420000;
	constant vs_disp : natural := 480;
	constant vs_fp : natural := 10;
	constant vs_sync : natural := 12;
	constant vs_bp : natural := 33;
	signal vs_count : natural := 0;

begin

	p_hs_count : process (vga_clk)
	begin
		if rstn = '0' then
			hs_count <= 0;
		elsif rising_edge(vga_clk) then
			if hs_count >= hs_count_max-1 then
				hs_count <= 0;
			else
				hs_count <= hs_count + 1;				
			end if;
		end if;
	end process;
	
	p_hs : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			if hs_count > hs_disp + hs_fp and hs_count < hs_count_max - hs_bp then
				vga_hs <= '0';
			else
				vga_hs <= '1';
			end if;
		end if;
	end process;
	
	p_vs_count : process (vga_clk)
	begin
		if rstn = '0' then
			vs_count <= 0;
		elsif rising_edge(vga_clk) then
			if vs_count >= vs_count_max-1 then
				vs_count <= 0;
			else
				vs_count <= vs_count + 1;
			end if;
		end if;
	end process;
	
	p_vs : process (vga_clk)
	begin
		if rising_edge(vga_clk) then
			if vs_count > vs_disp + vs_fp and vs_count < vs_count_max - vs_bp then
				vga_vs <= '0';
			else
				vga_vs <= '1';
			end if;
		end if;
	end process;

	vga_x <= hs_count;
	vga_y <= vs_count;

end behave;
