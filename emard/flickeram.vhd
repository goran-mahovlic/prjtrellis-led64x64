-- AUTHOR=EMARD
-- LICENSE=BSD

-- TODO
-- pseudo-random 8-bit PWM pixel flickering base
-- to make nearly flicker-free 8-bit fading of the LEDs

-- pseudo-random generator dynamically changes
-- values in this lookup table.
-- Outputs real time PWM signal which can be used
-- to drive individual pixel.

-- pseudo-random is done by shuffling the bits of
-- the counter which would normally run 0-255

-- a lookup table will shuffle the bits, in each
-- cycle 2 entries will be swapped

-- shuffled bit value is arithmetically compared to
-- pwm intensity like a<b to create output signal

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity flickeram is
    generic
    (
        dummy: integer := 0 -- dummy parameter
    );
    port
    (
        clk: in  std_logic; -- any clock, usually 25 MHz
        -- X counter out (high bit set means H-blank, content not displayed)
        -- combinatorial logic from addrx and addry should generate RGB0 (upper half) and RGB1 (lower half)
        value: in std_logic_vector(7 downto 0); -- 8-bit input desired intensity value
        -- following signals output to LED Panel
        pwm: out std_logic -- 1: pixel enable signal, to be used as PWM in real-time
    );
end;

architecture bhv of flickeram is
    signal R_counter: std_logic;
begin
    -- main process that always runs
    process(clk)
    begin
        if rising_edge(clk) then
        end if;
    end process;
    
end bhv;
