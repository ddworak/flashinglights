----------------------------------------------------------------------------------
-- Company: AGH University of Science and Technology
-- Engineer: Dawid Dworak
-- 
-- Create Date:    18:00:55 11/11/2015 
-- Module Name:    flashing_top - Behavioral 
-- Project Name: 
-- Target Devices:  XC6SLX9
-- Description: Top module for the project
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity flashinglights is
    Port ( clk50 : in  STD_LOGIC;
           leds : out  STD_LOGIC_VECTOR (7 downto 0));
end flashinglights;

architecture Behavioral of flashinglights is
	signal count : unsigned(30 downto 0) := (others => '0');
begin

process(clk50)
   begin
      if rising_edge(clk50) then
         count <= count+1;
         leds  <= STD_LOGIC_VECTOR(count(count'high-2 downto count'high-9));      
      end if;
   end process;

end Behavioral;