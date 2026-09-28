library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 8-bit bitwise OR, built structurally from 8 instances of or2
-- (used to combine LMASK and RMASK for the DISPLAY mux).
entity or8 is
    port ( a, b : in  STD_LOGIC_VECTOR(7 downto 0);
           y    : out STD_LOGIC_VECTOR(7 downto 0) );
end or8;

architecture structural of or8 is
begin
    BITS: for i in 0 to 7 generate
        G: entity work.or2 port map ( a => a(i), b => b(i), y => y(i) );
    end generate;
end structural;
