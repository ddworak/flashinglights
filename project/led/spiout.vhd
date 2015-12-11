----------------------------------------------------------------------------------
-- Company: AGH University of Science and Technology
-- Engineer: Dawid Dworak, Mateusz Owczarek
-- 
-- Module Name:  spiout - Behavioral 
-- Project Name: flashinglights
-- Target Devices:  XC6SLX9
-- Description: SPI output for RGB leds
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spiout is
    Port ( clk50 : in  STD_LOGIC;
           data : in std_logic_vector(0 to 24*25-1); --25 LED * 3 RGB * 8B
           MOSI : out  STD_LOGIC;
           SCK : out  STD_LOGIC);
end spiout;

architecture Behavioral of spiout is
signal sck_counter    : std_logic_vector(15 downto 0);
signal sck_s : std_logic;
signal sck_enable : std_logic := '1';
signal wrcnt: std_logic_vector(9 downto 0) := (others => '0');

begin
process(clk50,sck_counter,sck_enable)
	begin
		if (falling_edge(clk50)) then
			sck_counter <= sck_counter + 1;
		end if;
 	   sck_s <= sck_counter(11);
	end process;
		
process(sck_s, sck_enable)
	begin
		-- MOSI on falling edge
		-- it can be sampled by the WS2801 on the rising edge.
		if (rising_edge(sck_s)) then
			if wrcnt <= 599 then
				MOSI <= data(to_integer(unsigned(wrcnt)));			
				wrcnt <= (wrcnt + 1);			
				sck_enable <= '1'; -- this will let the clock go high on the next rising edge.
			elsif wrcnt = 600 then                
				MOSI <= '0';
				sck_enable <= '0';
				wrcnt <= (wrcnt + 1);
			elsif wrcnt = 640 then
				sck_enable <= '0';
				MOSI <= '0';
				wrcnt <= (others =>'0');
			else
				sck_enable <= '0';
				MOSI <= '0';
				wrcnt <= (wrcnt + 1);
			end if;				
		end if;
				
		if sck_enable = '1' then
			SCK <= sck_s;
		else
			SCK <= '0';
		end if;	
		
	end process;
		
end Behavioral;
