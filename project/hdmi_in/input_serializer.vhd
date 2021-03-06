----------------------------------------------------------------------------------
-- Company: AGH University of Science and Technology
-- Engineer: Dawid Dworak, Mateusz Owczarek
-- 
-- Module Name:  input_serialiser
-- Project Name: flashinglights
-- Target Devices:  XC6SLX9
-- Description: Transforms serial data into 5-bit vectors.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity input_serialiser is
    Port ( clk_fabric_x2 : in  STD_LOGIC;
           clk_input     : in  STD_LOGIC;
           strobe        : in  STD_LOGIC;
           ser_data      : out  STD_LOGIC_VECTOR (4 downto 0);
           ser_input     : in STD_LOGIC);
end input_serialiser;

architecture Behavioral of input_serialiser is
   signal clk0,     clk1,     clkdiv : std_logic;
   signal cascade : std_logic;
   constant bitslip : std_logic := '0';
begin
   clkdiv <= clk_fabric_x2;
   clk0   <= clk_input;
   clk1   <= '0';

ISERDES2_master : ISERDES2
   generic map (
      BITSLIP_ENABLE => TRUE,         -- enable bitslip
      DATA_RATE      => "SDR",        -- data-rate (SDR/DDR)
      DATA_WIDTH     => 5,            -- output data width
      INTERFACE_TYPE => "RETIMED",    -- NETWORKING/NETWORKING_PIPELINED/RETIMED 
      SERDES_MODE    => "MASTER"      -- NONE/MASTER/SLAVE 
   )
   port map (
      CFB0      => open,      
      CFB1      => open,     
      DFB       => open,       
      FABRICOUT => open,    
      INCDEC    => open,    
      -- Q1 - Q4: 1-bit outputs
      Q1        => ser_data(1),
      Q2        => ser_data(2),
      Q3        => ser_data(3),
      Q4        => ser_data(4),
      SHIFTOUT  => cascade,   -- out 1B: cascade output signal for master/slave I/O ??
      VALID     => open,      -- out 1B: output status of the phase detector
      BITSLIP   => bitslip ,   -- in 1B: bitslip on input
      CE0       => '1',        -- in 1B: enable input
      CLK0      => clk0,       -- in 1B: I/O clock network input
      CLK1      => clk1,       -- in 1B: secondary I/O clock network input
      CLKDIV    => clkdiv,     -- in 1B: FPGA logic domain clock input
      D         => ser_input,  -- in 1B: input data
      IOCE      => strobe,     -- in 1B: data strobe input
      RST       => '0',        -- in 1B: asynchronous reset input
      SHIFTIN   => '0'         -- in 1B: cascade input signal for master/slave I/O
   );

ISERDES2_slave : ISERDES2
   generic map (
      BITSLIP_ENABLE => TRUE,         -- Enable Bitslip Functionality (TRUE/FALSE)
      DATA_RATE      => "SDR",        -- Data-rate ("SDR" or "DDR")
      DATA_WIDTH     => 5,            -- Parallel data width selection (2-8)
      INTERFACE_TYPE => "RETIMED",    -- "NETWORKING", "NETWORKING_PIPELINED" or "RETIMED" 
      SERDES_MODE    => "SLAVE"       -- "NONE", "MASTER" or "SLAVE" 
   )
   port map (
      CFB0      => open,      -- out 1B: clock feed-through route output
      CFB1      => open,      -- out 1B: clock feed-through route output
      DFB       => open,      -- out 1B: feed-through clock output
      FABRICOUT => open,    -- out 1B: unsynchrnonized data output
      INCDEC    => open,    -- out 1B: phase detector output
      -- Q1 - Q4: 1B outputs: registered outputs to FPGA logic
      Q1        => open,
      Q2        => open,
      Q3        => open,
      Q4        => ser_data(0),
      SHIFTOUT  => open,      -- out 1B: cascade output signal for master/slave I/O
      VALID     => open,      -- out 1B: output status of the phase detector
      BITSLIP   => bitslip,   -- in 1B: bitslip on input
      CE0       => '1',       -- in 1B: enable input
      CLK0      => clk0,      -- in 1B: I/O clock network input
      CLK1      => clk1,      -- in 1B: secondary I/O clock network input
      CLKDIV    => clkdiv,    -- in 1B: FPGA logic domain clock input
      D         => '0',       -- in 1B: input data
      IOCE      => '1',       -- in 1B: data strobe input
      RST       => '0',       -- in 1B: asynchronous reset input
      SHIFTIN   => cascade    -- in 1B: cascade input signal for master/slave I/O
   );
   
end Behavioral;