----------------------------------------------------------------------------------
-- Company: AGH University of Science and Technology
-- Engineer: Dawid Dworak, Mateusz Owczarek
-- 
-- Module Name:  image_gen - Behavioral 
-- Project Name: flashinglights
-- Target Devices:  XC6SLX9
-- Description: Test RGB LED signal
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_gen is
  Port ( pixel_clock : in  STD_LOGIC;
			leds : out std_logic_vector(0 to 7);
         data : out std_logic_vector(0 to 24*25-1) -- MSB first
		);
end led_gen;

architecture Behavioral of led_gen is
   constant pure_red : STD_LOGIC_VECTOR(23 downto 0) := (23 downto 16 => '1', others => '0');
	constant pure_green : STD_LOGIC_VECTOR(23 downto 0) := (15 downto 8 => '1', others => '0');
	constant pure_blue : STD_LOGIC_VECTOR(23 downto 0) := (7 downto 0 => '1', others => '0');
	constant c1 : STD_LOGIC_VECTOR(24*25-1 downto 0) := (24*25-1 downto 24*25-8 => '1', 7 downto 0 => '1', others => '0');
	constant c2 : STD_LOGIC_VECTOR(24*25-1 downto 0) := (23 downto 16 => '1', 24*25-17 downto 24*25-24 => '1', others => '0');
	signal switch : unsigned(30 downto 0) := (others => '0');
	
begin
	process(pixel_clock)
		begin
		if rising_edge(pixel_clock) then
			switch <= switch+1;
			leds  <= STD_LOGIC_VECTOR(switch(switch'high-2 downto switch'high-9));
			if(switch(switch'high-2)='1') then
				data <= c1;
			else
				data <= c2;
			end if;
		end if;
	end process;
end Behavioral;