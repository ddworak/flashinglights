----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:40:22 12/06/2015 
-- Design Name: 
-- Module Name:    led_gen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


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
	constant wtf1 : STD_LOGIC_VECTOR(24*25-1 downto 0) := (24*25-1 downto 24*25-8 => '1', 7 downto 0 => '1', others => '0');
	constant wtf2 : STD_LOGIC_VECTOR(24*25-1 downto 0) := (23 downto 16 => '1', 24*25-17 downto 24*25-24 => '1', others => '0');
	signal wtf : unsigned(30 downto 0) := (others => '0');
	
begin
	process(pixel_clock)
		begin
		if rising_edge(pixel_clock) then
			wtf <= wtf+1;
			leds  <= STD_LOGIC_VECTOR(wtf(wtf'high-2 downto wtf'high-9));
			if(wtf(wtf'high-2)='1') then
				data <= wtf1;
			else
				data <= wtf2;
			end if;
		end if;
	end process;
end Behavioral;