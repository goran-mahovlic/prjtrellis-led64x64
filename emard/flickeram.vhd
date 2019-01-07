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
-- https://electronics.stackexchange.com/questions/30521/random-bit-sequence-using-verilog
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
        C_flickerfree: boolean := true; -- improves flickering
        C_bits: integer := 8 -- default 8-bit pwm
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
    -- main counter that will be comperated to duty cycle to get PWM out
    signal R_counter: std_logic_vector(C_bits-1 downto 0);
    signal R_blinky: std_logic_vector(22 downto 0); -- for debugging
    signal R_comparison_counter: std_logic_vector(C_bits-1 downto 0);
    signal R_output_compare: std_logic_vector(C_bits-1 downto 0);
    signal R_random: std_logic_vector(30 downto 0); -- 31-bit random
begin
    -- main process that always runs
    process(clk)
    begin
        if rising_edge(clk) then
          R_blinky <= R_blinky + 1;
          if conv_integer(R_blinky(R_blinky'high-2 downto 0)) = 0 then
            R_output_compare <= R_output_compare + 1; -- for fade
          end if;
        end if;
    end process;
    
    -- simple pseudo random number generator
    -- see https://electronics.stackexchange.com/questions/30521/random-bit-sequence-using-verilog
    process(clk)
    begin
        if rising_edge(clk) then
          R_random <= R_random(29 downto 0) & (R_random(30) xor R_random(27));
        end if;
    end process;
    
    R_counter <= R_blinky(R_blinky'high downto R_blinky'high-C_bits+1);    

    I_yes_flickerfree: if C_flickerfree generate
    F_reverse_bits:
    for i in 0 to C_bits-1 generate
      R_comparison_counter(i) <= R_counter(C_bits-1-i);
    end generate;
    end generate;

    I_not_flickerfree: if not C_flickerfree generate
      -- R_comparison_counter <= R_counter;
      R_comparison_counter <= R_random(R_comparison_counter'high downto 0);
    end generate;

    pwm <= '1' when conv_integer(R_comparison_counter) < conv_integer(R_output_compare) else '0';
end bhv;
