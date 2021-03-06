----------------------------------------------------------------------------------
-- Company: AGH University of Science and Technology
-- Engineer: Dawid Dworak, Mateusz Owczarek
-- 
-- Module Name:  image_gen - Behavioral 
-- Project Name: flashinglights
-- Target Devices:  XC6SLX9
-- Description: Test 720p signal generator with optional animation
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity image_gen is
    Port ( clk50           : in  STD_LOGIC;
		     move 				: in STD_LOGIC;
			  pixel_clock     : out STD_LOGIC;
			  

           red    : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
           green   : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
           blue    : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
           blank   : out STD_LOGIC := '0';
           hsync   : out STD_LOGIC := '0';
           vsync   : out STD_LOGIC := '0'
			  );
end image_gen;

architecture Behavioral of image_gen is
	COMPONENT image_clocks
	PORT( clk50           : IN  std_logic;          
         pixel_clock     : OUT std_logic);
	END COMPONENT;

	--todo
   constant h_rez        : natural := 1280;
   constant h_sync_start : natural := 1280+72;
   constant h_sync_end   : natural := 1280+72+80;
   constant h_max        : natural := 1647; -- max vertical blanking area in 720p@60Hz is 370 (could be 1649)
   signal   h_count      : unsigned(11 downto 0) := (others => '0');
   signal   h_offset     : unsigned(7 downto 0) := (others => '0');

   constant v_rez        : natural := 720;
   constant v_sync_start : natural := 720+3;
   constant v_sync_end   : natural := 720+3+5;
   constant v_max        : natural := 749; -- max vertical blanking area in 720p is 30
   signal   v_count      : unsigned(11 downto 0) := (others => '0');
   signal   v_offset     : unsigned(7 downto 0) := (others => '0');
   signal clk75 : std_logic;
begin

i_clocks: image_clocks PORT MAP(
		clk50           => clk50,
		pixel_clock     => clk75
	);
   pixel_clock <= clk75;

   
process(clk75)
   begin
      if rising_edge(clk75) then
         if h_count < h_rez and v_count < v_rez then
				blank   <= '0';
				red     <= std_logic_vector(h_count(7 downto 0)+h_offset);
				green   <= std_logic_vector(v_count(7 downto 0)+v_offset);
				blue    <= std_logic_vector(h_count(7 downto 0)+v_count(7 downto 0));
         else
            red     <= (others => '0');
            green   <= (others => '0');
            blue    <= (others => '0');
            blank   <= '1';
         end if;

         if h_count >= h_sync_start and h_count < h_sync_end then
            hsync <= '1';
         else
            hsync <= '0';
         end if;
         
         if v_count >= v_sync_start and v_count < v_sync_end then
            vsync <= '1';
         else
            vsync <= '0';
         end if;
         
         if h_count = h_max then
            h_count <= (others => '0');
            if v_count = v_max then
					if move = '1' then
						h_offset <= h_offset + 1;
						v_offset <= v_offset + 1;
					end if;
               v_count <= (others => '0');
            else
               v_count <= v_count+1;
            end if;
         else
            h_count <= h_count+1;
         end if;

      end if;
   end process;

end Behavioral;

