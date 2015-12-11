----------------------------------------------------------------------------------
-- Company: AGH University of Science and Technology
-- Engineer: Dawid Dworak, Mateusz Owczarek
-- 
-- Module Name:  analyser - Behavioral 
-- Project Name: flashinglights
-- Target Devices:  XC6SLX9
-- Description: Color analyser generating framebuffers for RGB leds
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity analyser is
    Port ( 
      clk_pixel : IN std_logic;
		sw 		 : IN std_logic;
		i_red     : IN std_logic_vector(7 downto 0);
		i_green   : IN std_logic_vector(7 downto 0);
		i_blue    : IN std_logic_vector(7 downto 0);
		i_blank   : IN std_logic;
		i_hsync   : IN std_logic;
		i_vsync   : IN std_logic;          

		framebuffer : OUT std_logic_vector(0 to 25*24-1); --25 LED * 3 RGB * 8B
		
		o_red     : OUT std_logic_vector(7 downto 0);
		o_green   : OUT std_logic_vector(7 downto 0);
		o_blue    : OUT std_logic_vector(7 downto 0);
		o_blank   : OUT std_logic;
		o_hsync   : OUT std_logic;
		o_vsync   : OUT std_logic);  
end analyser;

architecture Behavioral of analyser is

   signal red     : std_logic_vector(7 downto 0);
	signal green   : std_logic_vector(7 downto 0);
	signal blue    : std_logic_vector(7 downto 0);
	signal blank   : std_logic;
	signal hsync   : std_logic;
	signal vsync   : std_logic;  

   --screen position   
   signal x : STD_LOGIC_VECTOR (11 downto 0);
   signal y : STD_LOGIC_VECTOR (11 downto 0);

	constant blocks : integer := 25;	

   type t_accumulator is array (0 to blocks-1, 0 to 3) of std_logic_vector(21 downto 0);
   signal accumulator : t_accumulator; 
	
	type t_coords is array (0 to blocks-1) of integer;
	constant xstart : t_coords := (  0,  0,  0,  0,  0,0,144,288,432,576,720,864,1008,1152,1152,1152,1152,1152,1152,987,823,658,494,329,164);
	constant ystart : t_coords := (592,472,356,238,118,0,  0,  0,  0,  0,  0,  0,   0,   0, 118, 238, 356, 472, 592,592,592,592,592,592,592);		
	
	type gamma_type is array (0 to 255) of std_logic_vector(7 downto 0);
	constant gamma_lut : gamma_type := (
		X"01", X"01", X"01", X"01", X"01", X"01", X"01", X"01", X"01", X"01", X"01", X"01", X"01", X"01",
		X"01", X"01", X"01", X"01", X"01", X"01", X"01", X"01", X"02", X"02", X"02", X"02", X"02", X"02",
		X"02", X"02", X"02", X"02", X"02", X"03", X"03", X"03", X"03", X"03", X"03", X"03", X"03", X"04",
		X"04", X"04", X"04", X"04", X"05", X"05", X"05", X"05", X"05", X"06", X"06", X"06", X"06", X"06",
		X"07", X"07", X"07", X"08", X"08", X"08", X"08", X"09", X"09", X"09", X"0A", X"0A", X"0A", X"0B",
		X"0B", X"0B", X"0C", X"0C", X"0D", X"0D", X"0D", X"0E", X"0E", X"0F", X"0F", X"0F", X"10", X"10",
		X"11", X"11", X"12", X"12", X"13", X"13", X"14", X"14", X"15", X"15", X"16", X"17", X"17", X"18",
		X"18", X"19", X"19", X"1A", X"1B", X"1B", X"1C", X"1D", X"1D", X"1E", X"1F", X"1F", X"20", X"21",
		X"21", X"22", X"23", X"24", X"24", X"25", X"26", X"27", X"28", X"28", X"29", X"2A", X"2B", X"2C",
		X"2D", X"2D", X"2E", X"2F", X"30", X"31", X"32", X"33", X"34", X"35", X"36", X"37", X"38", X"39",
		X"3A", X"3B", X"3C", X"3D", X"3E", X"3F", X"40", X"41", X"42", X"43", X"44", X"46", X"47", X"48",
		X"49", X"4A", X"4B", X"4D", X"4E", X"4F", X"50", X"51", X"53", X"54", X"55", X"57", X"58", X"59",
		X"5A", X"5C", X"5D", X"5F", X"60", X"61", X"63", X"64", X"66", X"67", X"68", X"6A", X"6B", X"6D",
		X"6E", X"70", X"71", X"73", X"74", X"76", X"78", X"79", X"7B", X"7C", X"7E", X"80", X"81", X"83",
		X"85", X"86", X"88", X"8A", X"8B", X"8D", X"8F", X"91", X"92", X"94", X"96", X"98", X"9A", X"9B",
		X"9D", X"9F", X"A1", X"A3", X"A5", X"A7", X"A9", X"AB", X"AD", X"AF", X"B1", X"B3", X"B5", X"B7",
		X"B9", X"BB", X"BD", X"BF", X"C1", X"C3", X"C5", X"C7", X"CA", X"CC", X"CE", X"D0", X"D2", X"D5",
		X"D7", X"D9", X"DB", X"DE", X"E0", X"E2", X"E4", X"E7", X"E9", X"EC", X"EE", X"F0", X"F3", X"F5",
		X"F8", X"FA", X"FD", X"FF");	

