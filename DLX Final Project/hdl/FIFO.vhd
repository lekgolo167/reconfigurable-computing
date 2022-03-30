-------------------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
--
-- Description: Creates a Synchronous FIFO made out of registers.
--              Generic: g_WIDTH sets the width of the FIFO created.
--              Generic: g_DEPTH sets the depth of the FIFO created.
--
--              Total FIFO register usage will be width * depth
--              Note that this fifo should not be used to cross clock domains.
--              (Read and write clocks NEED TO BE the same clock domain)
--
--              FIFO Full Flag will assert as soon as last word is written.
--              FIFO Empty Flag will assert as soon as last word is read.
--
--              FIFO is 100% synthesizable.  It uses assert statements which do
--              not synthesize, but will cause your simulation to crash if you
--              are doing something you shouldn't be doing (reading from an
--              empty FIFO or writing to a full FIFO).
--
--              No Flags = No Almost Full (AF)/Almost Empty (AE) Flags
--              There is a separate module that has programmable AF/AE flags.
-------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity FIFO is
  generic (
    g_WIDTH : natural := 8;
    g_DEPTH : integer := 32
    );
  port (
	  clk  : in std_logic;
	  rstn : in std_logic;
 
    -- FIFO Write Interface
    wr_en   : in  std_logic;
    wr_data : in  std_logic_vector(g_WIDTH-1 downto 0);
    full    : out std_logic;
 
    -- FIFO Read Interface
    rd_en   : in  std_logic;
    rd_data : out std_logic_vector(g_WIDTH-1 downto 0);
    empty   : out std_logic
    );
end FIFO;
 
architecture rtl of FIFO is
 
  type t_FIFO_DATA is array (0 to g_DEPTH-1) of std_logic_vector(g_WIDTH-1 downto 0);
  signal r_FIFO_DATA : t_FIFO_DATA := (others => (others => '0'));
 
  signal r_WR_INDEX   : integer range 0 to g_DEPTH-1 := 0;
  signal r_RD_INDEX   : integer range 0 to g_DEPTH-1 := 0;
 
  -- # Words in FIFO, has extra range to allow for assert conditions
  signal r_FIFO_COUNT : integer range -1 to g_DEPTH+1 := 0;
 
  signal w_FULL  : std_logic;
  signal w_EMPTY : std_logic;
   
  signal read_en : std_logic;
  signal read_en_dly : std_logic;
begin

  process (clk)
  begin
    if rising_edge(clk) then
      read_en_dly <= rd_en;
    end if;
  end process;

  read_en <= rd_en and not read_en_dly;

  p_CONTROL : process (clk, rstn) is
  begin
	if rstn = '0' then
		r_FIFO_COUNT <= 0;
		r_WR_INDEX   <= 0;
		r_RD_INDEX   <= 0;
    elsif rising_edge(clk) then
        -- Keeps track of the total number of words in the FIFO
        if (wr_en = '1' and read_en = '0') then
          r_FIFO_COUNT <= r_FIFO_COUNT + 1;
        elsif (wr_en = '0' and read_en = '1') then
          r_FIFO_COUNT <= r_FIFO_COUNT - 1;
        end if;
 
        -- Keeps track of the write index (and controls roll-over)
        if (wr_en = '1' and w_FULL = '0') then
          if r_WR_INDEX = g_DEPTH-1 then
            r_WR_INDEX <= 0;
          else
            r_WR_INDEX <= r_WR_INDEX + 1;
          end if;
        end if;
 
        -- Keeps track of the read index (and controls roll-over)        
        if (read_en = '1' and w_EMPTY = '0') then
          if r_RD_INDEX = g_DEPTH-1 then
            r_RD_INDEX <= 0;
          else
            r_RD_INDEX <= r_RD_INDEX + 1;
          end if;
        end if;
 
        -- Registers the input data when there is a write
        if wr_en = '1' then
          r_FIFO_DATA(r_WR_INDEX) <= wr_data;
        end if;
         
    end if;                             -- rising_edge(clk)
  end process p_CONTROL;
   
  rd_data <= r_FIFO_DATA(r_RD_INDEX);
 
  w_FULL  <= '1' when r_FIFO_COUNT = g_DEPTH else '0';
  w_EMPTY <= '1' when r_FIFO_COUNT = 0       else '0';
 
  full  <= w_FULL;
  empty <= w_EMPTY;

end rtl;