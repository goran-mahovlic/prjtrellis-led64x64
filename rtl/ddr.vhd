library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library ecp5u;
use ecp5u.components.all;

entity ddr is
  port
  (
    clk: in std_logic;  -- main clock input from 30MHz clock source
    data: in std_logic_vector(1 downto 0);
    ddr_pin: out std_logic
 );
end;

architecture Behavioral of ddr is
begin
  gpdi_ddr: ODDRX1F port map(D0=>data(0), D1=>data(1), Q=>ddr_pin, SCLK=>clk, RST=>'0');
end Behavioral;
