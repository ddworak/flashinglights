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
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity led_gen is
  Port ( pixel_clock : in  STD_LOGIC;
         data : out std_logic_vector(0 to 24*26-1) -- MSB first
		);
end led_gen;

architecture Behavioral of led_gen is
   constant pure_red : STD_LOGIC_VECTOR(23 downto 0) := (23 downto 16 => '1', others => '0');
	constant pure_green : STD_LOGIC_VECTOR(23 downto 0) := (15 downto 8 => '1', others => '0');
	constant pure_blue : STD_LOGIC_VECTOR(23 downto 0) := (7 downto 0 => '1', others => '0');
	signal wtf : std_logic_vector(0 to 24*26-1) := (others => '0');
	signal sw: integer range 0 to 2;
	
begin
	process(pixel_clock)
		begin
		if rising_edge(pixel_clock) then
			sw <= (sw+1);
		end if;
		for I in 1 to 26 loop
			case sw is
				when 0 => data(I*24-24 to I*24-1) <= pure_red;
				when 1 => data(I*24-24 to I*24-1) <= pure_green;
				when 2 => data(I*24-24 to I*24-1) <= pure_blue;
			end case;
		end loop;
	end process;
end Behavioral;

