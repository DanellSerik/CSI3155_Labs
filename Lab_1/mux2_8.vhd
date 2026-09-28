library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 8-bit 2:1 mux, built structurally from 8 instances of mux2_1
-- (one per bit -- used for the LMASK and RMASK load-value muxes).
entity mux2_8 is
    port ( sel      : in  STD_LOGIC;
           in0, in1 : in  STD_LOGIC_VECTOR(7 downto 0);
           y        : out STD_LOGIC_VECTOR(7 downto 0) );
end mux2_8;

architecture structural of mux2_8 is
begin
    BITS: for i in 0 to 7 generate
        M: entity work.mux2_1
            port map ( sel => sel, in0 => in0(i), in1 => in1(i), y => y(i) );
    end generate;
end structural;
