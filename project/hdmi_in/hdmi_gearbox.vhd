----------------------------------------------------------------------------------
-- Company: AGH University of Science and Technology
-- Engineer: Dawid Dworak, Mateusz Owczarek
-- 
-- Module Name:  image_gen - Behavioral 
-- Project Name: flashinglights
-- Target Devices:  XC6SLX9
-- Description: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gearbox is
    Port ( clk_fabric_x2 : in  STD_LOGIC;
           invert        : in  STD_LOGIC;
           framing       : in  std_logic_vector(3 downto 0);
           data_in       : in  std_logic_vector(4 downto 0);
           data_out      : out std_logic_vector(9 downto 0));
end gearbox;

architecture Behavioral of gearbox is
   signal every_other : std_logic := '0';
   signal joined      : std_logic_vector(14 downto 0);
begin

process(clk_fabric_x2) 
   begin
      if rising_edge(clk_fabric_x2) then
         if every_other = '1' then
            case framing is
               when "0000" => data_out <= joined( 9 downto 0);
               when "0001" => data_out <= joined(10 downto 1);
               when "0010" => data_out <= joined(11 downto 2);
               when "0011" => data_out <= joined(12 downto 3);
               when "0100" => data_out <= joined(13 downto 4);
               when others => NULL;
            end case;
         else
            case framing is
               when "0101" => data_out <= joined( 9 downto 0);
               when "0110" => data_out <= joined(10 downto 1);
               when "0111" => data_out <= joined(11 downto 2);
               when "1000" => data_out <= joined(12 downto 3);
               when "1001" => data_out <= joined(13 downto 4);
               when others => NULL;
            end case;
         end if;
         if invert = '1' then 
            joined <= data_in & joined(joined'high downto 5) ;
         else
            joined <= (data_in xor "11111") & joined(joined'high downto 5) ;
         end if;
         every_other <= not every_other;
      end if;
   end process;

end Behavioral;