begin

process(clk_pixel)
	variable edge : std_logic := '0'; --debug
   begin
      if rising_edge(clk_pixel) then
				   					
			for b in 0 to blocks-1 loop
				if unsigned(x) >= xstart(b) and unsigned(x) < xstart(b)+128 and
						unsigned(y) >= ystart(b) and unsigned(y) < ystart(b)+128 then
					accumulator(b,0) <= std_logic_vector(unsigned(accumulator(b,0)) + unsigned(red));
					accumulator(b,1) <= std_logic_vector(unsigned(accumulator(b,1)) + unsigned(green));
					accumulator(b,2) <= std_logic_vector(unsigned(accumulator(b,2)) + unsigned(blue));
				end if;
			end loop;
		

			-- debug, mark blocks in blue
			edge := '0';
			for b in 0 to blocks-1 loop
				if ((unsigned(x) = xstart(b) or unsigned(x) = xstart(b)+128) and (unsigned(y) >= ystart(b) and unsigned(y) <= ystart(b)+128)) or
						((unsigned(y) = ystart(b) or unsigned(y) = ystart(b)+128) and (unsigned(x) >= xstart(b) and unsigned(x) <= xstart(b)+128)) then
					edge := '1';
				end if;
			end loop;
         
			if edge = '0' or sw = '0' then
				o_red     <= red;
				o_green   <= green;
				o_blue    <= blue;
			else
				o_red     <= X"00";
				o_green   <= X"00";
				o_blue    <= X"FF";
			end if;
			
         o_blank   <= blank;
         o_hsync   <= hsync;
         o_vsync   <= vsync;

         red     <= i_red;
         green   <= i_green;
         blue    <= i_blue;
         blank   <= i_blank;
         hsync   <= i_hsync;
         vsync   <= i_vsync;


         if i_vsync /= vsync then
            y <= (others => '0');
							
				if i_vsync = '1' then
					for i in 0 to blocks-1 loop
						for c in 0 to 2 loop
							framebuffer(c * 8 + i * 24 to i * 24 + c * 8 + 7) <= gamma_lut(to_integer(unsigned(accumulator(i,c)(21 downto 14))));
							accumulator(i,c) <= (others => '0');
						end loop;
					end loop;
				end if;						
         end if;

         if i_blank = '0' then
            x <= std_logic_vector(unsigned(x) + 1);
         end if;

         if blank = '0' and i_blank = '1' then
            y <= std_logic_vector(unsigned(y) + 1);
            x <= (others => '0');
         end if;

      end if;
   end process;
end Behavioral;
