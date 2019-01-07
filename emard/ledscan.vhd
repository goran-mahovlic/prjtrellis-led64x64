-- AUTHOR=EMARD
-- LICENSE=BSD

-- for some info, see here
-- http://www.benadorassociates.com/pz64f6ad8-cz57da853-64-x-64-pixels-p2-5-p3-p4-indoor-full-color-led-display-module-without-using-the-ribbon-cable.html
-- 

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

-- driving sequence

-- addrx -2: blank <= 1, addryy++
-- addrx -1: blank <= 0
-- addrx 0-63: display bits
-- addrx 62: latch <= 1
-- addrx 63: latch <= 0

-- during addrx = 0-63:
-- convert addrx and addry with combinatorial logic to calculate RGB0 and RGB1
-- RGB0 is pixel in upper half, RGB1 is pixel in lower half (32 pixels below)
-- display clock is the same as clk

-- when all 64x64 LEDs are illuminated (WHITE)
-- then from 4V supply it draws 3.3A

entity ledscan is
    generic
    (
        bits_x: integer := 6; -- 2^n LEDs is actual panel width
        bits_y: integer := 6  -- 2^n LEDs is actual panel height
    );
    port
    (
        clk     : in  std_logic; -- any clock, usually 25 MHz
        -- X counter out (high bit set means H-blank, content not displayed)
        -- combinatorial logic from addrx and addry should generate RGB0 (upper half) and RGB1 (lower half)
        addrx       : out std_logic_vector(bits_x downto 0); -- x addry it has 1 bit more
        -- following signals output to LED Panel
        addry       : out std_logic_vector(bits_y-2 downto 0); -- y addry 0-31, 1 bit less
        -- latch: short pulse '1' transfers data from shift register
        -- to row drivers and illuminates LED rows addry+0 and addry+32 
        latch      : out std_logic;
        -- blank: short pulse '1' turns off illuminated row and
        -- allows switching to the next row of data.
        blank      : out std_logic
    );
end;

architecture bhv of ledscan is
    -- Internal X/Y counters
    signal R_addrx: std_logic_vector(bits_x downto 0); -- one bit more to have small H-blank area
    signal R_addry: std_logic_vector(bits_y-2 downto 0); -- one bit less, iterates over half of display
    signal R_latch, R_blank: std_logic;
begin
    addrx <= R_addrx;
    addry <= R_addry;
    latch <= R_latch;
    blank <= R_blank;

    -- main process that always runs
    process(clk)
    begin
        if rising_edge(clk) then
          if R_addrx = "0111111" then
            R_addrx <= "1111110"; -- -2
          else
            R_addrx <= R_addrx + 1; -- x counter always runs
          end if;

          case R_addrx is
            when "1111110" => -- -2
              R_blank <= '1';
              R_addry <= R_addry + 1; -- increment during blank=1
            when "1111111" => -- -1
              R_blank <= '0';
            when "0111110" => -- 62
              R_latch <= '1'; -- send latch 1-clock early
            when "0111111" => -- 63
              R_latch <= '0'; -- remove latch
            when others =>
          end case;
        end if;
    end process;
    
end bhv;
