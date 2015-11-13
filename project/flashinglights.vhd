----------------------------------------------------------------------------------
-- Company: AGH University of Science and Technology
-- Engineer: Dawid Dworak, Mateusz Owczarek
-- 
-- Module Name:  flashing_top - Behavioral 
-- Project Name: flashinglights
-- Target Devices:  XC6SLX9
-- Description: Top module for the project
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flashinglights is
    Port ( clk50      : in  STD_LOGIC;
			  sw			 : in STD_LOGIC;
           hdmi_out_p : out  STD_LOGIC_VECTOR(3 downto 0); -- Differential Signaling - the signal is sent over two separate lines, 
           hdmi_out_n : out  STD_LOGIC_VECTOR(3 downto 0); -- out of phase with each other (the positive and negative reversed)   
           leds       : out std_logic_vector(7 downto 0));
end flashinglights;

architecture Behavioral of flashinglights is

	COMPONENT image_gen
	PORT(
		clk50           : IN std_logic;
		move 				 : IN std_logic;
		pixel_clock     : OUT std_logic; --75 MHz for HDTV 720p (according to XAPP495)
		red             : OUT std_logic_vector(7 downto 0);
		green           : OUT std_logic_vector(7 downto 0);
		blue            : OUT std_logic_vector(7 downto 0);
		blank           : OUT std_logic;
		hsync           : OUT std_logic;
		vsync           : OUT std_logic
		);
	END COMPONENT;


	COMPONENT hdmi_out
	PORT(
      clk_pixel  : IN std_logic;
		red        : IN std_logic_vector(7 downto 0);
		green      : IN std_logic_vector(7 downto 0);
		blue       : IN std_logic_vector(7 downto 0);
		blank      : IN std_logic;
		hsync      : IN std_logic;
		vsync      : IN std_logic;          
		tmds_out_p : OUT std_logic_vector(3 downto 0);
		tmds_out_n : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

	signal pixel_clock     : std_logic;

   signal red     : std_logic_vector(7 downto 0);
   signal green   : std_logic_vector(7 downto 0);
   signal blue    : std_logic_vector(7 downto 0);
	signal blank   : std_logic;
	signal hsync   : std_logic;
	signal vsync   : std_logic;          

begin
   leds <= x"55";

---------------------------------------
-- 720p test pattern
---------------------------------------
i_image_gen: image_gen PORT MAP(
		clk50 => clk50,
		move => sw,
		pixel_clock     => pixel_clock,      
		red             => red,
		green           => green,
		blue            => blue,
		blank           => blank,
		hsync           => hsync,
		vsync           => vsync
	);

---------------------------------------------------
-- HDMI(TMDS) output 
---------------------------------------------------
i_hdmi_out: hdmi_out PORT MAP(
		clk_pixel  => pixel_clock,
     
		red        => red,
		green      => green,
		blue       => blue,
		blank      => blank,
		hsync      => hsync,
		vsync      => vsync,
     
		tmds_out_p => hdmi_out_p,
		tmds_out_n => hdmi_out_n
	);


end Behavioral;

