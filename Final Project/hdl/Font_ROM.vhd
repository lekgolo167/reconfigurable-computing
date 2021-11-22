library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Font_ROM is
    port(
        addr: in std_logic_vector(8 downto 0);
        data: out std_logic_vector(0 to 7)
    );
end Font_ROM;

architecture content of Font_ROM is
    type rom_type is array(0 to 511) of std_logic_vector(7 downto 0);
	
    constant FONT: rom_type :=
    (
		-- 0
		"00111000", --   ###
		"01001100", --  #  ##
		"11000110", -- ##   ##
		"11000110", -- ##   ##
		"11000110", -- ##   ##
		"01100100", --  ##  #
		"00111000", --   ###
		"00000000", --
		-- 1
		"00011000", --    ##
		"00111000", --   ###
		"00011000", --    ##
		"00011000", --    ##
		"00011000", --    ##
		"00011000", --    ##
		"01111110", --  ######
		"00000000", --
		-- 2
		"01111100", --  #####
		"11000110", -- ##   ##
		"00001110", --     ###
		"00111100", --   ####
		"01111000", --  ####
		"11100000", -- ###
		"11111110", -- #######
		"00000000", --
		-- 3
		"01111110", --  ######
		"00001100", --     ##
		"00011000", --    ##
		"00111100", --   ####
		"00000110", --      ##
		"11000110", -- ##   ##
		"01111100", --  #####
		"00000000", --
		-- 4
		"00011100", --    ###
		"00111100", --   ####
		"01101100", --  ## ##
		"11001100", -- ##  ##
		"11111110", -- #######
		"00001100", --     ##
		"00001100", --     ##
		"00000000", --
		-- 5
		"11111100", -- ######
		"11000000", -- ##
		"11111100", -- ######
		"00000110", --      ##
		"00000110", --      ##
		"11000110", -- ##   ##
		"01111100", --  #####
		"00000000", --
		-- 6
		"00111100", --   ####
		"01100000", --  ##
		"11000000", -- ##
		"11111100", -- ######
		"11000110", -- ##   ##
		"11000110", -- ##   ##
		"01111100", --  #####
		"00000000", --
		-- 7
		"11111110", -- #######
		"11000110", -- ##   ##
		"00001100", --     ##
		"00011000", --    ##
		"00110000", --   ##
		"00110000", --   ##
		"00110000", --   ##
		"00000000", --
		-- 8
		"01111000", --  ####
		"11000100", -- ##   #
		"11100100", -- ###  #
		"01111000", --  ####
		"10011110", -- #  ####
		"10000110", -- #    ##
		"01111100", --  #####
		"00000000", --
		-- 9
		"01111100", --  #####
		"11000110", -- ##   ##
		"11000110", -- ##   ##
		"01111110", --  ######
		"00000110", --      ##
		"00001100", --     ##
		"01111000", --  ####
		"00000000", --
        -- 10
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        -- 11
        "00111000", --   ###
        "00111000", --   ###
        "00111000", --   ###
        "00110000", --   ##
        "00110000", --   ##
        "00000000", --
        "00110000", --   ##
        "00000000", --
        -- 12
        "00101000", --   # #
        "00101000", --   # #
        "00101000", --   # #
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        -- 13
        "01000100", --  #   #
        "11111110", -- #######
        "01000100", --  #   #
        "01000100", --  #   #
        "01000100", --  #   #
        "11111110", -- #######
        "01000100", --  #   #
        "00000000", --
        -- 14
        "00010000", --    #
        "01111110", --  ######
        "10010000", -- #  #
        "01111100", --  #####
        "00010010", --    #  #
        "11111100", -- ######
        "00010000", --    #
        "00000000", --
        -- 15
        "11000000", -- ##
        "11001000", -- ##  #
        "00010000", --    #
        "00100000", --   #
        "01000000", --  #
        "10011000", -- #  ##
        "00011000", --    ##
        "00000000", --
        -- 16
        "00110000", --   ##
        "01001000", --  #  #
        "01101000", --  ## #
        "01110000", --  ###
        "10011010", -- #  ## #
        "10001100", -- #   ##
        "01111010", --  #### #
        "00000000", --
        -- 17
        "01100000", --  ##
        "01100000", --  ##
        "00100000", --   #
        "01000000", --  #
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        -- 18
        "00001100", --     ##
        "00010000", --    #
        "00100000", --   #
        "00100000", --   #
        "00100000", --   #
        "00010000", --    #
        "00001100", --     ##
        "00000000", --
        -- 19
        "00110000", --   ##
        "00001000", --     #
        "00000100", --      #
        "00000100", --      #
        "00000100", --      #
        "00001000", --     #
        "00110000", --   ##
        "00000000", --
        -- 20
        "00000000", --
        "00010000", --    #
        "01010100", --  # # #
        "00111000", --   ###
        "01010100", --  # # #
        "00010000", --    #
        "00000000", --
        "00000000", --
        -- 21
        "00000000", --
        "00010000", --    #
        "00010000", --    #
        "01111100", --  #####
        "00010000", --    #
        "00010000", --    #
        "00000000", --
        "00000000", --
        -- 22
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00110000", --   ##
        "00110000", --   ##
        "01100000", --  ##
        "00000000", --
        -- 23
        "00000000", --
        "00000000", --
        "00000000", --
        "01111100", --  #####
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        -- 24
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00110000", --   ##
        "00110000", --   ##
        "00000000", --
        -- 25
        "00000010", --       #
        "00000100", --      #
        "00001000", --     #
        "00010000", --    #
        "00100000", --   #
        "01000000", --  #
        "10000000", -- #
        "00000000", --
        -- 26
        "00000000", --
        "00110000", --   ##
        "00110000", --   ##
        "00000000", --
        "00110000", --   ##
        "00110000", --   ##
        "00000000", --
        "00000000", --
        -- 27
        "00000000", --
        "00110000", --   ##
        "00110000", --   ##
        "00000000", --
        "00110000", --   ##
        "00110000", --   ##
        "01100000", --  ##
        "00000000", --
        -- 28
        "00001000", --     #
        "00010000", --    #
        "00100000", --   #
        "01000000", --  #
        "00100000", --   #
        "00010000", --    #
        "00001000", --     #
        "00000000", --
        -- 29
        "00000000", --
        "00000000", --
        "01111100", --  #####
        "00000000", --
        "01111100", --  #####
        "00000000", --
        "00000000", --
        "00000000", --
        -- 30
        "00100000", --   #
        "00010000", --    #
        "00001000", --     #
        "00000100", --      #
        "00001000", --     #
        "00010000", --    #
        "00100000", --   #
        "00000000", --
        -- 31
        "01111100", --  #####
        "11111110", -- #######
        "11000110", -- ##   ##
        "00001100", --     ##
        "00111000", --   ###
        "00000000", --
        "00111000", --   ###
        "00000000", --
        -- 32
        "00111000", --   ###
        "01000100", --  #   #
        "10010100", -- #  # #
        "10101100", -- # # ##
        "10011000", -- #  ##
        "01000000", --  #
        "00111100", --   ####
        "00000000", --
        -- 33
        "00111000", --   ###
        "01101100", --  ## ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11111110", -- #######
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "00000000", --
        -- 34
        "11111100", -- ######
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11111100", -- ######
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11111100", -- ######
        "00000000", --
        -- 35
        "00111100", --   ####
        "01100110", --  ##  ##
        "11000000", -- ##
        "11000000", -- ##
        "11000000", -- ##
        "01100110", --  ##  ##
        "00111100", --   ####
        "00000000", --
        -- 36
        "11111000", -- #####
        "11001100", -- ##  ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11001100", -- ##  ##
        "11111000", -- #####
        "00000000", --
        -- 37
        "11111110", -- #######
        "11000000", -- ##
        "11000000", -- ##
        "11111100", -- ######
        "11000000", -- ##
        "11000000", -- ##
        "11111110", -- #######
        "00000000", --
        -- 38
        "11111110", -- #######
        "11000000", -- ##
        "11000000", -- ##
        "11111100", -- ######
        "11000000", -- ##
        "11000000", -- ##
        "11000000", -- ##
        "00000000", --
        -- 39
        "00111110", --   #####
        "01100000", --  ##
        "11000000", -- ##
        "11001110", -- ##  ###
        "11000110", -- ##   ##
        "01100110", --  ##  ##
        "00111110", --   #####
        "00000000", --
        -- 40
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11111110", -- #######
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "00000000", --
        -- 41
        "01111110", --  ######
        "00011000", --    ##
        "00011000", --    ##
        "00011000", --    ##
        "00011000", --    ##
        "00011000", --    ##
        "01111110", --  ######
        "00000000", --
        -- 42
        "00011110", --    ####
        "00001100", --     ##
        "00001100", --     ##
        "00001100", --     ##
        "00001100", --     ##
        "10001100", -- #   ##
        "01111000", --  ####
        "00000000", --
        -- 43
        "11000110", -- ##   ##
        "11001100", -- ##  ##
        "11011000", -- ## ##
        "11110000", -- ####
        "11111000", -- #####
        "11011100", -- ## ###
        "11001110", -- ##  ###
        "00000000", --
        -- 44
        "01100000", --  ##
        "01100000", --  ##
        "01100000", --  ##
        "01100000", --  ##
        "01100000", --  ##
        "01100000", --  ##
        "01111110", --  ######
        "00000000", --
        -- 45
        "11000110", -- ##   ##
        "11101110", -- ### ###
        "11111110", -- #######
        "11111110", -- #######
        "11010110", -- ## # ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "00000000", --
        -- 46
        "11000110", -- ##   ##
        "11100110", -- ###  ##
        "11110110", -- #### ##
        "11111110", -- #######
        "11011110", -- ## ####
        "11001110", -- ##  ###
        "11000110", -- ##   ##
        "00000000", --
        -- 47
        "01111100", --  #####
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "01111100", --  #####
        "00000000", --
        -- 48
        "11111100", -- ######
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11111100", -- ######
        "11000000", -- ##
        "11000000", -- ##
        "00000000", --
        -- 49
        "01111100", --  #####
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11011110", -- ## ####
        "11001100", -- ##  ##
        "01111010", --  #### #
        "00000000", --
        -- 50
        "11111100", -- ######
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11001110", -- ##  ###
        "11111000", -- #####
        "11011100", -- ## ###
        "11001110", -- ##  ###
        "00000000", --
        -- 51
        "01111000", --  ####
        "11001100", -- ##  ##
        "11000000", -- ##
        "01111100", --  #####
        "00000110", --      ##
        "11000110", -- ##   ##
        "01111100", --  #####
        "00000000", --
        -- 52
        "01111110", --  ######
        "00011000", --    ##
        "00011000", --    ##
        "00011000", --    ##
        "00011000", --    ##
        "00011000", --    ##
        "00011000", --    ##
        "00000000", --
        -- 53
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "01111100", --  #####
        "00000000", --
        -- 54
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11101110", -- ### ###
        "01111100", --  #####
        "00111000", --   ###
        "00010000", --    #
        "00000000", --
        -- 55
        "11000110", -- ##   ##
        "11000110", -- ##   ##
        "11010110", -- ## # ##
        "11111110", -- #######
        "11111110", -- #######
        "11101110", -- ### ###
        "11000110", -- ##   ##
        "00000000", --
        -- 56
        "11000110", -- ##   ##
        "11101110", -- ### ###
        "01111100", --  #####
        "00111000", --   ###
        "01111100", --  #####
        "11101110", -- ### ###
        "11000110", -- ##   ##
        "00000000", --
        -- 57
        "01100110", --  ##  ##
        "01100110", --  ##  ##
        "01100110", --  ##  ##
        "00111100", --   ####
        "00011000", --    ##
        "00011000", --    ##
        "00011000", --    ##
        "00000000", --
        -- 58
        "11111110", -- #######
        "00001110", --     ###
        "00011100", --    ###
        "00111000", --   ###
        "01110000", --  ###
        "11100000", -- ###
        "11111110", -- #######
        "00000000", --
        -- 59
        "00111100", --   ####
        "00110000", --   ##
        "00110000", --   ##
        "00110000", --   ##
        "00110000", --   ##
        "00110000", --   ##
        "00111100", --   ####
        "00000000", --
        -- 60
        "00100000", --   #
        "00110000", --   ##
        "00111000", --   ###
        "00111100", --   ####
        "00111000", --   ###
        "00110000", --   ##
        "00100000", --   #
        "00000000", --
        -- 61
        "00111100", --   ####
        "00001100", --     ##
        "00001100", --     ##
        "00001100", --     ##
        "00001100", --     ##
        "00001100", --     ##
        "00111100", --   ####
        "00000000", --
        -- 62
        "00100000", --   #
        "01010000", --  # #
        "10001000", -- #   #
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        -- 63
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "00000000", --
        "11111110", -- #######
        "00000000" --
    );
begin
    data <= FONT(conv_integer(addr));
end content;